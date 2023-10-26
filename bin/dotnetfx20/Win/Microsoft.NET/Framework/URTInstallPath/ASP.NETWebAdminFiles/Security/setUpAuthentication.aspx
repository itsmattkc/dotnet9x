<%@ Page masterPageFile="~/WebAdminButtonRow.master" trace="false" inherits="System.Web.Administration.SecurityPage"%>
<%@ Import Namespace="System.Web.Configuration" %>

<script runat="server" language="cs">
public void Page_Load() {
    if (!IsPostBack) {
        Configuration config = OpenWebConfiguration(ApplicationPath);
        AuthenticationSection auth = (AuthenticationSection) config.GetSection("system.web/authentication");
        if (auth.Mode == AuthenticationMode.Windows) {
            fromInternet.Checked = false;
            fromNetwork.Checked = true;
        }
    }
}

public void UpdateAndReturnToPreviousPage(object sender, EventArgs e) {
    Configuration config = OpenWebConfiguration(ApplicationPath);
    AuthenticationSection auth = (AuthenticationSection) config.GetSection("system.web/authentication");
    auth.Mode = fromInternet.Checked ? AuthenticationMode.Forms : AuthenticationMode.Windows;
    SaveConfig(config);
    Response.Write(auth.Mode);
    ReturnToPreviousPage(sender, e);
}

</script>
<asp:content runat="server" contentplaceholderid="titleBar"/>

<asp:content runat="server" contentplaceholderid="buttons">
    <asp:button ValidationGroup="none" runat="server" id="button1" text="<%$ Resources:DoneButton %>" onclick="UpdateAndReturnToPreviousPage"/>
</asp:content>

<asp:content runat="server" contentplaceholderid="content">
<asp:literal runat="server" text="<%$ Resources: HowWillUsersAccess %>"/>
<br/>
<br/>
<table width="62%">
    <tr>
        <td><asp:radioButton runat="server" id="fromInternet" groupName="auth" checked="true" /></td>
        <td class="bodyTextNoPadding">
            <asp:label runat="server" associatedcontrolid="fromInternet" font-bold="true" text="<%$ Resources:FromInternet %>"/>
        </td>
    </tr>
    <tr>
        <td>
        </td>
        <td class="bodyTextNoPadding">
        <asp:literal runat="server" text="<%$ Resources: InternetExplanation %>"/>        
        </td>
    </tr>
    <tr>
        <td><asp:radioButton runat="server" id="fromNetwork" type="radio" groupName="auth"/></td>
        <td class="bodyTextNoPadding">
            <asp:label runat="server" associatedcontrolid="fromNetwork" font-bold="true" text="<%$ Resources:FromNetwork %>"></asp:label>
        </td>
    </tr>
    <tr>
        <td>
        </td>
        <td class="bodyTextNoPadding">
        <asp:literal runat="server" text="<%$ Resources: NetworkExplanation %>"/>        
        </td>
    </tr>
</table>
</asp:content>

