<%@ page masterPageFile="~/WebAdminWithConfirmation.master" inherits="System.Web.Administration.ApplicationConfigurationPage"%>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Globalization" %>
<%@ Import Namespace="System.Web.Administration" %>
<%@ Import Namespace="System.Web.Configuration" %>

<script runat="server" language="cs">

private enum LocationType {
    Local = 0,
    Inherited = 1,
    Overridden = 2,
}

private WebAdminWithConfirmationMasterPage Master {
    get {
        return (WebAdminWithConfirmationMasterPage)base.Master;
    }
}

private void AddAppSettingRow(DataTable dataTable, string name, string value, LocationType locationType) {
    DataRow row = dataTable.NewRow();

    // Assume the columns are in expected order when the table is created
    row[0] = name;
    row[1] = value;
    row[2] = locationType;

    dataTable.Rows.Add(row);
}

private void BindAppSettings() {
    // TODO: Perf: It might not be needed if there are no application settings.

    DataTable dataTable = new DataTable();
    dataTable.Locale = CultureInfo.InvariantCulture;  // FxCop

    dataTable.Columns.Add("Name", typeof(string));
    dataTable.Columns.Add("Value", typeof(string));
    dataTable.Columns.Add("LocationType", typeof(LocationType));

    string appPath = ApplicationPath;
    string parentPath = GetParentPath(appPath);

    Configuration parentConfig = OpenWebConfiguration(parentPath);
    AppSettingsSection parentAppSettingsSection = (AppSettingsSection) parentConfig.GetSection("appSettings");
    KeyValueConfigurationCollection parentSettings = parentAppSettingsSection.Settings;

    Configuration config = OpenWebConfiguration(appPath);
    AppSettingsSection appSettingsSection = (AppSettingsSection) config.GetSection("appSettings");
    KeyValueConfigurationCollection settings = appSettingsSection.Settings;

    foreach (KeyValueConfigurationElement element in settings) {
        string name = element.Key;
        string value = element.Value;
        KeyValueConfigurationElement parentValue = parentSettings[name];
        if (parentValue != null && parentValue.Value != value) {
            AddAppSettingRow(dataTable, name, value, LocationType.Overridden);
            parentSettings.Remove(name);
        }
        else if (parentValue == null) {
            AddAppSettingRow(dataTable, name, value, LocationType.Local);
        }
        else {
            // we have something which is getting inherited but not getting overridden...
            AddAppSettingRow(dataTable, name, value, LocationType.Inherited);
        }
    }

    DataView dataView = new DataView(dataTable);
    dataView.Sort = "Name ASC";

    AppSettingGridView.DataSource = dataView;
    AppSettingGridView.DataBind();

    // Display the label of # of app settings
    int totalCount = dataView.Count;
    string numOfAppSettingsText = String.Format((string)GetLocalResourceObject("NumOfAppSettingsText"), totalCount.ToString(CultureInfo.InvariantCulture));
    if (totalCount <= AppSettingGridView.PageSize) {
        NumOfAppSettingsLabel.Visible = true;
        NumOfAppSettingsLabel.Text = numOfAppSettingsText;
    }
    else {
        // Merge the text in the pager row
        NumOfAppSettingsLabel.Visible = false;

        TableCell labelCell = new TableCell();
        labelCell.HorizontalAlign = DirectionalityHorizontalAlign;
        labelCell.VerticalAlign = VerticalAlign.Top;
        labelCell.ColumnSpan = 4;
        labelCell.Text = numOfAppSettingsText;

        GridViewRow pagerRow = AppSettingGridView.BottomPagerRow;
        TableCell pagerCell = pagerRow.Cells[0];
        pagerCell.ColumnSpan -= 4;
        pagerRow.Cells.AddAt(0, labelCell);
    }
}

private string GetToolTip(string resourceName, string itemName) {
    string tempString = (string) GetLocalResourceObject(resourceName);
    return String.Format((string)GetGlobalResourceObject("GlobalResources","ToolTipFormat"), tempString, itemName);
}

private string GetLocationTypeText(LocationType locationType) {
    string resourceName = PropertyConverter.EnumToString(typeof(LocationType), locationType);
    return ((string) GetLocalResourceObject(resourceName));
}

void Page_Load() {
    if (!IsPostBack) {
        string appPath = ApplicationPath;
        if (!String.IsNullOrEmpty(appPath)) {
            MainTitle.Text = String.Format((string)GetLocalResourceObject("TitleForSite"), appPath);
        }

        BindAppSettings();

        AppSettingGridView.HeaderStyle.HorizontalAlign = DirectionalityHorizontalAlign;
    }
}

void AppSettingGridView_Delete(object sender, GridViewDeleteEventArgs e) {
    GridViewRow row = AppSettingGridView.Rows[e.RowIndex];
    TableCell nameCell = row.Cells[1];
    Name.Value = HttpUtility.HtmlDecode(nameCell.Text.ToString());
    DeleteName.Text = String.Format((string)GetLocalResourceObject("ConfirmationText"), nameCell.Text);

    // Go to confirmation UI
    Master.SetDisplayUI(true);
}

void AppSettingGridView_Edit(object sender, GridViewEditEventArgs e) {
    StringBuilder editUrl = new StringBuilder();
    editUrl.Append("EditAppSetting.aspx");

    GridViewRow row = AppSettingGridView.Rows[e.NewEditIndex];
    TableCell nameCell = row.Cells[1];
    TableCell valueCell = row.Cells[2];

    string tempString = HttpUtility.HtmlDecode(nameCell.Text.ToString());
    editUrl.Append("?name=");
    tempString =  HttpUtility.UrlEncode(tempString);

    editUrl.Append(tempString);

    tempString = HttpUtility.HtmlDecode(valueCell.Text.ToString());
    editUrl.Append("&value=");
    tempString =  HttpUtility.UrlEncode(tempString);

    editUrl.Append(tempString);

    Response.Redirect(editUrl.ToString());
}

void AppSettingGridView_PageIndexChanged(object sender, GridViewPageEventArgs e) {
    AppSettingGridView.PageIndex = e.NewPageIndex;
    BindAppSettings();
}

// Confirmation's related handlers
void Yes_Click(object sender, EventArgs e) {

    string appPath = ApplicationPath;
    string parentPath = GetParentPath(appPath);

    Configuration parentConfig = OpenWebConfiguration(parentPath);
    AppSettingsSection parentAppSettingsSection = (AppSettingsSection) parentConfig.GetSection("appSettings");
    KeyValueConfigurationCollection parentSettings = parentAppSettingsSection.Settings;
    
    Configuration config = OpenWebConfiguration(ApplicationPath);
    AppSettingsSection appSettingsSection = (AppSettingsSection) config.GetSection("appSettings");

    // check if this is an inherited setting that
    // we are trying to remove.
    KeyValueConfigurationElement parentValue = parentSettings[Name.Value];
    if (parentValue != null) {
        // add an identical entry that the parent already has, so local entry gets deleted
        if (appSettingsSection.Settings[Name.Value] == null)
            appSettingsSection.Settings.Add(Name.Value,parentValue.Value);
        else
            appSettingsSection.Settings[Name.Value].Value = parentValue.Value;
    }
    else {
        appSettingsSection.Settings.Remove(Name.Value);
    }
    
    SaveConfig(config);

    // Before data binding again, we need to adjust the current page index if
    // this is the last property to be deleted on this page
    if (AppSettingGridView.PageIndex != 0) {
        int totalCount = AppSettingGridView.Rows.Count - 1;
        if ((totalCount % AppSettingGridView.PageSize) == 0) {
            AppSettingGridView.PageIndex -= 1;
        }
    }

    // Re-populate data and return to the content page
    BindAppSettings();
    Master.SetDisplayUI(false);
}

void No_Click(object sender, EventArgs e) {
    BindAppSettings();
    Master.SetDisplayUI(false);
}

</script>

<%-- Main Content --%>
<asp:content runat="server" contentplaceholderid="titleBar">
    <asp:Literal runat="server" id="MainTitle" Text="<%$ Resources:Title %>"/>
</asp:content>

<asp:content runat="server" contentplaceholderid="content">
    <table height="100%" width="100%" cellspacing="0" cellpadding="0">
        <tr>
            <td>
                <table height="100%" width="100%" cellspacing="0" cellpadding="1">
                    <tr class="bodyText" valign="top" height="1%">
                        <td>
                            <asp:Literal runat="server" Text="<%$ Resources:Instructions %>"/>
                        </td>
                    </tr>
                    <tr height="20"><td/></tr>
                    <tr height="1%">
                        <td>
                            <table height="100%" width="100%" cellspacing="0" cellpadding="0"
                                   rules="all" bordercolor="#CCDDEF" border="1" style="border-color:#CCDDEF;border-style:None;border-collapse:collapse;">
                                <tr valign="top">
                                    <td class="lbBorders">
                                        <asp:GridView runat="server" id="AppSettingGridView" width="100%" cellspacing="0" cellpadding="5" border="0"
                                                      AutoGenerateColumns="false"
                                                      OnRowDeleting="AppSettingGridView_Delete" OnRowEditing="AppSettingGridView_Edit"
                                                      AllowPaging="true" PageSize="7" OnPageIndexChanging="AppSettingGridView_PageIndexChanged"
                                                      UseAccessibleHeader="true">
                                            <rowstyle cssclass="gridRowStyle" />
                                            <alternatingrowstyle cssclass="gridAlternatingRowStyle" />
                                            <pagersettings mode="Numeric" Position="Bottom" />
                                            <pagerstyle cssClass="gridPagerStyle" />
                                            <headerstyle cssclass="callOutStyle" font-bold="true" />

                                            <Columns>
                                                <asp:TemplateField ItemStyle-Width="15%" HeaderText="<%$ Resources:SourceHeader %>">
                                                    <ItemTemplate>
                                                        <%# GetLocationTypeText((LocationType) DataBinder.Eval(Container.DataItem, "LocationType"))%>
                                                    </ItemTemplate>
                                                </asp:TemplateField>

                                                <asp:BoundField HeaderText="<%$ Resources:NameHeader %>" DataField="Name" ItemStyle-Width="20%"/>

                                                <asp:BoundField HeaderText="<%$ Resources:ValueHeader %>" DataField="Value" ItemStyle-Width="20%"/>

                                                <asp:TemplateField ItemStyle-Width="15%">
                                                    <ItemTemplate>
                                                        <asp:LinkButton runat="server" commandname="Edit" forecolor="blue"
                                                                        Text='<%# (((LocationType) DataBinder.Eval(Container.DataItem, "LocationType")) == LocationType.Inherited) ? (string)GetLocalResourceObject("OverrideLinkText") : (string)GetLocalResourceObject("EditLinkText") %>'
                                                                        ToolTip='<%# (((LocationType) DataBinder.Eval(Container.DataItem, "LocationType")) == LocationType.Inherited) ? GetToolTip("OverrideLinkToolTip",DataBinder.Eval(Container.DataItem, "Name").ToString()) : GetToolTip("EditLinkToolTip",DataBinder.Eval(Container.DataItem, "Name").ToString()) %>'/>
                                                    </ItemTemplate>
                                                </asp:TemplateField>

                                                <asp:TemplateField>
                                                    <ItemTemplate>
                                                        <asp:LinkButton runat="server" commandname="Delete" forecolor="blue"
                                                                        Text="<%$ Resources:DeleteLinkText %>" toolTip='<%# GetToolTip("DeleteLinkToolTip",DataBinder.Eval(Container.DataItem, "Name").ToString()) %>'
                                                                        Enabled='<%# (((LocationType) DataBinder.Eval(Container.DataItem, "LocationType")) == LocationType.Inherited) ? false : true %>'/>
                                                    </ItemTemplate>
                                                </asp:TemplateField>
                                            </Columns>
                                        </asp:Gridview>
                                    </td>
                                </tr>
                                <tr class="gridPagerStyle" style="padding-left:5;">
                                    <td>
                                        <asp:Label runat="server" id="NumOfAppSettingsLabel"/>
                                    </td>
                                </tr>
                            </table>
                        </td>
                    </tr>
                    <tr class="bodyText" valign="top" >
                        <td>
                            <asp:HyperLink runat="server" NavigateUrl="CreateAppSetting.aspx" Text="<%$ Resources:CreateAppSettingLinkText %>"/>
                        <td>
                    </tr>
                </table>
            </td>
            <td width="100"/>
        </tr>
    </table>
</asp:content>

<asp:content runat="server" contentplaceholderid="buttons">
    <asp:Button ValidationGroup="none" Text="<%$ Resources:GlobalResources,BackButtonLabel %>" id="BackButton" onclick="ReturnToPreviousPage" runat="server"/>
</asp:content>

<%-- Confirmation Dialog --%>
<asp:content runat="server" contentplaceholderid="dialogTitle">
    <asp:Literal runat="server" Text="<%$ Resources:DeleteAppSettingTitle %>"/>
</asp:content>

<asp:content runat="server" contentplaceholderid="dialogContent">
    <asp:HiddenField runat="server" id="Name"/>
    <table cellspacing="4" cellpadding="4">
        <tr class="bodyText">
            <td>
                <asp:Image runat="server" ImageUrl="~/Images/alert_lrg.gif"/>
            </td>
            <td>
                <asp:Literal runat="server" id="DeleteName"/>
            </td>
        </tr>
    </table>
</asp:content>

<asp:content runat="server" contentplaceholderid="dialogBottomLeftButton">
    <asp:Button runat="server" OnClick="Yes_Click" Text="<%$ Resources:GlobalResources,YesButtonLabel %>" width="100"/>
</asp:content>

<asp:content runat="server" contentplaceholderid="dialogBottomRightButton">
    <asp:Button runat="server" OnClick="No_Click" Text="<%$ Resources:GlobalResources,NoButtonLabel %>" width="75"/>
</asp:content>
