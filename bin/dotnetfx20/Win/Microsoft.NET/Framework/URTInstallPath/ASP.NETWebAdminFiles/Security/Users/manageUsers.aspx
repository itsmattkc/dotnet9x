<%@ Page masterPageFile="~/WebAdminWithConfirmation.master" inherits="System.Web.Administration.SecurityPage"%>
<%@ MasterType virtualPath="~/WebAdminWithConfirmation.master" %>
<%@ Import Namespace="System.Web.Administration" %>

<script runat="server" language="cs">

private const string DATA_SOURCE = "WebAdminDataSource";
private const string DATA_SOURCE_ROLES = "WebAdminDataSourceRoles";

public void SetDataSourceRoles(object v) {
    Session[DATA_SOURCE_ROLES] =  v;
}

public void SetDataSource(object v) {
    Session[DATA_SOURCE] = (MembershipUserCollection) v;
}

public void BindGrid(bool displayUsersNotCreated) {
    DataGrid.DataSource = Session[DATA_SOURCE];
    DataGrid.DataBind();
    if (DataGrid.Rows.Count == 0) {
        if(displayUsersNotCreated) {
            noUsers.Visible = true;
        }
        else {
            notFoundUsers.Visible = true;
        }
    }
}

public void IndexChanged(object sender, GridViewPageEventArgs e) {
    DataGrid.PageIndex = e.NewPageIndex;
    BindGrid(false);
}

public void Page_Load() {
    noUsers.Visible = false;
    if(!IsPostBack) {
        PopulateRepeaterDataSource();
        AlphabetRepeater.DataBind();

        int total = 0;
        MembershipUserCollection users = (MembershipUserCollection) CallWebAdminHelperMethod(true, "GetAllUsers",new object[] {0, Int32.MaxValue, total}, new Type[] {typeof(int),typeof(int),Type.GetType("System.Int32&")});
        string[] roles = null;
        if (IsRoleManagerEnabled()) {
            roles = (string[]) CallWebAdminHelperMethod(false, "GetAllRoles",new object[] {}, null);
        }

        SetDataSourceRoles(roles);
        SetDataSource(users);
        BindGrid(true);
        DataGrid.HeaderStyle.HorizontalAlign = DirectionalityHorizontalAlign;
    }
}

public void ButtonClick(object sender, EventArgs e) {
    LinkButton button = (LinkButton)sender;
    string userName = button.CommandArgument;
    SetCurrentUser(userName);
}

public void EnabledChanged(object sender, EventArgs e) {
    CheckBox checkBox = (CheckBox) sender;
    GridViewRow item = (GridViewRow)checkBox.Parent.Parent;
    Label label = (Label) item.FindControl("UserNameLink");
    string userID = label.Text;
    MembershipUser user = (MembershipUser) CallWebAdminHelperMethod(true, "GetUser", new object[] {userID, false /* isOnline */}, new Type[] {typeof(string),typeof(bool)});
    user.IsApproved = checkBox.Checked;

    string  typeFullName = "System.Web.Security.MembershipUser, " + typeof(HttpContext).Assembly.GetName().ToString();;
    Type tempType = Type.GetType(typeFullName);

    CallWebAdminHelperMethod(true, "UpdateUser", new object[] {(MembershipUser) user}, new Type[] {tempType});
}

public void LinkButtonClick(object sender, CommandEventArgs e) {
    if (e.CommandName.Equals("EditUser")) {
        CurrentUser = ((string)e.CommandArgument); 
        // do not prepend ~/ to this path since it is not at the root
        Response.Redirect("editUser.aspx");
    }
    if (e.CommandName.Equals("DeleteUser")) {
        UserID.Text = (string)e.CommandArgument;
        AreYouSure.Text = String.Format((string)GetLocalResourceObject("AreYouSure"), UserID.Text);
        Master.SetDisplayUI(true);
    }
}

private void No_Click(object sender, EventArgs e) {
    Master.SetDisplayUI(false);
}

private void PopulateRepeaterDataSource() {
    PopulateRepeaterDataSource (AlphabetRepeater);
}

public void RedirectToAddUser(object sender, EventArgs e) {
    CurrentUser = null;
    // do not prepend ~/ to this path since it is not at the root
    Response.Redirect("adduser.aspx");
}

public void RetrieveLetter(object sender, RepeaterCommandEventArgs e) {
    MembershipUserCollection users = null;
    RetrieveLetter(sender, e, DataGrid, (string)GetGlobalResourceObject("GlobalResources", "All"), users);
    SetDataSource(DataGrid.DataSource);
    BindGrid(false);
    RolePlaceHolder.Visible = DataGrid.Rows.Count != 0;
}

protected void RoleMembershipChanged(object sender, EventArgs e) {
    try {
        CheckBox box = (CheckBox) sender;
        // Array manipulation because cannot use Roles static method (need different appPath).
        string u = CurrentUser;
        string role = box.Text;

        if (box.Checked) {
            CallWebAdminHelperMethod(false, "AddUsersToRoles",new object[] {new string[]{u}, new string[]{role}}, new Type[] {typeof(string[]),typeof(string[])});
        }
        else {
            CallWebAdminHelperMethod(false, "RemoveUsersFromRoles",new object[] {new string[]{u}, new string[]{role}}, new Type[] {typeof(string[]),typeof(string[])});
        }
    }
    catch {
        // Ignore, e.g., user is already in role.
    }
}

public void SearchForUsers(object sender, EventArgs e) {
    SearchForUsers(sender, e, AlphabetRepeater, DataGrid, SearchByDropDown, TextBox1);
    SetDataSource(DataGrid.DataSource);
    BindGrid(false);
    RolePlaceHolder.Visible = DataGrid.Rows.Count != 0;
}

private void SetCurrentUser(string s) {
    CurrentUser = s;
    if (IsRoleManagerEnabled()) {

        CheckBoxRepeater.DataSource = Session[DATA_SOURCE_ROLES];
        CheckBoxRepeater.DataBind();
        if (CheckBoxRepeater.Items.Count > 0) {
            AddToRole.Text = String.Format((string)GetLocalResourceObject("AddToRoles2"), s);
        }
        else {
            AddToRole.Text = (string)GetLocalResourceObject("NoRolesDefined");
        }
    }
    else {
        ArrayList arr = new ArrayList();
        CheckBoxRepeater.DataSource = arr;
        CheckBoxRepeater.DataBind();
        AddToRole.Text = (string)GetLocalResourceObject("RolesNotEnabled");
    }

    multiView1.ActiveViewIndex = 1;
}

private string GetToolTip(string resourceName, string itemName) {
    string tempString = (string) GetLocalResourceObject(resourceName);
    return String.Format((string)GetGlobalResourceObject("GlobalResources","ToolTipFormat"), tempString, itemName);
}

private void Yes_Click(object sender, EventArgs e) {
    CallWebAdminHelperMethod(true, "DeleteUser", new object[] {(string) UserID.Text, true}, new Type[] {typeof(string),typeof(bool)});

    int total = 0;
    MembershipUserCollection users = (MembershipUserCollection) CallWebAdminHelperMethod(true, "GetAllUsers",new object[] {0, Int32.MaxValue, total}, new Type[] {typeof(int),typeof(int),Type.GetType("System.Int32&")});
    string[] roles = null;
    if (IsRoleManagerEnabled()) {
        roles = (string[]) CallWebAdminHelperMethod(false, "GetAllRoles",new object[] {}, null);
    }

    SetDataSource(users);
    SetDataSourceRoles(roles);
    BindGrid(true);

    PopulateRepeaterDataSource();
    AlphabetRepeater.DataBind();

    Master.SetDisplayUI(false);
}
</script>


<asp:content runat="server" contentplaceholderid="titleBar">
Manage Users
</asp:content>

<asp:content runat="server" contentplaceholderid="buttons">
<asp:button ValidationGroup="none" runat="server" id="Button1" text="<%$ Resources:Back %>" onclick="ReturnToPreviousPage"/>
</asp:content>

<asp:content runat="server" contentplaceholderid="content">
<asp:literal runat="server" text="<%$ Resources:Instructions %>" />
<br/><br/>
<%-- Cause the textbox to submit the page on enter, raising server side onclick--%>
<input type="text" style="visibility:hidden"/>
<table cellspacing="0" cellpadding="5" class="lrbBorders" width="750">
    <tr>
        <td class="callOutStyle"><asp:literal runat="server" text="<%$ Resources:SearchForUsers %>"/></td>
    </tr>
    <tr >
        <td class="bodyTextLowTopPadding">
            <asp:Label runat="server" AssociatedControlID="SearchByDropDown" Text="<%$ Resources:SearchBy %>"/>
            <asp:dropDownList runat="server" id="SearchByDropDown">
            <asp:listItem runat="server" id="Item1" text="<%$ Resources:Username %>" />
            <asp:listitem runat="server" id="Item2" text="<%$ Resources:Email %>" />
            </asp:dropdownlist>
            &nbsp;&nbsp;<asp:Label runat="server" AssociatedControlID="TextBox1" Text="<%$ Resources:For %>"/>
            <asp:textbox runat="server" id="TextBox1"/>
            <asp:button runat="server" text="<%$ Resources:SearchFor %>" onclick="SearchForUsers"/>
            <br/>
            <asp:Label runat="server" id="AlphabetInfo" Text="<%$ Resources:GlobalResources,AlphabetInfo %>"/><br/>
            <asp:repeater runat="server" id="AlphabetRepeater" onitemcommand="RetrieveLetter">
            <itemtemplate>
            <asp:linkbutton runat="server" id="LinkButton1" commandname="Display" commandargument="<%#Container.DataItem%>" text="<%#Container.DataItem%>"/>
            &nbsp;
            </itemtemplate>
            </asp:repeater>
        </td>
</table>
<br/>

<table cellspacing="0" cellpadding="0" border="0" id="hook" width="750">
    <tbody>
    <tr align="left" valign="top">
        <td width="62%" height="100%" class="lbBorders">
            <asp:gridview runat="server" id="DataGrid" width="100%" cellspacing="0" cellpadding="5" border="0" autogeneratecolumns="False" allowpaging="true" pagesize="7" onpageindexchanging="IndexChanged" UseAccessibleHeader="true">
            <rowstyle cssclass="gridRowStyle" />
            <alternatingrowstyle cssclass="gridAlternatingRowStyle" />
            <pagerstyle cssClass="gridPagerStyle"/>
            <pagersettings mode="Numeric"/>
            <headerstyle cssclass="callOutStyle" font-bold="true" />
            <selectedrowstyle cssclass="gridSelectedRowStyle"/>
            <columns>
           
                        
            <asp:templatefield headertext="<%$ Resources:Active %>">
            <headerstyle horizontalalign="center"/>
            <itemstyle horizontalalign="center"/>
            <itemtemplate>
            <asp:checkBox runat="server" id="CheckBox1" oncheckedchanged="EnabledChanged" autopostback="true" checked='<%#DataBinder.Eval(Container.DataItem, "IsApproved")%>'/>
            </itemtemplate>
            </asp:templatefield>

            <asp:templatefield runat="server" headertext="<%$ Resources:Username %>">
            <itemtemplate>
            <asp:label runat="server" id="UserNameLink" forecolor='black' text='<%#DataBinder.Eval(Container.DataItem, "UserName")%>'/>
            </itemtemplate>
            </asp:templatefield>

            <asp:templatefield runat="server">
            <itemtemplate>
            <asp:linkButton runat="server" id="LinkButton1" text="<%$ Resources:EditUser %>" commandname="EditUser" toolTip='<%# GetToolTip("EditUser",DataBinder.Eval(Container.DataItem, "UserName").ToString()) %>' commandargument='<%#DataBinder.Eval(Container.DataItem, "UserName")%>' forecolor="black" oncommand="LinkButtonClick"/>
            </itemtemplate>
            </asp:templatefield>

            <asp:templatefield runat="server">
            <itemtemplate>
            <asp:linkButton runat="server" id="linkButton2" text="<%$ Resources:DeleteUser%>" commandname="DeleteUser" toolTip='<%# GetToolTip("DeleteUser",DataBinder.Eval(Container.DataItem, "UserName").ToString()) %>' commandargument='<%#DataBinder.Eval(Container.DataItem, "UserName")%>' forecolor="black" oncommand="LinkButtonClick"/>
            </itemtemplate>
            </asp:templatefield>

            <asp:templatefield runat="server">
            <itemtemplate>
            <asp:linkbutton runat="server" commandname="EditRoles" toolTip='<%# GetToolTip("EditRoles",DataBinder.Eval(Container.DataItem, "UserName").ToString()) %>' forecolor='black' onclick="ButtonClick" text="<%$ Resources:EditRoles %>" commandargument='<%# DataBinder.Eval(Container.DataItem, "UserName") %>'/>
            </itemtemplate>
            </asp:templatefield>

            </columns>
            </asp:gridview>

            
            <asp:label runat="server" id="noUsers" class="bodyTextNoPadding" enableViewState="false" visible="false" text="<%$ Resources:NoUsersCreated %>"/>
            <asp:label runat="server" id="notFoundUsers" class="bodyTextNoPadding" enableViewState="false" visible="false" text="<%$ Resources:NotFoundUsers %>"/>
            
        </td>
        <td width="32%" height="100%">
            <asp:placeholder runat="server" id="RolePlaceHolder">
                <table borderwidth="1px" cellpadding="5" cellspacing="0" height="100%" width="100%">
                    <tr class="callOutStyle">
                        <td valign="center"><asp:literal runat="server" text="<%$ Resources:Roles %>"/></td>
                    </tr>
                    <tr class="userDetailsWithFontSize" valign="top">
                        <td class="lrbBorders" height="100%" >
                            <asp:multiView runat="server" id="multiView1" activeviewindex="0">
                            <asp:view runat="server" id="view1">
                            </asp:view>
                            <asp:view runat="server" id="view2">
                            <asp:label runat="server" id="AddToRole" text="<%$ Resources:AddToRoles %>"/><br/>
                            <asp:repeater runat="server" id="CheckBoxRepeater">
                            <itemtemplate>
                            <asp:checkBox runat="server" id="CheckBox1" autopostback="true" oncheckedchanged="RoleMembershipChanged" text='<%# Container.DataItem.ToString()%>' checked='<%# (bool)CallWebAdminHelperMethod(false, "IsUserInRole", new object[] {CurrentUser, Container.DataItem.ToString()}, new Type[] {typeof(string),typeof(string)}) %>'/>
                            <br/>
                            </itemtemplate>
                            </asp:repeater>
                            </asp:view>
                            </asp:multiView>
                        </td>
                    </tr>
                </table>
            </asp:placeholder>
        </td>
    </tr>
    </tbody>
</table>
<asp:linkButton runat="server" id="LinkButton3" text="<%$ Resources:CreateNewUser %>" onclick="RedirectToAddUser"/>
</asp:content>

<%-- Confirmation Dialog --%>
<asp:content runat="server" contentplaceholderid="dialogTitle">
<asp:literal runat="server" text="<%$ Resources:ManageUsers %>" />
</asp:content>

<asp:content runat="server" contentplaceholderid="dialogContent">

    <img src="../../Images/alert_lrg.gif"/>
<%-- Literal is used here as a convenience, including storing a text property in view state. --%>
<asp:literal runat="server" id="UserID" visible="false"/>
<asp:literal runat="server" id="AreYouSure" text="<%$ Resources:AreYouSure %>" />
</asp:content>

<asp:content runat="server" contentplaceholderid="dialogBottomLeftButton">
    <asp:Button runat="server" OnClick="Yes_Click" Text="<%$ Resources:Yes %>" width="100"/>
</asp:content>

<asp:content runat="server" contentplaceholderid="dialogBottomRightButton">
    <asp:Button runat="server" OnClick="No_Click" Text="<%$ Resources:No %>" width="100"/>
</asp:content>


