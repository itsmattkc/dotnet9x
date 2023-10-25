<%@ Control Inherits="System.Web.Administration.WebAdminUserControl" %>
<%@ Import Namespace="System.Web.Administration" %>
<%@ Import Namespace="System.Web.Mail" %>
<%@ Register TagPrefix="admin" Namespace="System.Web.Administration" Assembly="System.Web" %>

<script runat="server" language="cs">

public void ContinueClick(object sender, EventArgs e) {
    ((WizardPage)Page).SaveActiveView();
}

public void CreatedUser(object sender, EventArgs e) {
    activeUser.Visible = false;
}

public void CreatingUser(object sender, EventArgs e) {
    createUser.DisableCreatedUser = !activeUser.Checked;
}

public void SendPasswordChanged(object sender, MailMessageEventArgs e) {
    e.Cancel = true;
}
</script>

<div class="bodyTextNoPadding" style="width:500">
<asp:literal runat="server" text="<%$ Resources:AddUserInstructions %>"/>
<br/><br/>
<table cellspacing="0" cellpadding="5" class="lrbBorders">
    <tr>
        <td class="callOutStyle"><asp:literal runat="server" text="<%$ Resources:CreateUser %>"/></td>
    </tr>
    <tr >
        <td>
             <asp:createUserWizard runat=server id=createUser class="bodyText" createUserTitleText="" continueDestinationPageUrl="~/security/wizard/wizard.aspx" emailLabelText="<%$ Resources:EmailLabel %>" displayCancelButton="false" emailRegularExpression="\S+@\S+\.\S+" oncontinuebuttonclick="ContinueClick" oncreateduser="CreatedUser" oncreatinguser="CreatingUser" MembershipProvider="WebAdminMembershipProvider" >
             </asp:createuserwizard>
        </td>
    </tr>
</table>
<asp:checkbox runat="server" id="activeUser" checked="true" text="<%$ Resources:ActiveUser %>"/>
</div>
