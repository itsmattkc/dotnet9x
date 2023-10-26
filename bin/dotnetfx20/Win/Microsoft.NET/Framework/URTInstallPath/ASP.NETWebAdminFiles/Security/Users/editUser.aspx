<%@ Page masterPageFile="~/WebAdminWithConfirmation.master" debug="true" inherits="System.Web.Administration.SecurityPage"%>
<%@ MasterType virtualPath="~/WebAdminWithConfirmation.master" %>
<%@ Import Namespace="System.Web.Administration" %>
<%@ Import Namespace="System.Web.Mail" %>
<%@ Import Namespace="System.Web.Configuration" %>


<script runat="server" language="cs">
private Exception currentRequestException;

private void AddAnother_Click(object sender, EventArgs e) {
    ResetUI();
    Master.SetDisplayUI(false);
}

public void Cancel(object sender, EventArgs e) {
    ClearTextBoxes();    
}

private void ClearTextBoxes() {
    UserID.Text = String.Empty;
    UserID.Enabled = true;
    Email.Text = String.Empty;
    Description.Text = String.Empty;
}

private void OK_Click(object sender, EventArgs e) {
    ReturnToPreviousPage(sender, e);
}

public void Page_Load() {
    string userName = CurrentUser;
    if (!IsPostBack) {
        PopulateCheckboxes();
        UserID.Text = userName;
        UserID.Enabled = false;

        MembershipUser mu = (MembershipUser) CallWebAdminHelperMethod(true, "GetUser", new object[] {userName, false /* isOnline */}, new Type[] {typeof(string),typeof(bool)});
        if (mu == null) {
            return; // Review: scenarios where this happens.
        }
        Email.Text = mu.Email;
        ActiveUser.Checked = mu.IsApproved;
        string comment = mu.Comment;
        string notSet = (string)GetLocalResourceObject("NotSet");
        Description.Text = comment == null || comment == string.Empty ? notSet : mu.Comment;        
    }
}

private void PopulateCheckboxes() {
    if (IsRoleManagerEnabled()) {
        CheckBoxRepeater.DataSource = (string[]) CallWebAdminHelperMethod(false, "GetAllRoles", new object[] {}, null);
        CheckBoxRepeater.DataBind();
        if (CheckBoxRepeater.Items.Count > 0) {
            SelectRolesLabel.Text = (string)GetLocalResourceObject("SelectRoles");
        }
        else {
            SelectRolesLabel.Text = (string)GetLocalResourceObject("NoRolesDefined");
        }
    }
    else {
        SelectRolesLabel.Text = (string)GetLocalResourceObject("RolesNotEnabled");
    }
}

public void ResetUI() {
    ClearTextBoxes();
}

private void ServerCustomValidate(object sender, ServerValidateEventArgs e) {
    if (currentRequestException == null) {
        e.IsValid = true;
        return;
    }
    CustomValidator v = (CustomValidator) sender;
    v.ErrorMessage = currentRequestException.Message;
    e.IsValid = false;
}

public void SaveClick(object sender, EventArgs e) {
   UpdateUser(sender, e);
}

private void UpdateRoleMembership(string u) {
    if (u == null || u.Equals(String.Empty)) {
        return;
    }
    foreach(RepeaterItem i in CheckBoxRepeater.Items) {
        CheckBox c = (CheckBox)i.FindControl("checkbox1");
        UpdateRoleMembership(u, c);
    }
    // Clear the checkboxes
    CurrentUser = null;
    PopulateCheckboxes();
}

private void UpdateRoleMembership(string u, CheckBox box) {
    // Array manipulation because cannot use Roles static method (need different appPath).
    string role = box.Text;

    bool boxChecked = box.Checked;
    bool userInRole = (bool) CallWebAdminHelperMethod(false, "IsUserInRole", new object[] {u, role}, new Type[] {typeof(string),typeof(string)});
    try {
        if (boxChecked && !userInRole) {
            CallWebAdminHelperMethod(false, "AddUsersToRoles",new object[] {new string[]{u}, new string[]{role}}, new Type[] {typeof(string[]),typeof(string[])});
        }
        else if (!boxChecked && userInRole) {
            CallWebAdminHelperMethod(false, "RemoveUsersFromRoles",new object[] {new string[]{u}, new string[]{role}}, new Type[] {typeof(string[]),typeof(string[])});
        }
    }
    catch (Exception ex) {
        PlaceholderValidator.IsValid = false;
        PlaceholderValidator.ErrorMessage = ex.Message;
    }
}

public void UpdateUser(object sender, EventArgs e) {
    if (!Page.IsValid) {
        return;
    }
    string userIDText = UserID.Text;
    string emailText = Email.Text;
    string notSet = (string)GetLocalResourceObject("NotSet");
    try {
        MembershipUser mu = (MembershipUser) CallWebAdminHelperMethod(true, "GetUser", new object[] {(string) UserID.Text, false /* isOnline */}, new Type[] {typeof(string),typeof(bool)});
        mu.Email = Email.Text;
        if (
            Description.Text != null && !Description.Text.Equals(notSet)) {
            mu.Comment = Description.Text;
        }

        mu.IsApproved = ActiveUser.Checked;

        string  typeFullName = "System.Web.Security.MembershipUser, " + typeof(HttpContext).Assembly.GetName().ToString();;
        Type tempType = Type.GetType(typeFullName);

        CallWebAdminHelperMethod(true, "UpdateUser", new object[] {(MembershipUser) mu}, new Type[] {tempType});
        UpdateRoleMembership(userIDText);
    }
    catch (Exception ex) {
        PlaceholderValidator.IsValid = false;
        PlaceholderValidator.ErrorMessage = ex.Message;
        return;
    }
    
    // Go to confirmation
    DialogMessage.Text = String.Format((string)GetLocalResourceObject("Successful"), userIDText);
    AddAnother.Visible = false;
    Master.SetDisplayUI(true);

    ResetUI();       
}
</script>

<asp:content runat="server" contentplaceholderid="buttons">
<asp:button ValidationGroup="none" text="Back" id="DoneButton" onclick="ReturnToPreviousPage" runat="server"/>
</asp:content>

<asp:content runat="server" contentplaceholderid="titleBar">
<asp:literal runat="server" text="<%$ Resources:UpdateUser %>" />
</asp:content>

<asp:content runat="server" contentplaceholderid="content">

<div style="width:750">
<asp:literal runat="server" text="<%$ Resources:Instructions %>" />

<br/><br/>
</div>
<br/>

<table cellspacing="0" cellpadding="0" border="0"  width="750">
    <tbody>
    <tr align="left" valign="top">
        <td width="62%" height="100%" class="lbBorders">

            <table cellspacing="0" width="100%" cellpadding="0" border="0">
                <tr class="callOutStyleLowLeftPadding">
                    <td colspan="4">
                        <asp:literal runat="server" text="<%$ Resources:User %>" />
                    </td>
                </tr>
                <tr>
                    <td>
                        <table class="bodyText" bordercolor="#CCDDEF">
                            <tr>
                                <td width="2em"></td>
                                <td><asp:Label runat="server" AssociatedControlID="UserID" Text="<%$ Resources:UserID %>"/></td>
                                <td>
                                    <asp:textbox runat="server" id="UserID" maxlength="255" tabindex="101"/>
                                </td>
                            </tr>
                            <tr>
                                <td width="2em"><img runat="server" src="../../Images/requiredBang.gif" alt="<%$ Resources:Required %>"/></td>
                                <td><asp:Label runat="server" AssociatedControlID="Email" Text="<%$ Resources:EmailAddress %>"/></td>
                                <td>
                                    <asp:textbox runat="server" id="Email" maxlength="128" tabindex="102"/>
                                </td>
                                <td colspan="3"><asp:checkbox runat="server" id="ActiveUser" text="<%$ Resources:ActiveUser %>" checked="true"/></td>
                            </tr>

                            <tr>
                                <td width="2em"></td>
                                <td ><asp:Label runat="server" AssociatedControlID="Description" Text="<%$ Resources:Description %>"/></td>
                                <td>
                                    <asp:textbox runat="server" id="Description" />
                                </td>
                               <td colSpan="3"><asp:button runat="server" id="SaveButton" onClick="SaveClick" text="<%$ Resources:Save %>" width="100"/>
                                </td>
                            </tr>
                        </table>

                    </td>
                </tr>
            </table>
        </td>
        <td width="32%" height="100%">
            <table  borderwidth="1px" cellpadding="0" cellspacing="0" height="100%" width="100%">
                <tbody>
                <tr class="callOutStyleLowLeftPadding" height="1">
                    <td valign="top">
                        <asp:literal runat="server" text="<%$ Resources:Roles %>" />
                    </td>
                </tr>
                <tr valign="top">
                    <td  class="userDetailsWithFontSize" height="100%">
                        <asp:panel runat="server" id="Panel1" scrollbars="auto" valign="top">
                        <asp:label runat="server" id="SelectRolesLabel" text="<%$ Resources:SelectRoles%>"/>
                        <br/>
                        <asp:repeater runat="server" id="CheckBoxRepeater">
                        <itemtemplate>
                        <asp:checkbox runat="server" id="checkBox1" text='<%# Container.DataItem.ToString()%>' checked='<%# (CurrentUser == null) ? false : (bool)CallWebAdminHelperMethod(false, "IsUserInRole", new object[] {(string) CurrentUser, (string) Container.DataItem.ToString()}, new Type[] {typeof(string),typeof(string)})%>'/>
                        <br/>
                        </itemtemplate>
                        </asp:repeater>
                        </asp:panel>
                    </td>
                </tr>
    </tbody>
            </table>
        </td>
    </tr>
    </tbody>
</table>
            (<asp:image runat="server" imageurl="../../Images/requiredBang.gif" alternateText="<%$ Resources:Required %>"/>) 
                        <asp:literal runat="server" text="<%$ Resources:RequiredField %>" />                                

</div>
<br/>
<asp:validationsummary runat="server" headertext="<%$ Resources:PleaseCorrect %>"/>
<asp:requiredfieldvalidator runat="server" controltovalidate="UserID" enableclientscript="false" errormessage="<%$ Resources:UserIDRequired %>" display="none"/>
<asp:regularexpressionvalidator runat="server" controltovalidate="Email" enableclientscript="false" errormessage="<%$ Resources:InvalidEmailFormat %>" display="none" validationexpression="\S+@\S+\.\S+"/>
<asp:requiredfieldvalidator runat="server" controltovalidate="Email" enableclientscript="false" errormessage="<%$ Resources:EmailRequired %>" display="none"/>
<asp:customvalidator runat="server" id="PlaceholderValidator" controltovalidate="UserID" enableclientscript="false" errormessage="<%$ Resources:InvalidInput %>" onservervalidate="ServerCustomValidate" display="none"/>
</asp:content>

<%-- Confirmation Dialog --%>
<asp:content runat="server" contentplaceholderid="dialogTitle">
<asp:literal runat="server" text="<%$ Resources:UserManagement %>" />
</asp:content>

<asp:content runat="server" contentplaceholderid="dialogContent">
<asp:literal runat="server" id="DialogMessage" />

</asp:content>

<asp:content runat="server" contentplaceholderid="dialogBottomLeftLink">
    <asp:HyperLink runat="server" NavigateUrl="~/security/Security.aspx" Text="<%$ Resources:GoHome %>"/>
</asp:content>

<asp:content runat="server" contentplaceholderid="dialogBottomLeftButton">
    <asp:Button runat="server" id="AddAnother" enableViewState="false" OnClick="AddAnother_Click" Text="<%$ Resources:AddAnother %>" width="100"/>
</asp:content>

<asp:content runat="server" contentplaceholderid="dialogBottomRightButton">
    <asp:Button runat="server" OnClick="OK_Click" Text="<%$ Resources:OK %>" width="75"/>
</asp:content>
