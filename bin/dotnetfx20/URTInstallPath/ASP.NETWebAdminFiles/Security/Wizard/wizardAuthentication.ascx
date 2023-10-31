<%@ Control Inherits="System.Web.Administration.WebAdminUserControl" %>

<%@ Import Namespace="System.Web.Administration" %>
<%@ Import Namespace="System.Web.Configuration" %>

<script runat="server" language="cs">
public void Page_Load() {
    if (!IsPostBack) {
        Configuration config = ((WebAdminPage)Page).OpenWebConfiguration((string)Session["WebAdminApplicationPath"]);
        AuthenticationSection auth = (AuthenticationSection) config.GetSection("system.web/authentication");
        fromInternet.Checked = auth.Mode == AuthenticationMode.Forms;
        fromNetwork.Checked = auth.Mode == AuthenticationMode.Windows;
    }
}

public void UpdateAuth(object sender, EventArgs e) {
    Configuration config = ((WebAdminPage)Page).OpenWebConfiguration((string)Session["WebAdminApplicationPath"]);
    AuthenticationSection auth = (AuthenticationSection) config.GetSection("system.web/authentication");
    auth.Mode = fromInternet.Checked ? AuthenticationMode.Forms : AuthenticationMode.Windows;
    ((WebAdminPage)Page).SaveConfig(config);
}

public override bool OnNext() {
    UpdateAuth(null, null);
    return true;
}

</script>
<table border="0" cellpadding="0" cellspacing="0" width="62%" >
<tr><td class="bodyTextLeftPadding5">
<b><asp:literal runat="server" text="<%$ Resources:SelectAccess %>"/></b><br/><br/>
<asp:literal runat="server" text="<%$ Resources:SelectAccessInstructions %>"/>
</td></tr></table>
<br/>
<table border="0" cellpadding="0" cellspacing="0" width="62%" >
    <tr>
        <td align="left"><asp:radioButton runat="server" id="fromInternet" groupName="auth" checked="true" onCheckedChanged="UpdateAuth"/></td>
        <td class="bodyTextLeftPadding">
            <asp:label runat="server" associatedcontrolid="fromInternet" font-bold="true" text="<%$ Resources:FromInternet %>"/>
        </td>
    </tr>
    <tr>
        <td>
        </td>
        <td class="bodyTextLeftPadding">
        <asp:literal runat="server" text="<%$ Resources:FromInternetInstructions %>"/>
        </td>
    </tr><tr><td colspan="2"><br/></td></tr>
    <tr>
        <td><asp:radioButton runat="server" id="fromNetwork" type="radio" groupName="auth" onCheckedChanged="UpdateAuth"/></td>
        <td class="bodyTextLeftPadding">
            <asp:label runat="server" associatedcontrolid="fromNetwork" font-bold="true" text="<%$ Resources:FromLocalNet %>"/>
        </td>
    </tr>
    <tr>
        <td>
        </td>
        <td class="bodyTextLeftPadding">
            <asp:literal runat="server" text="<%$ Resources:FromLocalNetInstructions %>"/>
        </td>
    </tr>
</table>



