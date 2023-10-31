<%@ Page masterPageFile="~/WebAdmin.master" inherits="System.Web.Administration.SecurityPage"%>
<%@ Import Namespace="System.Web.Administration" %>
<%@ Import Namespace="System.Web.Configuration" %>

<script runat="server" language="cs">
private void BackToPreviousPage(object sender, EventArgs e) {
    ReturnToPreviousPage(sender, e);
}

protected void DisableRoleManager() {
    Configuration config = OpenWebConfiguration(ApplicationPath);
    RoleManagerSection roleSection = (RoleManagerSection)config.GetSection("system.web/roleManager");
    roleSection.Enabled = false;
    SaveConfig(config);
}

protected void EnableRoleManager() {
    Configuration config = OpenWebConfiguration(ApplicationPath);
    RoleManagerSection roleSection = (RoleManagerSection)config.GetSection("system.web/roleManager");
    roleSection.Enabled = true;
    SaveConfig(config);
}


public void Page_Init() {
    if (IsWindowsAuth()) {
        userManagementDisabler.ActiveViewIndex = 1;
    }
    string appPath = ApplicationPath;
    if (appPath != null && appPath.Length > 0) {
        application.Text = String.Format((string)GetLocalResourceObject("SecurityManagementForSite"), appPath);
    }
}

public void Page_Load() {
    if (!IsPostBack) {
        CurrentUser = null;

        try {
            Configuration config = OpenWebConfiguration(ApplicationPath);
            // this call is only to detect the validity of the config setting
            RoleManagerSection roleSection = (RoleManagerSection)config.GetSection("system.web/roleManager");
            bool temp = roleSection.Enabled;
        }
        catch (Exception e){
            SetCurrentException(Context, e);
            // do not prepend ~/ to this path, since its not at the root
            Response.Redirect("security0.aspx");
        }

        UpdateProviderUI();
    }
}

private void ToggleRoles(object sender, EventArgs e) {
    if(IsRoleManagerEnabled()) {
        DisableRoleManager();
    }
    else {
        EnableRoleManager();
    }
    UpdateProviderUI();
}



private void UpdateProviderUI() {
    try {
        int total = 0;
        MembershipUserCollection users = (MembershipUserCollection) CallWebAdminHelperMethod(true, "GetAllUsers",new object[] {0, Int32.MaxValue, total}, new Type[] {typeof(int),typeof(int),Type.GetType("System.Int32&")});
        string[] roles = null;
        try {
            roles = (string[])CallWebAdminHelperMethod(false, "GetAllRoles", new object[] {}, null);
        } catch {
            // will throw if roles not enabled
        }

        userCount.Text = users.Count.ToString();
        if (IsRoleManagerEnabled()) {
            if (roles != null) {
                roleCount.Text = roles.Length.ToString();
            }
            else {
                roleCount.Text = "0";
            }
            roleCount.Visible = true;
            roleMessage.Text = (string)GetLocalResourceObject("ExistingRoles"); 
            waLink5.Visible = true;
            waLabel5.Visible = false;
            toggleRoles.Text = (string)GetLocalResourceObject("DisableRoles");
        }
        else {
            roleCount.Visible = false;
            roleMessage.Text = (string)GetLocalResourceObject("RolesNotEnabled");
            // Cannot disable a hyperlink, so "replace" it with a label.
            waLink5.Visible = false;
            waLabel5.Visible = true;
            toggleRoles.Text = (string)GetLocalResourceObject("EnableRoles"); 
        }
    }
    catch (Exception e){
        SetCurrentException(Context, e);
        // do not prepend ~/ to this path, since its not at the root
        Response.Redirect("security0.aspx"); // States that there is a problem with the selected data store and redirects to chooseProvider.aspx
    }
}


</script>

<%-- Main Content --%>
<asp:content runat="server" contentplaceholderid="titleBar">
<asp:literal runat="server" id="application" text="<%$ Resources: SecurityManagement %>"/>
</asp:content>

<asp:content runat="server" contentplaceholderid="content">
    <table id="hook" height="100%" width="100%">
        <tr>
            <td width="600" valign="top">
                <table width="100%" valign="top">
                    <tr>
                        <td class="bodyTextNoPadding" colspan="3">
                            <asp:literal runat="server" text="<%$ Resources: Explanation %>"/>
                            <br/><br/>
                             <asp:hyperlink runat=server id="linkhook" navigateUrl="~/security/wizard/wizard.aspx" text="<%$ Resources:SecurityLink %>"/>
                            <br/><br/>
                            <asp:literal runat="server" text="<%$ Resources: ClickLinksInstruction %>"/>
                        </td>
                    </tr>
                    <tr>
                        <td width="33%" height="100%">
                            <table cellspacing="0" height="100%" width="100%" cellpadding="4" rules="all" bordercolor="#CCDDEF" border="1" style="border-color:#CCDDEF;border-style:None;border-collapse:collapse;">
                                <tr class="callOutStyle">
                                    <td><asp:literal runat="server" text="<%$ Resources: Users %>"/></td>
                                </tr>
                                <tr class="bodyText" height="100%" valign="top">
                                    <td>
                                    <asp:multiview runat="server" id="userManagementDisabler" activeViewIndex="0">
                                    <asp:view runat="server">
                                        
                                        <asp:literal runat="server" text="<%$ Resources: ExistingUsers %>"/> <asp:label runat="server" id="userCount" font-bold="true" text="0"/><br/>
                                        <asp:hyperlink runat="server" id="waLink3" navigateUrl="~/security/users/addUser.aspx" text="<%$ Resources:CreateUser %>"/><br/>
                                        <asp:hyperlink runat="server" id="waLink4" navigateUrl="~/security/users/manageUsers.aspx" text="<%$ Resources:ManageUsers %>"/><br/>
                                        </asp:view>
                                        <asp:view runat="server">
                                        <asp:literal runat="server" text="<%$ Resources: WindowsAuthExplanation %>"/>
                                        </asp:view>
                                        </asp:multiview>
                                        <br/>
                                        <asp:hyperlink runat="server" navigateUrl="~/security/setUpAuthentication.aspx" text="<%$ Resources:SelectAuth %>"/>
                                        </td>
                                </tr>
                            </table>
                        </td>
                        <td width="33%" height="100%">
                            <table cellspacing="0" height="100%" width="100%" cellpadding="4" rules="all" bordercolor="#CCDDEF" border="1" style="border-color:#CCDDEF;border-style:None;border-collapse:collapse;">
                                <tr class="callOutStyle">
                                    <td><asp:Literal runat="server" Text="<% $ Resources: Roles%>" /></td>
                                </tr>
                                <tr class="bodyText" height="100%" valign="top">
                                    <td>
                                        <asp:label runat="server" id="roleMessage" text="<%$ Resources: ExistingRoles%>"/>
                                        <asp:label runat="server" id="roleCount" font-bold="true" text="0"/>
                                        <br/>
                                        <asp:linkButton runat="server" id="toggleRoles" onclick="ToggleRoles" text="Enable roles"/><br/>
                                        <asp:label runat="server" id="waLabel5" enabled="false" text="<%$ Resources:CreateOrManageRoles %>"/>
                                        <asp:hyperlink runat="server" id="waLink5" navigateUrl="~/security/roles/manageAllRoles.aspx" text="<%$ Resources:CreateOrManageRoles %>"/><br/>
                                    </td>
                                </tr>
                            </table>
                        </td>
                        <td width="33%" height="100%">
                            <table cellspacing="0" height="100%" width="100%" cellpadding="4" rules="all" bordercolor="#CCDDEF" border="1" style="border-color:#CCDDEF;border-style:None;border-collapse:collapse;">
                                <tr class="callOutStyle">
                                    <td><asp:Literal runat="server" Text="<% $ Resources: AccessRules%>" /></td>
                                </tr>
                                <tr class="bodyText" height="100%" valign="top">
                                    <td>
                                        <asp:hyperlink runat="server" id="waLink7" navigateUrl="~/security/permissions/createPermission.aspx" text="<%$ Resources:CreateAccessRules %>"/>
                                        <asp:label runat="server" id="waLabel7" enabled="false" visible="false" text="<%$ Resources:CreateAccessRules %>"/><br/>
                                        <asp:hyperlink runat="server" id="waLink8" navigateUrl="~/security/permissions/managePermissions.aspx" text="<%$ Resources:ManageAccessRules %>"/>
                                        <asp:label runat="server" id="waLabel8" enabled="false" visible="false" text="<%$ Resources:ManageAccessRules%>"/><br/>
                                        
                                    </td>
                                </tr>
                            </table>
                        </td>
                    </tr>
                </table>
            </td>
        </tr>
    </table>
</asp:content>


