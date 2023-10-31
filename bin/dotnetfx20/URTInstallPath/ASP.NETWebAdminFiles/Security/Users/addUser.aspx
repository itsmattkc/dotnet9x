<%@ Page masterPageFile="~/WebAdminWithConfirmation.master" debug="true" inherits="System.Web.Administration.SecurityPage"%>
<%@ Import Namespace="System.Web.Administration" %>
<%@ Import Namespace="System.Web.Mail" %>
<%@ Import Namespace="System.Web.Configuration" %>
<%@ Register TagPrefix="admin" Namespace="System.Web.Administration" Assembly="System.Web" %>

<script runat="server" language="cs">

public void CreatedUser(object sender, EventArgs e) {
    activeUser.Visible = false;
    panel1.Enabled = false; 
    addUserInstructions.Visible = false;
    UpdateRoleMembership(createUser.UserName);
}

public void CreatingUser(object sender, EventArgs e) {
    createUser.DisableCreatedUser = !activeUser.Checked;
}

public void Page_Load() {
    if (!IsPostBack) {
        PopulateCheckboxes();
    }
}

private void PopulateCheckboxes() {
    if (IsRoleManagerEnabled()) {
        checkBoxRepeater.DataSource = (string[])CallWebAdminHelperMethod(false, "GetAllRoles", new object[] {}, null);
        checkBoxRepeater.DataBind();
        if (checkBoxRepeater.Items.Count > 0) {
            selectRolesLabel.Text = (string) GetLocalResourceObject("SelectRoles");
        }
        else {
            selectRolesLabel.Text = (string) GetLocalResourceObject("NoRolesDefined");
        }
    }
    else {
        selectRolesLabel.Text = (string) GetLocalResourceObject("RolesNotEnabled");
    }
}

private void SendingPasswordMail(object sender, MailMessageEventArgs e) {
    e.Cancel = true;
}

private void UpdateRoleMembership(string u) {
    if (String.IsNullOrEmpty(u)) {
        return;
    }
    foreach(RepeaterItem i in checkBoxRepeater.Items) {
        CheckBox c = (CheckBox)i.FindControl("checkbox1");
        UpdateRoleMembership(u, c);
    }
}

private void UpdateRoleMembership(string u, CheckBox box) {
    // Array manipulation because cannot use Roles static method (need different appPath).
    string role = box.Text;

    if (box.Checked && !(bool)CallWebAdminHelperMethod(false, "IsUserInRole", new object[] {u, role}, new Type[] {typeof(string),typeof(string)})) {
        CallWebAdminHelperMethod(false, "AddUsersToRoles",new object[] {new string[]{u}, new string[]{role}}, new Type[] {typeof(string[]),typeof(string[])});
    }
    else if (!box.Checked && (bool)CallWebAdminHelperMethod(false, "IsUserInRole", new object[] {u, role}, new Type[] {typeof(string),typeof(string)})) {
        CallWebAdminHelperMethod(false, "RemoveUsersFromRoles",new object[] {new string[]{u}, new string[]{role}}, new Type[] {typeof(string[]),typeof(string[])});
    }
}


</script>

<asp:content runat="server" contentplaceholderid="buttons">
<asp:button ValidationGroup="none" text="<%$ Resources:Back %>" id="doneButton" onclick="ReturnToPreviousPage" runat="server"/>
</asp:content>

<asp:content runat="server" contentplaceholderid="titleBar">
<asp:literal runat="server" text="<%$ Resources:CreateUser %>"/>
</asp:content>

<asp:content runat="server" contentplaceholderid="content">

<div style="width:750">
<asp:literal runat="server" id="addUserInstructions" text="<%$ Resources:Instructions %>"/>
</div>
<br/>
<table>
<tr>
<td>
    <table cellspacing="0" cellpadding="5" class="lrbBorders">
    <tr>
        <td class="callOutStyle"><asp:literal runat="server" text="<%$ Resources:CreateUser %>"/></td>
    </tr>
    <tr >
        <td>
            <asp:createUserWizard runat=server id=createUser displayCancelButton="false"
                class="bodyText" createUserTitleText="" continueDestinationPageUrl="~/security/users/addUser.aspx"
                emailLabelText="<%$ Resources:EmailLabel %>" emailRegularExpression="\S+@\S+\.\S+"
                oncancelclick="ReturnToPreviousPage" oncreateduser="CreatedUser" oncreatinguser="CreatingUser"
                onSendingMail="SendingPasswordMail" MembershipProvider="WebAdminMembershipProvider" />
        </td>
    </tr>
</table>

    </td><td height="100%">
            <table  borderwidth="1px" cellpadding="0" cellspacing="0" height="100%" width="100%">
                <tr class="callOutStyleLowLeftPadding" height="1">
                    <td valign="top"><asp:literal runat="server" text="<%$ Resources:Roles %>"/></td>
                </tr>
                <tr valign="top" height="100%">
                    <td  class="userDetailsWithFontSize" height="100%">
                        <asp:panel runat="server" id="panel1" scrollbars="auto" valign="top">
                        <asp:label runat="server" id="selectRolesLabel" text="<%$ Resources:SelectRoles %>"/>
                        <br/>
                        <asp:repeater runat="server" id="checkBoxRepeater">
                        <itemtemplate>
                        <asp:checkbox runat="server" id="checkBox1" text='<%# Container.DataItem.ToString()%>' />
                        <br/>
                        </itemtemplate>
                        </asp:repeater>
                        </asp:panel>
                    </td>
                </tr>
            </table>    
    </td>
    </tr>
</table>

<asp:checkbox runat="server" id="activeUser" checked="true" text="<%$ Resources:ActiveUser %>"/>
</asp:content>
