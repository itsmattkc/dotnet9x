<%@ Page MasterPageFile="WebAdminNoButtonRow.master" inherits="System.Web.Administration.WebAdminPage"%>
<%@ MasterType virtualPath="~/WebAdminNoButtonRow.master" %>
<%@ Import Namespace="System.Web.Configuration"%>
<%@ Import Namespace="System.Web.Hosting"%>
<%@ Import Namespace="System.Security" %> 
<%@ Import Namespace="System.Security.Principal" %> 
<%@ Import Namespace="System.Web.Administration" %>
<%@ Import Namespace="System.Web.Management" %>
<%@ Reference virtualPath="WebAdminNoButtonRow.master" %>

<script runat="server" language="cs">
protected override bool CanSetApplicationPath {
    get {
        return true;
    }
}

protected override void OnInit(EventArgs e) {
    Master.SetNavigationBarSelectedIndex(0);
    try {
        SetApplicationPath();
    }
    catch {
        Response.Redirect("~/error.aspx");
    }
    base.OnInit(e);
}

public void Page_Load() {
    string id = Page.User.Identity.Name;
    if (id != null && !id.Equals(String.Empty)) {
        user.Text = String.Format((string)GetLocalResourceObject("CurrentUserName"), id.ToUpper()); 
    }

    string appPath = ApplicationPath;   
    if (appPath != null && !appPath.Equals(String.Empty)) {
        application.Text = String.Format((string)GetLocalResourceObject("Application"), appPath); 
    }
    if (IsWindowsAuth()) {
        existingUsersLiteral.Text = (string)GetLocalResourceObject("WindowsAuth");
    }
    else {
        try {
            int total = 0;
            MembershipUserCollection users = (MembershipUserCollection) CallWebAdminHelperMethod(true, "GetAllUsers",new object[] {0, Int32.MaxValue, total}, new Type[] {typeof(int),typeof(int),Type.GetType("System.Int32&")});
            existingUsersLiteral.Text = String.Format((string)GetLocalResourceObject("ExistingUsers"), users.Count.ToString()); 
        }
        catch {
            // Can happen, for example, if access is the default provider, but it is not available.
            existingUsersLiteral.Visible = false;
        }
    }
}

</script>
<asp:content runat="server" contentplaceholderid="titleBar">
 <asp:literal runat="server" text="<%$ Resources: Home %>"/>
</asp:content>
<asp:content runat="server" contentplaceholderid="content">
<table width="100%" height="100%" >
    <tr>
        <td width="62%" valign="top" class="bodyTextNoPadding" style="padding-left:0;">
            <div style="font-size:1.5em; font-weight:bold" nowrap>
                <asp:label runat="server" id="welcome" text="<%$ Resources:Welcome %>"/>
            </div>
            <br/>
            <asp:literal runat="server" id="application"/>
            <br/>
            <asp:literal runat="server" id="user"/>
            <br/>
            <br/>

            <table cellspacing="0" cellpadding="0" rules="none" onrowcommand="LinkButtonClick" class="allBorders" border="0">
                <tr class="gridAlternatingRowStyle8" >
                    <td >
                        <a id="hook" href="security/security.aspx"><asp:literal runat="server" text="<%$ Resources:Security %>"/></a>
                    </td><td>
                        <asp:literal runat="server" text="<%$ Resources: EnablesSecurity %>"/>
                        <br/>
                        <asp:literal runat="server" id="existingUsersLiteral"/>
                    </td>
                </tr>
                <tr class="gridRowStyle8" >
                    <td >
                        <a id="AppConfigHomeLink" href="appConfig/AppConfigHome.aspx"><asp:literal runat="server" text="<%$ Resources:AppConfig %>"/></a>
                    </td><td>
                        <asp:literal runat="server" text="<%$ Resources: EnablesConfig %>"/>                    
                    </td>
                </tr><tr class="gridAlternatingRowStyle8">
                       <td>
                        <a id="ProviderLink" href="providers/chooseProviderManagement.aspx"><asp:literal runat="server" text="<%$ Resources:ProviderConfig %>"/></a>
                    </td><td>
                     <asp:literal runat="server" text="<%$ Resources: EnablesData %>"/>                                           
                    </td>
                </tr>    
            </table>
    </tr>
</table>
</asp:content>

