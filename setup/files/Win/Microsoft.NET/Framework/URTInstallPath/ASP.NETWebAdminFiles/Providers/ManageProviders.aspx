<%@ page masterPageFile="~/WebAdminWithConfirmation.master" inherits="System.Web.Administration.ProvidersPage"%>
<%@ Register TagPrefix="uc" TagName="ProviderList" Src="ProviderList.ascx"%>
<%@ MasterType virtualPath="~/WebAdminWithConfirmation.master" %>
<%@ Import Namespace="System.Reflection" %>
<%@ Import Namespace="System.Web.Configuration" %>

<script runat="server" language="cs">
private void BackToPreviousPage(object sender, EventArgs e) {
    ReturnToPreviousPage(sender, e);
}

private void BindProviderList(ProviderSettingsCollection providers,
                              string defaultProvider,
                              ProviderListUserControl providerList) {
                              
    ArrayList providersArray = new ArrayList();
    
    foreach (System.Configuration.ProviderSettings mps in providers) {
        string name = mps.Name;
        string connectionString = mps.Parameters["connectionStringName"];
        providersArray.Add(new ProviderListUserControl.ProviderListItems(mps.Name, mps.Parameters["description"], mps.Parameters["connectionStringName"], mps.Type, false));
    }
                              
    providerList.DataSource = providersArray;
    
    int i = 0;
    foreach(System.Configuration.ProviderSettings ps in providers){
        if (ps.Name == defaultProvider) {
            providerList.SelectedIndex = i;
        }
        i++;
    }
    providerList.DataBind();
}

private void BindProviderLists() {
    Configuration config = OpenWebConfiguration(ApplicationPath);

    MembershipSection membershipSection = (MembershipSection)config.GetSection("system.web/membership");
    MembershipProviderList.ParentProviderCount = ParentProviderCount("membership");
    BindProviderList(membershipSection.Providers, membershipSection.DefaultProvider, MembershipProviderList);

    RoleManagerSection roleManagerSection = (RoleManagerSection)config.GetSection("system.web/roleManager");
    RoleProviderList.ParentProviderCount = ParentProviderCount("roleManager");
    BindProviderList(roleManagerSection.Providers, roleManagerSection.DefaultProvider, RoleProviderList);
}

private void Page_Load() {
    if (!IsPostBack) {
        BindProviderLists();
    }
}

private void SelectProvider(object sender, ProviderListUserControl.ProviderEventArgs e) {
    RadioButton radioButton = (RadioButton) sender;

    Configuration config = OpenWebConfiguration(ApplicationPath);
    switch (e.ServiceName) {
        case "membership":
            MembershipSection membershipSection = (MembershipSection)config.GetSection("system.web/membership");
            membershipSection.DefaultProvider = e.ProviderName;
            break;
        case "roleManager":
            RoleManagerSection roleManagerSection = (RoleManagerSection)config.GetSection("system.web/roleManager");
            roleManagerSection.DefaultProvider = e.ProviderName;
            break;
        default:
            throw new HttpException((string)String.Format((string)GetLocalResourceObject("UnrecognizedService"), e.ServiceName));
    }

    SaveConfig(config);
    BindProviderLists();
}

private int ParentProviderCount(string serviceName) {
    string parentPath = GetParentPath(ApplicationPath);
    Configuration parentConfig = OpenWebConfiguration(parentPath);
    switch (serviceName) {
        case "membership":
            MembershipSection membershipSection = (MembershipSection)parentConfig.GetSection("system.web/membership");
            return membershipSection.Providers.Count;
        case "roleManager":
            RoleManagerSection roleManagerSection = (RoleManagerSection)parentConfig.GetSection("system.web/roleManager");
            return roleManagerSection.Providers.Count;
        default:
            return -1;
    }
}

private bool TestConnectionHelper(string connection) {
    bool good = true;
    try {
        Type type = typeof(HttpApplication).Assembly.GetType("System.Web.DataAccess.SqlConnectionHelper");
        MethodInfo method = type.GetMethod("GetConnection", BindingFlags.Static | BindingFlags.Public | BindingFlags.NonPublic);
        if (method != null) {
            method.Invoke(null, new object[]{connection, false /* revert impersonation */});
        }
    }
    catch {
        good = false;
    }
    return good;
}

private bool TestConnectionString(object sender, EventArgs e) {
    LinkButton b = sender as LinkButton;
    string connectionString = null;
    try {
        Configuration config = OpenWebConfiguration(ApplicationPath);
        ConnectionStringsSection connectionStringSection = (ConnectionStringsSection)config.GetSection("connectionStrings");
        // Review: Management API doesn't allow retrieve a connection string setting via direct name look up
        // Need to create an object with the name set for looking up instead.
        ConnectionStringSettings css = new ConnectionStringSettings();
        css.Name = b.CommandArgument /* connection string name */;
        css = connectionStringSection.ConnectionStrings[connectionStringSection.ConnectionStrings.IndexOf(css)];
        connectionString = css.ConnectionString;
    }
    catch {
        return false;
    }

    if (b.CommandName.Contains("Sql")) {
        return TestConnectionHelper(connectionString);
    } else {
        return true;
    }
}

private void TestConnection(object sender, EventArgs e) {
    bool good = TestConnectionString(sender, e);
    LinkButton b = (LinkButton) sender;
    bool isSql = b.CommandName.Contains("Sql");
    bool isWindowsToken = b.CommandName.Contains("WindowsToken");
    if (isWindowsToken) {
        good = true;
    }

    mv1.ActiveViewIndex = 1;
    testConnectionLiteral.Text = TestConnectionText(good, isSql);

    OKButton.Visible = true;
    Master.SetDisplayUI(true /* confirmation */);
}

private void OK_Click(object sender, EventArgs e) {
    Master.SetDisplayUI(false);
}

</script>

<%-- Main Content --%>
<asp:content runat="server" contentplaceholderid="titleBar">
    <asp:literal runat="server" text="<%$ Resources:ManageProviders %>"/>
</asp:content>

<asp:content runat="server" contentplaceholderid="content">
    <table height="100%" width="100%" cellspacing="0" cellpadding="0" valign="top" align="left">
        <tr class="bodyTextNoPadding" height="1%">
            <td>
                <asp:literal runat="server" text="<%$ Resources:UseThisPage %>"/>
            </td>
        </tr>
        <tr height="1%">
            <td/>
                &nbsp;
            </td>
        </tr>
        <tr height="1%">
            <td>
                <uc:ProviderList runat="server" id="MembershipProviderList"
                                 HeaderText="<%$ Resources:MembershipProvider %>" ServiceName="membership"
                                 OnSelectProvider="SelectProvider"
                                 OnTestConnection="TestConnection" />
            </td>
        </tr>
        <tr height="1%">
            <td/>
                &nbsp;
            </td>
        </tr>
        <tr height="1%">
            <td>
                <uc:ProviderList runat="server" id="RoleProviderList"
                                 HeaderText="<%$ Resources:RoleProvider %>" ServiceName="roleManager"
                                 OnSelectProvider="SelectProvider"
                                 OnTestConnection="TestConnection"/>
            </td>
        </tr>
        <tr height="1%">
            <td/>
                &nbsp;
            </td>
        </tr>
        <tr height="1%">
            <td/>
                &nbsp;
            </td>
        </tr>
        <tr height="1%">
            <td>
            </td>
        </tr>
        <tr height="1%">
            <td/>
                &nbsp;
            </td>
        </tr>
        <tr height="1%">
            <td>
            </td>
        </tr>
        <tr height="93%">
            <td/>
                &nbsp;
            </td>
        </tr>
    </table>
</asp:content>

<asp:content runat="server" contentplaceholderid="buttons">
    <asp:button ValidationGroup="none" text="<%$ Resources:Back %>" id="BackButton" onclick="BackToPreviousPage" runat="server"/>
</asp:content>

<%-- Confirmation Dialog --%>
<asp:content runat="server" contentplaceholderid="dialogTitle">
    <asp:literal runat="server" text="<%$ Resources:ProviderManagement %>"/>
</asp:content>

<asp:content runat="server" contentplaceholderid="dialogContent">
    <asp:multiview runat="server" id="mv1" enableViewState="false" activeViewIndex="0">
        <asp:view runat="server">
            <table cellspacing="4" cellpadding="4">
                <tr class="bodyText">
                    <td valign="top">
                        <asp:Image runat="server" ImageUrl="~/Images/alert_lrg.gif"/>
                    </td>
                    <td>
                        <asp:literal runat="server" id="areYouSureLiteral" />
                    </td>
                </tr>
            </table>
        </asp:view>
        <asp:view runat="server">
            <asp:label runat="server" id="testConnectionLiteral"/>
        </asp:view>
    </asp:multiview>
</asp:content>

<asp:content runat="server" contentplaceholderid="dialogBottomLeftButton">
</asp:content>
<asp:content runat="server" contentplaceholderid="dialogBottomRightButton">
    <asp:Button runat="server" id="OKButton" enableViewState="false" OnClick="OK_Click" Text="<%$ Resources:OK%>" visible="false" width="75"/>
</asp:content>
