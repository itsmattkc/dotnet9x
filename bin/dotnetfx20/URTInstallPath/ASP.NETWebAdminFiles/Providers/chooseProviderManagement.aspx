<%@ Page masterPageFile="~/WebAdmin.master" inherits="System.Web.Administration.ProvidersPage" debug="true"%>
<%@ MasterType virtualPath="~/WebAdmin.master" %>
<%@ Import Namespace="System.Web.Configuration" %>

<script runat="server" language="cs">
public void Page_Load() {
    System.Configuration.Configuration config = OpenWebConfiguration(ApplicationPath);
    MembershipSection membershipSection = (MembershipSection)config.GetSection("system.web/membership");
    RoleManagerSection roleManagerSection = (RoleManagerSection)config.GetSection("system.web/roleManager");
    ConnectionStringsSection connectionStringSection = (ConnectionStringsSection)config.GetSection("connectionStrings");

    string defaultProvider = membershipSection.DefaultProvider;
    string connectionStringName = membershipSection.Providers[defaultProvider].Parameters["connectionStringName"];
    bool updateText = false;
    if (defaultProvider == roleManagerSection.DefaultProvider &&
        connectionStringName == roleManagerSection.Providers[defaultProvider].Parameters["connectionStringName"]) {
        updateText = true;
    }

    // check if providers are part of the same group.
    if (!updateText) {
        foreach(GroupedProperty oneGroupedProvider in GroupedProvidersList) {
            if (membershipSection.DefaultProvider == oneGroupedProvider.MembershipProvider) {
                if (roleManagerSection.DefaultProvider == oneGroupedProvider.RoleProvider) {
                    defaultProvider = oneGroupedProvider.Name;
                    updateText = true;
                }
            }
        }
    }

    if (updateText) {
        providerLiteral.Text = String.Format((string)GetLocalResourceObject("CurrentProvider"), defaultProvider);
    }
}
</script>

<%-- Main Content --%>
<asp:content runat="server" contentplaceholderid="titleBar">
    <asp:literal runat="server" text="<%$ Resources:ConfigureProviders %>"/>
</asp:content>

<asp:content runat="server" contentplaceholderid="content">
<asp:literal runat="server" text="<%$ Resources:Instructions %>"/>
<br/><br/>
<asp:literal runat=server id=providerLiteral/>
<asp:HyperLink id="hook" runat="server" NavigateUrl="~/Providers/ManageConsolidatedProviders.aspx" text="<%$ Resources:SelectSame %>"/>
<br/>
<asp:HyperLink runat="server" NavigateUrl="~/Providers/ManageProviders.aspx" text="<%$ Resources:SelectDifferent%>" />
</asp:content>


