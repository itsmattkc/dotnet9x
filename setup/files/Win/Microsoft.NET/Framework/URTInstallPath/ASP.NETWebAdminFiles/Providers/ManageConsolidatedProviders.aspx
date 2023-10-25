<%@ page masterPageFile="~/WebAdminWithConfirmation.master" inherits="System.Web.Administration.ProvidersPage"%>
<%@ MasterType virtualPath="~/WebAdminWithConfirmation.master" %>
<%@ Register TagPrefix="uc" TagName="ProviderList" Src="ProviderList.ascx"%>
<%@ Import Namespace="System.Reflection" %>
<%@ Import Namespace="System.Web.Configuration" %>

<script runat="server" language="cs">

private int _parentProviderCount = 0;

private string CurrentProvider {
    get {
        return (string)Session["WebAdminManageConsolidatedProvidersCurrentProvider"];
    }
    set {
        Session["WebAdminManageConsolidatedProvidersCurrentProvider"] = value;
    }
}

private void BackToPreviousPage(object sender, EventArgs e) {
    ReturnToPreviousPage(sender, e);
}

private void BindProviderList(ProviderListUserControl providerList) {
    string appPath = ApplicationPath;
    int trailingSlash = appPath.LastIndexOf("/");
    string parentAppPath = appPath.Substring(0, trailingSlash);
    if (parentAppPath != null && parentAppPath.Length == 0) {
        parentAppPath = null;
    }

    Configuration config = OpenWebConfiguration(appPath);
    MembershipSection membershipSection = (MembershipSection)config.GetSection("system.web/membership");
    RoleManagerSection roleManagerSection = (RoleManagerSection)config.GetSection("system.web/roleManager");
  
    Configuration parentConfig = OpenWebConfiguration(parentAppPath);
    MembershipSection membershipParentSection = (MembershipSection)parentConfig.GetSection("system.web/membership");
    RoleManagerSection roleManagerParentSection = (RoleManagerSection)parentConfig.GetSection("system.web/roleManager");

    ArrayList providersArray = new ArrayList();
    ArrayList groupedProvidersFiltered = new ArrayList();

    ProviderSettingsCollection membershipProviders = membershipSection.Providers;
    ProviderSettingsCollection roleManagerProviders = roleManagerSection.Providers;
    
    ProviderSettingsCollection membershipParentProviders = membershipParentSection.Providers;
    ProviderSettingsCollection roleManagerParentProviders = roleManagerParentSection.Providers;

    ConnectionStringsSection connectionStringSection = (ConnectionStringsSection)config.GetSection("connectionStrings");
    
    // loop thru the membershipProviders and see if our grouped entries are in there
    // if so, then grab the connection string, it must be the same for the role provider as well
    foreach (System.Configuration.ProviderSettings mps in membershipProviders) {
        string name = mps.Name;
        string connectionString = mps.Parameters["connectionStringName"];
        
        foreach(GroupedProperty oneGroupedProvider in GroupedProvidersList) {
            if (name == oneGroupedProvider.MembershipProvider) {
            
                // check if the roleprovider exists with the identical connection string
                if (HasProviderInProviderSettings(roleManagerProviders, oneGroupedProvider.RoleProvider, connectionString)) {
                    groupedProvidersFiltered.Add(oneGroupedProvider);
                    
                    string tempDescription = oneGroupedProvider.Description;
                    
                    // use the type from the membership provider for the test link...
                    providersArray.Add(new ProviderListUserControl.ProviderListItems(oneGroupedProvider.Name, tempDescription, connectionString, mps.Type, true));
                }
            }
        }
    }

    foreach (System.Configuration.ProviderSettings mps in membershipProviders) {
        string name = mps.Name;
        string connectionString = mps.Parameters["connectionStringName"];
        
        if (HasProviderInProviderSettings(roleManagerProviders, name, connectionString)) {
        
            // Check if the same provider shows up in the parent config.
            if (HasProviderInProviderSettings(membershipParentProviders, name, connectionString) &&
                HasProviderInProviderSettings(roleManagerParentProviders, name, connectionString)) {
                _parentProviderCount++;
            }
            
            providersArray.Add(new ProviderListUserControl.ProviderListItems(mps.Name, mps.Parameters["description"], mps.Parameters["connectionStringName"], mps.Type, false));
        }
    }

    providerList.DataSource = providersArray;

    providerList.ParentProviderCount = _parentProviderCount;
    string defaultMembershipProvider = membershipSection.DefaultProvider;
    string defaultRoleProvider = roleManagerSection.DefaultProvider;
    
    if (defaultMembershipProvider == defaultRoleProvider) {
        for (int i = 0; i < providersArray.Count; i++) {
            if (((ProviderListUserControl.ProviderListItems) providersArray[i]).ProviderName == defaultMembershipProvider) {
                providerList.SelectedIndex = i;
            }
        }
        Session["DefaultProvider"] = defaultMembershipProvider;
    } else {
        // check if they are part of a group and select that group
        string groupProviderName = String.Empty;
        foreach (GroupedProperty oneGroupedProvider in groupedProvidersFiltered) {
            if (oneGroupedProvider.MembershipProvider == defaultMembershipProvider) {
                if (oneGroupedProvider.RoleProvider == defaultRoleProvider) {
                    groupProviderName = oneGroupedProvider.Name;
                    
                    for (int i = 0; i < providersArray.Count; i++) {
                        if (((ProviderListUserControl.ProviderListItems) providersArray[i]).ProviderName == groupProviderName) {
                            providerList.SelectedIndex = i;
                        }
                    }
                    Session["DefaultProvider"] = groupProviderName;
                }
            }
        }
    }
    
    providerList.DataBind();
}

private void BindProviderLists() {
    BindProviderList(ProviderList);
}

private bool HasProviderInProviderSettings(ProviderSettingsCollection providerSettings, string name, string connectionString) {
    bool found = false;
    foreach (System.Configuration.ProviderSettings ps in providerSettings) {
        if (ps.Name == name && ps.Parameters["connectionStringName"] == connectionString) {
            found = true;
            break;
        }
    }
    return found;
}

private void Page_Load() {
    if (!IsPostBack) {
        BindProviderLists();
    }
}

private void SelectProvider(object sender, ProviderListUserControl.ProviderEventArgs e) {
    RadioButton radioButton = (RadioButton) sender;
    Configuration config = OpenWebConfiguration(ApplicationPath);

    MembershipSection membershipSection = (MembershipSection)config.GetSection("system.web/membership");
    RoleManagerSection roleManagerSection = (RoleManagerSection)config.GetSection("system.web/roleManager");

    if (e.IsGroup) {
        // lookup the group and set the appropriate providers.
        foreach(GroupedProperty oneGroupedProvider in GroupedProvidersList) {
            if (e.ProviderName == oneGroupedProvider.Name) {
                if (oneGroupedProvider.MembershipProvider != null) {
                    membershipSection.DefaultProvider = oneGroupedProvider.MembershipProvider;
                } else {
                    membershipSection.DefaultProvider = null;
                }
                if (oneGroupedProvider.RoleProvider != null) {
                    roleManagerSection.DefaultProvider = oneGroupedProvider.RoleProvider;
                } else  {
                    roleManagerSection.DefaultProvider = null;
                }
            }
        }
    }
    else {
        membershipSection.DefaultProvider = e.ProviderName;
        roleManagerSection.DefaultProvider = e.ProviderName;
    }

    SaveConfig(config);
    BindProviderLists();
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
    <table height="10" width="100%" cellspacing="0" cellpadding="0" valign="top" align="left">
        <tr class="bodyTextNoPadding" height="1%">
            <td>
                <asp:literal runat="server" text="<%$ Resources:Instructions %>"/>
            </td>
        </tr>
        <tr><td>&nbsp</td></tr>
        <tr height="1%">
            <td>
                <uc:ProviderList runat="server" id="ProviderList"
                                 HeaderText="<%$ Resources:Provider %>"
                                 ServiceName="all"
                                 OnSelectProvider="SelectProvider"
                                 OnTestConnection="TestConnection"/>
            </td>
        </tr>
    </table>
</asp:content>

<asp:content runat="server" contentplaceholderid="buttons">
    <asp:button ValidationGroup="none" text="<%$ Resources:GlobalResources,BackButtonLabel %>" id="BackButton" onclick="BackToPreviousPage" runat="server"/>
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
                <asp:literal runat="server" id="areYouSureLiteral"/>
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
    <asp:Button runat="server" id="OKButton" enableViewState="false" OnClick="OK_Click" Text="<%$ Resources:OK %>" visible="false" width="75"/>
</asp:content>
