<%@ Page masterPageFile="~/WebAdminWithConfirmation.master" inherits="System.Web.Administration.SecurityPage"%>
<%@ MasterType virtualPath="~/WebAdminWithConfirmation.master" %>
<%@ Import Namespace="System.Data.SqlClient" %>

<script runat="server" language="cs">

public void AddRole(object sender, EventArgs e) {
    if (!textBox1.Text.Equals(string.Empty)){
        try {
            CallWebAdminHelperMethod(false, "CreateRole",new object[] {(string) textBox1.Text}, new Type[] {typeof(string)});
            textBox1.Text = string.Empty;
        }
        catch (Exception ex){
            errorMessage.Text = ex.Message;
            errorMessage.Visible = true;
        }
        BindGrid();
    }
}

private void BindGrid() {
    string[] arr = (string[])CallWebAdminHelperMethod(false, "GetAllRoles", new object[] {}, null);
    dataGrid.DataSource = arr;

    int currentPage = dataGrid.PageIndex;
    int count = arr.Length;
    int pageSize = dataGrid.PageSize;
    if (count > 0 && currentPage == count / pageSize && count % pageSize == 0) {
        dataGrid.PageIndex -= 1;
    }
    dataGrid.DataBind();
    dataGrid.Visible = (dataGrid.Rows.Count > 0);
}

private string GetToolTip(string resourceName, string itemName) {
    string tempString = (string) GetLocalResourceObject(resourceName);
    return String.Format((string)GetGlobalResourceObject("GlobalResources","ToolTipFormat"), tempString, itemName);
}

public void IndexChanged(object sender, GridViewPageEventArgs e) {
    dataGrid.PageIndex = e.NewPageIndex;
    BindGrid();
}

public void LinkButtonClick(object sender, CommandEventArgs e){
    if (e.CommandName.Equals("ManageRole")) {
        CurrentRole = (string)e.CommandArgument;
        // do not prepend ~/ to this path since it is not at the root
        Response.Redirect("manageSingleRole.aspx");
    }
    if (e.CommandName.Equals("DeleteRole")){
        RoleName.Text = (string)e.CommandArgument;
        Master.SetDisplayUI(true);
    }
}


private void No_Click(object sender, EventArgs e) {
    Master.SetDisplayUI(false);
}


public void Page_Load() {
    if (!IsPostBack) {
        BindGrid();
    }

    dataGrid.HeaderStyle.HorizontalAlign = DirectionalityHorizontalAlign;
}

private void Yes_Click(object sender, EventArgs e) {
    if ((bool)CallWebAdminHelperMethod(false, "RoleExists", new object[] {(string) RoleName.Text}, new Type[] {typeof(string)})) {
        CallWebAdminHelperMethod(false, "DeleteRole", new object[] {(string) RoleName.Text, false}, new Type[] {typeof(string),typeof(bool)});
    }

    BindGrid();
    Master.SetDisplayUI(false);
}
</script>


<asp:content runat="server" contentplaceholderid="buttons">
    <asp:button ValidationGroup="none" text="<%$ Resources:Back%>" id="doneButton" onClick="ReturnToPreviousPage" runat=server/>
</asp:content>

<asp:content runat="server" contentplaceholderid="titleBar"><asp:literal runat="server" text="<%$ Resources:ManageRoles %>"/>
</asp:content>
<asp:content runat="server" contentplaceholderid="content">

<div style="width:580">
    <asp:literal runat="server" text="<%$ Resources:Instructions %>" />
    </div><br/>
<table cellspacing="0" cellpadding="5" class="lrbBorders" width="580">
    <tr>
        <td class="callOutStyle"><asp:literal runat="server" text="<%$ Resources:CreateNewRole %>" /></td>
    </tr>
    <tr >
        <td class="bodyTextNoPadding">
               <asp:Label runat="server" AssociatedControlID="textBox1" Text="<%$ Resources:NewRoleName %>"/>
               <asp:textBox runat=server id="textBox1" maxlength="256"/>
               <asp:button runat=server id="button1" text="<%$ Resources:AddRole %>" onClick="AddRole"/><br/>
    <asp:label runat="server" id="errorMessage" enableViewState="false" forecolor="Red" visible="false"/>

        </td>
    </tr>
</table>

<%-- Cause the textbox to submit the page on enter, raising server side onclick--%>
<input type="text" style="visibility:hidden"/>
<br/>
<table cellspacing="0" cellpadding="0" border="0"  width="580">
    <tbody>
    <tr valign="top">
        <td height="100%" class="lrbBorders">
            <asp:gridView runat="server" id="dataGrid" allowpaging="true" autogeneratecolumns="False" border="0"  cellpadding="5" cellspacing="0" OnPageIndexChanging="IndexChanged" pagesize="7" width="100%" UseAccessibleHeader="true">

                <rowStyle cssClass="gridRowStyle" />
                <alternatingRowStyle cssClass="gridAlternatingRowStyle" />
                <footerStyle forecolor="#003399" backcolor="#99CCCC"/>
                <headerStyle cssClass="callOutStyle" font-bold="true" />
                <selectedRowStyle font-bold="True" forecolor="#CCFF99" backcolor="#009999"/>
                <pagerStyle forecolor="#000000" backcolor="#EEEEEE"/>
                <pagersettings mode="Numeric"/>

                <columns >
                    <asp:templateField runat="server" headerText="<%$ Resources:RoleName %>" >
                        <itemTemplate>
                            <%# Container.DataItem %>
                        </itemTemplate>
                    </asp:templateField>

                    <asp:templateField runat="server" headerText="<%$ Resources:AddRemove %>" >
                        <itemTemplate>
                            <asp:linkButton runat="server" id="linkButton1" text="<%$ Resources:Manage %>" commandName="ManageRole" toolTip='<%# GetToolTip("Manage",Container.DataItem.ToString()) %>' commandArgument='<%#Container.DataItem%>' onCommand='LinkButtonClick'/>
                        </itemTemplate>
                    </asp:templateField>

                    <asp:templateField runat="server" >
                        <itemStyle horizontalAlign="center"/>
                        <itemTemplate>
                            <asp:linkButton runat="server" id="linkButton2" text="<%$ Resources:Delete %>" commandName="DeleteRole" toolTip='<%# GetToolTip("Delete",Container.DataItem.ToString()) %>' commandArgument='<%#Container.DataItem%>' onCommand='LinkButtonClick'/>
                        </itemTemplate>
                    </asp:templateField>
                </columns>
            </asp:gridView>
        </td>
    </tr>
    </tbody>
</table>
</asp:content>

<%-- Confirmation Dialog --%>
<asp:content runat="server" contentplaceholderid="dialogTitle">
<asp:literal runat="server" text="<%$ Resources:UserManagement %>" />
</asp:content>

<asp:content runat="server" contentplaceholderid="dialogContent">

    <img src="../../Images/alert_lrg.gif"/>
    <asp:literal runat="server" text="<%$ Resources:AreYouSure %>"/> "<asp:Label runat=server id="RoleName" Font-Bold="true"/>"?
</asp:content>

<asp:content runat="server" contentplaceholderid="dialogBottomLeftButton">
    <asp:Button runat="server" OnClick="Yes_Click" Text="<%$ Resources:Yes %>" width="100"/>
</asp:content>

<asp:content runat="server" contentplaceholderid="dialogBottomRightButton">
    <asp:Button runat="server" OnClick="No_Click" Text="<%$ Resources:No %>" width="100"/>
</asp:content>

