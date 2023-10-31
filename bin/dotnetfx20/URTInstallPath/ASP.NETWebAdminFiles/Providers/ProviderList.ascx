<%@ Control ClassName="ProviderListUserControl"%>
<%@ Import Namespace="System.Text" %>
<%@ Import Namespace="System.Globalization" %>
<%@ Import Namespace="System.Web.Administration" %>

<script runat="server" language="cs">

// Helper event related classes for raising events to users of the control
public delegate void ProviderEventHandler(object sender, ProviderEventArgs e);
public delegate void TestConnectionEventHandler(object sender, EventArgs e);

public class ProviderListItems {

    private string _providerName;
    private string _connectionStringName;
    private string _description;
    private string _type;
    private bool   _isGroup;
    public string ProviderName {
        get {
            return _providerName;
        }
    }
    public string ConnectionStringName {
        get {
            return _connectionStringName;
        }
    }
    public string Description {
        get {
            return _description;
        }
    }
    public string Type {
        get {
            return _type;
        }
    }
    public bool IsGroup {
        get {
            return _isGroup;
        }
    }
    public ProviderListItems(string providerName, string description, string connectionStringName, string type, bool isGroup) {
        _providerName = providerName;
        _connectionStringName = connectionStringName;
        _description = description;
        _type = type;
        _isGroup = isGroup;
   }

   public override string ToString() {
        return _providerName;
   }
}

public class ProviderEventArgs : EventArgs {

    private string _serviceName;
    private string _providerName;
    private bool   _isGroup;

    public string ServiceName {
        get {
            return _serviceName;
        }
    }
    public string ProviderName {
        get {
            return _providerName;
        }
    }
    public bool IsGroup {
        get {
            return _isGroup;
        }
    }
    public ProviderEventArgs(string serviceName, string providerName, bool isGroup) {
        _serviceName = serviceName;
        _providerName = providerName;
        _isGroup = isGroup;
    }
}

private bool IsTestable(string providerName) {
    if (providerName.Contains("Sql")) {
        return true;
    } else {
        return false;
    }
}

private string GetProviderName(object ps) {
    return ((ProviderListItems)ps).ProviderName;
}
private string GetConnectionStringName(object ps) {
    return ((ProviderListItems)ps).ConnectionStringName;
}
private string GetTypeString(object ps) {
    return ((ProviderListItems)ps).Type;
}
private string GetDescription(object ps) {
    return ((ProviderListItems)ps).Description;
}
private string GetIsGroup(object ps) {
    return ((ProviderListItems)ps).IsGroup.ToString();
}


private static readonly object EventSelectProvider = new object();
private static readonly object EventTestConnection = new object();

private string _serviceName = string.Empty;

public object DataSource {
    get {
        return ProviderListGridView.DataSource;
    }
    set {
        ProviderListGridView.DataSource = value;
    }
}

public string HeaderText {
    get {
        return HeaderLiteral.Text;
    }
    set {
        HeaderLiteral.Text = value;
    }
}

public int ParentProviderCount {
    get {
        object x = ViewState["ParentProviderCount"];
        return (x == null) ? -1 : (int) x;
    }
    set {
        ViewState["ParentProviderCount"] = value;
    }
}

public int SelectedIndex {
    get {
        return ProviderListGridView.SelectedIndex;
    }
    set {
        ProviderListGridView.SelectedIndex = value;
    }
}

public string ServiceName {
    get {
        return _serviceName;
    }
    set {
        _serviceName = value;
    }
}

public event ProviderEventHandler SelectProvider {
    add {
        Events.AddHandler(EventSelectProvider, value);
    }
    remove {
        Events.RemoveHandler(EventSelectProvider, value);
    }
}

public event TestConnectionEventHandler TestConnection {
    add {
        Events.AddHandler(EventTestConnection, value);
    }
    remove {
        Events.RemoveHandler(EventTestConnection, value);
    }
}

public void DataBind() {
    ProviderListGridView.DataBind();
}

private string GetToolTip(string resourceName, string itemName) {
    string tempString = (string) GetLocalResourceObject(resourceName);
    return String.Format((string)GetGlobalResourceObject("GlobalResources","ToolTipFormat"), tempString, itemName);
}

private void ProviderListGridView_DataBound(object sender, GridViewRowEventArgs e) {
    GridViewRow row = e.Row;
    // Response.Write(DataBinder.Eval(row.DataItem, "Name"));
    if (row.RowType == DataControlRowType.DataRow &&
        row.RowIndex == ProviderListGridView.SelectedIndex) {
        RadioButton radioButton = (RadioButton) row.FindControl("ProviderRadioButton");
        if (radioButton != null) {
            radioButton.Checked = true;
        }
    }
}

private void ProviderRadioButton_Click(object sender, EventArgs e) {
    RadioButton radioButton = (RadioButton) sender;
    GridViewRow row = (GridViewRow) radioButton.Parent.Parent;

    Label  isGroupLabel = (Label) row.FindControl("IsGroupControl");
    bool isGroup = (isGroupLabel.Text.ToLower() == "true");
    ProviderEventArgs providerArgs = new ProviderEventArgs(ServiceName, radioButton.Text, isGroup);

    ProviderEventHandler handler = (ProviderEventHandler)Events[EventSelectProvider];
    if (handler != null) {
        handler(sender, providerArgs);
    }
}

private void TestConnection_Click(object sender, EventArgs e) {
    TestConnectionEventHandler handler = (TestConnectionEventHandler)Events[EventTestConnection];
    if (handler != null) {
        handler(sender, e);
    }
}


</script>

<table height="100%" width="100%" cellspacing="0" cellpadding="4"
       rules="all" bordercolor="#CCDDEF" border="1"
       style="border-color:#CCDDEF;border-style:None;border-collapse:collapse;">
    <tr height="1%">
        <td class="callOutStyle" valign="top">
            <asp:Literal runat="server" id="HeaderLiteral"/>
        </td>
    </tr>
    <tr align="left" valign="top">
        <td>
            <asp:GridView runat="server" id="ProviderListGridView"
                          width="100%" cellspacing="0" cellpadding="0" border="0"
                          AutoGenerateColumns="false" ShowHeader="false"
                          OnRowDatabound="ProviderListGridView_DataBound"
                          EmptyDataText="<%$ Resources:NoProvidersCreated %>">
                <rowstyle cssclass="gridRowStyle" />
                <alternatingrowstyle cssclass="gridAlternatingRowStyle" />
                <EmptyDataRowStyle cssClass="bodyText" forecolor="gray"/>

                <columns>
                    <asp:TemplateField ItemStyle-Width="20%">
                        <ItemTemplate>
                            <asp:RadioButton runat="server" id="ProviderRadioButton"
                                             AutoPostBack="true" OnCheckedChanged="ProviderRadioButton_Click"
                                             Text='<%# GetProviderName(Container.DataItem) %>'/>
                        </ItemTemplate>
                    </asp:TemplateField>

                    <asp:TemplateField ItemStyle-Width="20%">
                        <ItemTemplate>
                            <asp:LinkButton runat="server" id="TestProviderLinkButton"
                                            Visible='<%# IsTestable(GetProviderName(Container.DataItem)) %>'
                                            Text="<%$ Resources:Test %>" ForeColor="blue" OnClick="TestConnection_Click"
                                            toolTip='<%# GetToolTip("Test",GetProviderName(Container.DataItem)) %>'
                                            CommandArgument='<%# GetConnectionStringName(Container.DataItem) %>'
                                            CommandName='<%# GetTypeString(Container.DataItem) %>'/>
                        </ItemTemplate>
                    </asp:TemplateField>

                    <asp:TemplateField ItemStyle-Width="59%">
                        <ItemTemplate>
                            <asp:Label runat="server" Text='<%# GetDescription(Container.DataItem) %>' />
                        </ItemTemplate>                        
                    </asp:TemplateField>

                    <asp:TemplateField ItemStyle-Width="0">
                        <ItemTemplate>
                            <asp:Label visible=false id="IsGroupControl" runat="server" Text='<%# GetIsGroup(Container.DataItem) %>' />
                        </ItemTemplate>                        
                    </asp:TemplateField>

                </columns>
            </asp:Gridview>
        </td>
    </tr>
</table>
