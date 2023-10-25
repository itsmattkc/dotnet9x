<%@ Page masterPageFile="~/WebAdminButtonRow.master" inherits="System.Web.Administration.SecurityPage"%>
<%@ Import Namespace="System.Drawing" %>
<%@ Import Namespace="System.Web.Administration" %>
<%@ Import Namespace="System.Web.Configuration" %>

<script runat="server" language="cs">

private const string DATA_SOURCE = "WebAdminDataSource";

public void SetDataSource(object v) {
    Session[DATA_SOURCE] = v;
}

public void BindGrid(bool displayUsersNotFound) {
    dataGrid.DataSource = Session[DATA_SOURCE];
    dataGrid.DataBind();
    if (dataGrid.Rows.Count == 0) {
        if (displayUsersNotFound) {
            notFoundUsers.Visible = true;
        }
    }
}

public void IndexChanged(object sender, GridViewPageEventArgs e) {
    dataGrid.PageIndex = e.NewPageIndex;
    BindGrid(false);
}

public void EnabledChanged(object sender, EventArgs e) {
    CheckBox checkBox = (CheckBox) sender;
    GridViewRow gvr = (GridViewRow)checkBox.Parent.Parent;
    Label label = (Label) gvr.FindControl("userNameLink");
    string userName = label.Text;
    string currentRoleName = CurrentRole;
    if (checkBox.Checked) {

        if (!(bool)CallWebAdminHelperMethod(false, "IsUserInRole", new object[] {userName, currentRoleName}, new Type[] {typeof(string),typeof(string)})) {
            CallWebAdminHelperMethod(false, "AddUsersToRoles",new object[] {new string[]{userName}, new string[]{currentRoleName}}, new Type[] {typeof(string[]),typeof(string[])});
        }
    }
    else {
        if ((bool)CallWebAdminHelperMethod(false, "IsUserInRole", new object[] {userName, currentRoleName}, new Type[] {typeof(string),typeof(string)})) {
            CallWebAdminHelperMethod(false, "RemoveUsersFromRoles",new object[] {new string[]{userName}, new string[]{currentRoleName}}, new Type[] {typeof(string[]),typeof(string[])});
        }
    }
}

public void Page_Load() {
    if(!IsPostBack) {
        PopulateRepeaterDataSource();
        repeater.DataBind();
        string currentRoleName = CurrentRole;
        roleName.Text = currentRoleName;

        string[] muc = (string[]) CallWebAdminHelperMethod(false, "GetUsersInRole", new object[] {currentRoleName}, new Type[] {typeof(string)});
        MembershipUserCollection Coll = new MembershipUserCollection();
        // no Role method for returning a MembershipUserCollection.
        MembershipUser OneUser = null;
        foreach (string username in muc) {
            try {
                OneUser = (MembershipUser) CallWebAdminHelperMethod(true, "GetUser", new object[] {username, false /* isOnline */}, new Type[] {typeof(string),typeof(bool)});
            }
            catch {
                // eat it
            }
            if (OneUser != null) {
                Coll.Add(OneUser);
            }
        }
        SetDataSource(Coll);
        BindGrid(false);
        dataGrid.HeaderStyle.HorizontalAlign = DirectionalityHorizontalAlign;
    }

}

    
private void PopulateRepeaterDataSource() {
    PopulateRepeaterDataSource (repeater);
}

protected override void OnPreRender(EventArgs e) {
    base.OnPreRender(e);
    if (dataGrid.Rows.Count == 0) {
        containerTable.Visible = false;
    }
    else {
        containerTable.Visible = true;
    }
}

public void RedirectToAddUser(object sender, EventArgs e) {
    // do not prepend ~/ to this path since it is not at the root
    Response.Redirect("adduser.aspx");
}

public void RetrieveLetter(object sender, RepeaterCommandEventArgs e) {
    RetrieveLetter(sender, e, dataGrid, (string)GetLocalResourceObject("All"));
    SetDataSource(dataGrid.DataSource);
    BindGrid(true);
}

public void SearchForUsers(object sender, EventArgs e) {
    SearchForUsers(sender, e, repeater, dataGrid, dropDown1, textBox1);
    SetDataSource(dataGrid.DataSource);
    BindGrid(true);
    //multiView1.ActiveViewIndex = 0;
}

</script>


<asp:content runat="server" contentplaceholderid="titleBar">
<asp:literal runat="server" text="<%$ Resources:ManageRoleMembership %>" />
</asp:content>

<asp:content runat="server" contentplaceholderid="buttons">
<asp:button ValidationGroup="none" runat="server" id="button1" text="<%$ Resources:Back %>" onclick="ReturnToPreviousPage"/>
</asp:content>


<asp:content runat="server" contentplaceholderid="content">
<%-- Cause the textbox to submit the page on enter, raising server side onclick--%>
<input type="text" style="visibility:hidden"/>
<table width="100%">
    <tbody>
    <tr>
        <td>
            <span class="bodyTextNoPadding">
            <asp:literal runat="server" text="<%$ Resources:Instructions %>" />
            <br/>
            <br/>
            <asp:literal runat="server" text="<%$ Resources:Role %>" />
            <asp:label id="roleName" runat="server" font-bold="true">
            </asp:label>
            </span>
        </td>
    </tr>
    <tr>
        <td>
            <table>
                <tbody>
                <tr valign="top">
                    <td>
                        <table cellspacing="0" cellpadding="5" class="lrbBorders" width="750"/>

                        <tbody>
                <tr>
                    <td class="callOutStyle">
                         <asp:literal runat="server" text="<%$ Resources:SearchForUsers %>" />
                    </td>
                </tr>
                <tr >
                    <td class="bodyTextNoPadding">
                        <asp:literal runat="server" text="<%$ Resources:SearchBy %>" />
                        <asp:dropdownlist id="dropDown1" runat="server">
                        <asp:listitem runat="server" id="listItem1" text="<%$ Resources:Username %>"/>
                        <asp:listitem runat="server" id="listItem2" text="<%$ Resources:Email %>"/>
                        </asp:dropdownlist>
                        &nbsp;<asp:literal runat="server" text="<%$ Resources:For %>"/>
                        <asp:textbox runat="server" id="textBox1" width="11em"/>
                        &nbsp;
                        <asp:button runat="server" id="button2" onclick="SearchForUsers" text="<%$ Resources:FindUser %>"/>
                        <br />
                       <asp:Label runat="server" id="alphabetInfo" Text="<%$ Resources:GlobalResources,AlphabetInfo %>"/><br/>
                        <asp:repeater runat="server" id="repeater" onitemcommand="RetrieveLetter">
                        <itemtemplate>
                        <asp:linkbutton runat="server" id="linkButton1" text="<%#Container.DataItem%>" forecolor="black" commandname="Display" commandargument="<%#Container.DataItem%>" />
                        &nbsp;
                        </itemtemplate>
                        </asp:repeater>
                    </td>
                </tr>
    </tbody>
            </table>
            <br />
            <table id="containerTable" runat="server" border="0" cellspacing="0" cellpadding="0"  class="itemDetailsContainer" width="750" >
                <tbody>
                <tr align="left" valign="top">
                    <td width="62%" height="100%" class="lrbBorders">
                        <asp:gridview runat="server" id="dataGrid" allowpaging="true" border="0" cellspacing="0" cellpadding="5" autogeneratecolumns="False" onitemdatabound="ItemDataBound" onpageindexchanging="IndexChanged" pagesize="7" width="100%" UseAccessibleHeader="true">
                        <rowstyle cssclass="gridRowStyle" />
                        <alternatingrowstyle cssclass="gridAlternatingRowStyle" />
                        <headerstyle cssclass="callOutStyle" font-bold="true" height="10"/>
                        <selectedrowstyle cssclass="gridSelectedRowStyle"/>
                        <pagerstyle cssclass="gridPagerStyle"/>
                        <pagersettings mode="Numeric"/>
                        <columns>

                        <asp:templatefield runat="server" headertext="<%$ Resources:Username %>">
                        <itemtemplate>
                        <asp:label runat="server" id="userNameLink" forecolor='black' text='<%#DataBinder.Eval(Container.DataItem, "UserName")%>'/>
                        </itemtemplate>
                        </asp:templatefield>

                        <asp:templatefield runat="server" headertext="<%$ Resources:UserInRole %>" >
                        <headerstyle horizontalalign="center" />
                        <itemstyle horizontalalign="center" />
                        <itemtemplate>
                        <asp:checkbox runat="server" oncheckedchanged="EnabledChanged" autopostback="true" checked='<%#(bool)CallWebAdminHelperMethod(false, "IsUserInRole", new object[] {(string) DataBinder.Eval(Container.DataItem, "UserName").ToString(), (string)CurrentRole}, new Type[] {typeof(string),typeof(string)})%>' />
                        </itemtemplate>
                        </asp:templatefield>

                        </columns>
                        </asp:gridview>
                    </td>
                </tr>
                </tbody>
            </table>
            <asp:label runat="server" id="notFoundUsers" class="bodyTextNoPadding" enableViewState="false" visible="false" text="<%$ Resources:NotFoundUsers %>"/>
        </td>
    </tr>
    </tbody>
</table>
</td>
</tr>
</tbody>
</table>
</asp:content>

