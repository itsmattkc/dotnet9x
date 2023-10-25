<%@ Page masterPageFile="~/WebAdminNoButtonRow.master" inherits="System.Web.Administration.SecurityPage"%>
<%@ MasterType virtualPath="~/WebAdminNoButtonRow.master" %>
<%@ Import Namespace="System.Web.Administration" %>

<script runat="server" language="cs">

private const string DATA_SOURCE = "WebAdminDataSource";

public void SetDataSource(object v) {
    Session[DATA_SOURCE] = v;
}

public void BindGrid(bool displayNoUsersCreated) {
    dataGrid.DataSource = Session[DATA_SOURCE];
    dataGrid.DataBind();
    if (dataGrid.Rows.Count == 0) {
		if(displayNoUsersCreated) {
			noUsers.Visible = true;
		} 
		else {
			notFoundUsers.Visible = true;
		}
    }
}

public void IndexChanged(object sender, GridViewPageEventArgs e) {
    dataGrid.PageIndex = e.NewPageIndex;
    BindGrid(false);
}

public void Page_Load() {
    if (!IsPostBack) {
        ClearUserCollection();
    }

    noUsers.Visible = false;
    if(!IsPostBack) {
        PopulateRepeaterDataSource();
        alphabetRepeater.DataBind();

        Int32 total = 0;
        dataGrid.DataSource = (MembershipUserCollection) CallWebAdminHelperMethod(true,"GetAllUsers",new object[] {0, Int32.MaxValue, total}, new Type[] {typeof(int),typeof(int),Type.GetType("System.Int32&")});
        SetDataSource(dataGrid.DataSource);
        BindGrid(true);
    }

    dataGrid.HeaderStyle.HorizontalAlign = DirectionalityHorizontalAlign;
}

private void Cancel_Click(object sender, EventArgs e) {
    ClearUserCollection();
    ReturnToPreviousPage(sender, e);
}

public void SelectedChanged(object sender, EventArgs e) {
    CheckBox checkBox = (CheckBox) sender;
    GridViewRow item = (GridViewRow)checkBox.Parent.Parent;
    Label label = (Label) item.FindControl("userNameLabel");
    string userID = label.Text;
    // Add/remove the user in the collection
    UserCollection[userID] = checkBox.Checked ? (object)true : null;
}

private void OK_Click(object sender, EventArgs e) {
    ReturnToPreviousPage(sender, e);
}

private void PopulateRepeaterDataSource() {
    PopulateRepeaterDataSource (alphabetRepeater);
}

public void RedirectToAddUser(object sender, EventArgs e) {
    CurrentUser = null;
    // do not prepend ~/ to this path since it is not at the root
    Response.Redirect("adduser.aspx");
}

public void RetrieveLetter(object sender, RepeaterCommandEventArgs e) {
    RetrieveLetter(sender, e, dataGrid);
    SetDataSource(dataGrid.DataSource);
    BindGrid(false);
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
    SearchForUsers(sender, e, alphabetRepeater, dataGrid, dropDown1, textBox1);
    SetDataSource(dataGrid.DataSource);
    BindGrid(false);
}
</script>


<asp:content runat="server" contentplaceholderid="titleBar">
Find Users
</asp:content>
<asp:content runat="server" contentplaceholderid="content">
<asp:literal runat="server" text="<%$ Resources:Instructions %>"/>
<table cellspacing="0" cellpadding="5" class="lrbBorders" width="750">
    <tr>
        <td class="callOutStyle"><asp:literal runat="server" text="<%$ Resources:SearchUsers %>"/></td>
    </tr>
    <tr >
        <td class="bodyTextLowTopPadding"><asp:literal runat="server" text="<%$ Resources:SearchBy %>"/>
            <asp:dropDownList runat="server" id="dropDown1">
            <asp:listItem runat="server" id="item1" text="<%$ Resources:Username %>" >
            </asp:listitem>
            <asp:listitem runat="server" id="item2" text="<%$ Resources:EMail %>" >
            </asp:listitem>
            </asp:dropdownlist>
            &nbsp;&nbsp;
            <asp:literal runat="server" text="<%$ Resources:For %>"/>
            <asp:textbox runat="server" id="textBox1"/>
            <asp:button runat="server" text="<%$ Resources:FindUser %>" onclick="SearchForUsers"/>
            <br/>
            <asp:Label runat="server" id="alphabetInfo" Text="<%$ Resources:GlobalResources,AlphabetInfo %>"/><br/>
            <asp:repeater runat="server" id="alphabetRepeater" onitemcommand="RetrieveLetter">
            <itemtemplate>
            <asp:linkbutton runat="server" id="linkButton1" commandname="Display" commandargument="<%#Container.DataItem%>" text="<%#Container.DataItem%>"/>
            &nbsp;
            </itemtemplate>
            </asp:repeater>
        </td>
</table>
<br/>

<table cellspacing="0" cellpadding="0" border="0" id="hook" width="750">
    <tbody>
    <tr align="left" valign="top">
        <td width="62%" height="100%" class="lrbBorders">
            <asp:label runat="server" id="noUsers" class="bodyTextNoPadding" enableViewState="false" visible="false">&nbsp;<asp:literal runat="server" text="<%$ Resources:NoUsersCreated %>"/></asp:label>
            <asp:label runat="server" id="notFoundUsers" class="bodyTextNoPadding" enableViewState="false" visible="false">&nbsp;<asp:literal runat="server" text="<%$ Resources:NotFoundUsers %>"/></asp:label>
	
            <asp:gridView runat="server" id="dataGrid" width="100%" cellspacing="0" cellpadding="5" border="0" autogeneratecolumns="False" allowpaging="true" pagesize="7" onpageindexchanging="IndexChanged" UseAccessibleHeader="true" >
            <rowstyle cssclass="gridRowStyle" />
            <alternatingrowstyle cssclass="gridAlternatingRowStyle" />
            <pagerstyle cssClass="gridPagerStyle"/>
            <pagersettings mode="Numeric"/>

            <headerstyle cssclass="callOutStyle" font-bold="true"/>
            <selectedrowstyle cssclass="gridSelectedRowStyle"/>
            <columns>
                                    
            <asp:templatefield>
            <itemstyle horizontalalign="center"/>
            <itemtemplate>
            <asp:checkBox runat="server" id="checkBox1" oncheckedchanged="SelectedChanged" autopostback="true" checked='<%#UserCollection[DataBinder.Eval(Container.DataItem, "UserName")] != null%>'/>
            </itemtemplate>
            </asp:templatefield>

            <asp:templatefield runat="server" headertext="<%$ Resources:Username %>">
            <itemtemplate>
            <asp:label runat="server" id="userNameLabel" forecolor='black' text='<%# DataBinder.Eval(Container.DataItem, "UserName")%>'/>
            </itemtemplate>
            </asp:templatefield>

            <asp:templatefield runat="server" headertext="<%$ Resources:EmailAddress %>">
            <itemtemplate>
            <asp:label runat="server" id="email" forecolor='black' text='<%#DataBinder.Eval(Container.DataItem, "Email")%>'/>
            </itemtemplate>
            </asp:templatefield>

            </columns>
            </asp:gridView>
            
            <div align="right">
               <asp:button runat="server" onclick="OK_Click" text="<%$ Resources:OK %>" width="75"/>
               <asp:button runat="server" onclick="Cancel_Click" text="<%$ Resources:Cancel %>" width="75"/>
            </div>  
            
        </td>

    </tr>
    </tbody>
</table>
<%-- Cause the textbox to submit the page on enter, raising server side onclick--%>
<input type="text" style="visibility:hidden"/>
</asp:content>
