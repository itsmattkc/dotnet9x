<%@ Control Inherits="System.Web.Administration.WebAdminUserControl" %>
<%@ Import Namespace="System.Web.Administration" %>
<%@ Import Namespace="System.Web.Configuration" %>


<script runat="server" language="cs">
private string ApplicationPath {
    get {
        return (string)Session["WebAdminApplicationPath"];
    }
}

public void Page_Load() {
    System.Configuration.Configuration config = ((WebAdminPage)Page).OpenWebConfiguration(ApplicationPath);
    MembershipSection membershipSection = (MembershipSection)config.GetSection("system.web/membership");
    RoleManagerSection roleManagerSection = (RoleManagerSection)config.GetSection("system.web/roleManager");
    ConnectionStringsSection connectionStringSection = (ConnectionStringsSection)config.GetSection("connectionStrings");

    string defaultProvider = membershipSection.DefaultProvider;
    string connectionStringName = membershipSection.Providers[defaultProvider].Parameters["connectionStringName"];
    if (defaultProvider == roleManagerSection.DefaultProvider &&
        connectionStringName == roleManagerSection.Providers[defaultProvider].Parameters["connectionStringName"]) {
        label1.Text = defaultProvider;
    }
    else {
        label1.Text = (string)GetLocalResourceObject("AdvancedSettings"); 
    }

}
</script>

<table border="0" cellpadding="0" cellspacing="0" width="100%" >
<tr><td class="bodyTextLeftPadding5">
<asp:literal runat="server" text="<%$ Resources:CurrentlyConfigured %>" />
<br/><br/>

<asp:label runat="server" id="label1" font-bold="true" text="Unknown"/>

<br/><br/>
<asp:literal runat="server" text="<%$ Resources:ChangeInstructions %>"/>
</td></tr></table>
