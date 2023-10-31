<%@ Page masterPageFile="~/WebAdminWithConfirmation.master" inherits="System.Web.Administration.SecurityPage"%>
<%@ MasterType virtualPath="~/WebAdminWithConfirmation.master" %>
<%@ Import Namespace="System.Drawing" %>
<%@ Import Namespace="System.Web.Administration" %>
<%@ Import Namespace="System.Web.Configuration" %>
<%@ Import Namespace="System.Web.Hosting" %>

<script runat="server" language="cs">
private const string SELECTED_RULE = "WebAdminSelectedRule";
private const string RULES = "WebAdminRules";
private const string NO_DELETE_RULES = "WebAdminNoDeleteRules";
private const string PARENT_RULE_COUNT = "WebAdminParentRuleCount";
private const string SELECTED_ITEM = "WebAdminSelectedItem";

private int ParentRuleCount {
    get {
        object obj = Session[PARENT_RULE_COUNT];
        return obj != null ? (int) obj : -1;
    }
    set {
        Session[PARENT_RULE_COUNT] = value;
    }
}

private ArrayList NotDeleteableRules {
    get {
        object obj = (ArrayList)Session[NO_DELETE_RULES];
        if (obj != null) {
            return (ArrayList)Session[NO_DELETE_RULES];
        } else {
            return (new ArrayList());
        }
    }
    set {
        Session[NO_DELETE_RULES] = value;
    }
}

private ArrayList Rules {
    get {
        object obj = (ArrayList)Session[RULES];
        if (obj != null) {
            return (ArrayList)Session[RULES];
        } else {
            return (new ArrayList());
        }
    }
    set {
        Session[RULES] = value;
    }
}

private int SelectedRule {
    get {
        object obj = Session[SELECTED_RULE];
        return obj != null ? (int) obj : -1;
    }
    set {
        Session[SELECTED_RULE] = value;
    }
}

private void GetNotDeletableRules(Configuration config) {
    AuthorizationSection notDeleteableAuth = (AuthorizationSection) config.GetSection("system.web/authorization");
    ArrayList arrNoDelete = new ArrayList();
    PropertyInformation propUsers = null;
    PropertyInformation propRoles = null;
    bool entryIsDeletable = false;
    int i = 0;
    foreach (AuthorizationRule entryKeep in notDeleteableAuth.Rules) {
        entryIsDeletable = true;
        propUsers = entryKeep.ElementInformation.Properties["users"];
        propRoles = entryKeep.ElementInformation.Properties["roles"];

        if (propUsers != null) {
            if (propUsers.ValueOrigin == PropertyValueOrigin.Inherited) {
                entryIsDeletable = false;
            }
        }

        if (propRoles != null && entryIsDeletable) {
            if (propRoles.ValueOrigin == PropertyValueOrigin.Inherited) {
                entryIsDeletable = false;
            }
        }

        if (!entryIsDeletable) {
            // store the index in here as to which one is not deletable
            arrNoDelete.Add(i);
        }

        i++;
    }

    Session[NO_DELETE_RULES] = arrNoDelete;
}

private string GetToolTip(string resourceName, string itemName) {
    string tempString = (string) GetLocalResourceObject(resourceName);
    return String.Format((string)GetGlobalResourceObject("GlobalResources","ToolTipFormat"), tempString, itemName);
}

private void BindGrid() {
    string appPath = CurrentPath;
    string parentPath = GetParentPath(appPath);

    Configuration config = OpenWebConfiguration(appPath, true);
    AuthorizationSection auth = (AuthorizationSection) config.GetSection("system.web/authorization");

    Configuration parentConfig = OpenWebConfiguration(parentPath, true);
    AuthorizationSection parentAuth = (AuthorizationSection) parentConfig.GetSection("system.web/authorization");
    ParentRuleCount = parentAuth.Rules.Count;

    GetNotDeletableRules(config);

    ArrayList arr = new ArrayList();
    foreach (AuthorizationRule entry in auth.Rules) {
        arr.Add(entry);
    }

    Session[RULES] = arr;
    dataGrid.DataSource = arr;
    dataGrid.DataBind();
    if (dataGrid.SelectedRow != null) {
        UpdateRowColors(dataGrid, dataGrid.Rows[dataGrid.SelectedRow.RowIndex]); 
    }
}

private void DeleteRule(object sender, EventArgs e) {
    LinkButton button = (LinkButton) sender;
    GridViewRow item = (GridViewRow) button.Parent.Parent;
    AuthorizationRule rule = (AuthorizationRule)Rules[item.RowIndex];
    StringBuilder builder = new StringBuilder();
    builder.Append(rule.Action);
    int i = 0;
    foreach (string u in rule.Users) {
        if (i > 0) {
            builder.Append(", " + u);
        }
        else {
            builder.Append(" " + u);
        }
        i++;
    }
    i = 0;
    foreach (string r in rule.Roles) {
        if (i > 0) {
            builder.Append(", " + r);
        }
        else {
            builder.Append(" " + r);
        }
        i++;
    }
    RuleDescription.Text = builder.ToString();
    Master.SetDisplayUI(true);
    Session["ItemIndex"] = item.RowIndex;
}

private void Yes_Click(object sender, EventArgs e) {    
    Rules.RemoveAt((int)Session["ItemIndex"]);
    UpdateRules();
    dataGrid.SelectedIndex = -1;
    BindGrid();
    Master.SetDisplayUI(false);
}

private void No_Click(object sender, EventArgs e) {
    Master.SetDisplayUI(false);
}


private string GetRoles(object val, bool appendImg) {
    StringBuilder builder = new StringBuilder();
    AuthorizationRule rule = (AuthorizationRule)val;
    if (rule.Roles.Count == 0) {
        return String.Empty;
    }
    for(int i = 0; i < rule.Roles.Count; i++) {
        if (i > 0) {
            builder.Append(", ");
        }
        string role = rule.Roles[i];
        if (role == "*") {
            role = (string)GetLocalResourceObject("BracketAll");
        }
        builder.Append(role);
    }
    if (appendImg) {
        StringBuilder builder2 = new StringBuilder();
        builder2.Append("<img src=\"../../Images/image2.gif\" alt=\"" + (string)GetGlobalResourceObject("GlobalResources", "RoleGif") + " [" + builder.ToString() + "]" + "\"/> ");
        builder2.Append(builder.ToString());
        return builder2.ToString();
    } else {
        return builder.ToString();
    }
}


private string GetUsers(object val, bool appendImg) {
    StringBuilder builder = new StringBuilder();
    AuthorizationRule rule = (AuthorizationRule)val;
    if (rule.Users.Count == 0) {
        return String.Empty;
    }
    for(int i = 0; i < rule.Users.Count; i++) {
        if (i > 0) {
            builder.Append(", ");
        }
        string user = rule.Users[i];
        if (user == "?") {
            user = (string)GetLocalResourceObject("BracketAnonymous");
        }
        else if (user == "*") {
            user = (string)GetLocalResourceObject("BracketAll");
        }
        builder.Append(user);
    }
    if (appendImg) {
        StringBuilder builder2 = new StringBuilder();
        builder2.Append("<img src=\"../../Images/image1.gif\" alt=\"" + (string)GetGlobalResourceObject("GlobalResources", "UserGif") + " [" + builder.ToString() + "]" + "\"/> ");
        builder2.Append(builder.ToString());
        return builder2.ToString();
    } else { 
        return builder.ToString();
    }     
}


private string GetAction(object val) {
    AuthorizationRule rule = (AuthorizationRule)val;
    string ruleAction = "";
    if (rule.Action == AuthorizationRuleAction.Allow) {
        ruleAction = (string)GetLocalResourceObject("Allow");
    } else if (rule.Action == AuthorizationRuleAction.Deny) {
        ruleAction = (string)GetLocalResourceObject("Deny");
    }
    return ruleAction;
}

private string GetUsersAndRoles(object val, bool appendImg) {
    return GetUsers(val, appendImg) + GetRoles(val, appendImg);
}


private bool IsEntryDeleteable(int rowIndex) {
    bool entryIsDeleteable = false;
    if (rowIndex < Rules.Count - ParentRuleCount) {
         entryIsDeleteable = true;
    }
    if (!entryIsDeleteable) {
         return entryIsDeleteable;
    }
    foreach (int index1 in NotDeleteableRules) {
         if (index1 == rowIndex) {
             entryIsDeleteable = false;
         }
    }
    return entryIsDeleteable;
}

private bool IsIE() {
   HttpBrowserCapabilities caps = Page.Request.Browser;
   bool isIE = (caps.Type.IndexOf("IE") > -1);
   return isIE;
}

private void ItemDataBound(object sender, System.Web.UI.WebControls.GridViewRowEventArgs e)
{
   if (e.Row.RowIndex >= Rules.Count - ParentRuleCount) {
       return;
   }
   DataControlRowType itemType = e.Row.RowType;
   if ((itemType == DataControlRowType.Pager) || 
       (itemType == DataControlRowType.Header) || 
       (itemType == DataControlRowType.Footer)) 
   {
      return;
   }

   if (IsIE()) {
       if (IsEntryDeleteable(e.Row.RowIndex)) {
           // if netscape, then selecting the the row
           // will not allow the DeleteRule to fire
           foreach(Control c in e.Row.Cells[0].Controls) {
               LinkButton button = c as LinkButton;
               if (button == null) {
                   continue;
               }
               e.Row.Attributes["onclick"] = Page.GetPostBackClientHyperlink(button, "");
           }
        }
    }
}

private void MoveRuleDown(object sender, EventArgs e) {
    ArrayList rules = Rules;
    int selectedRule = SelectedRule;
    // // Response.Write(selectedRule);

    if(selectedRule >= rules.Count - ParentRuleCount) {
        return;
    }

    AuthorizationRule rule = (AuthorizationRule)rules[selectedRule];
    rules.RemoveAt(selectedRule);
    rules.Insert(selectedRule + 1, rule);
    UpdateRules();
    BindGrid();
    dataGrid.SelectedIndex = selectedRule + 1;
    UpdateRowColors(dataGrid, dataGrid.Rows[selectedRule + 1]);
    SelectedRule = selectedRule + 1;
    UpdateUpDownButtons();
}

private void MoveRuleUp(object sender, EventArgs e) {
    ArrayList rules = Rules;
    int selectedRule = SelectedRule;

    if(selectedRule == 0) {
        return;
    }

    AuthorizationRule rule = (AuthorizationRule)rules[selectedRule];
    rules.RemoveAt(selectedRule);
    rules.Insert(selectedRule - 1, rule);
    UpdateRules();
    BindGrid();
    dataGrid.SelectedIndex = selectedRule - 1;
    UpdateRowColors(dataGrid, dataGrid.Rows[selectedRule - 1]);
    SelectedRule = selectedRule - 1;
    UpdateUpDownButtons();
}

private string GetDirectory(string path) {
    if (path == null) {
        return null;
    }

    if (path.LastIndexOf('/') == -1) {
        return "/";
    }

    return path.Substring(path.LastIndexOf('/') + 1);
}

private void Page_Init() {
    if(!IsPostBack) {
        // Note: treenodes persist when added in Init, before loadViewState
        TreeNode n = new TreeNode(GetDirectory(ApplicationPath), ApplicationPath);
        tv.Nodes.Add(n);
        n.Selected = true;

        if (String.IsNullOrEmpty(CurrentPath)) {
            CurrentPath = ApplicationPath;
        }

        PopulateChildren(n, CurrentPath);
    }
    dataGrid.HeaderStyle.HorizontalAlign = DirectionalityHorizontalAlign;
}

private void Page_Load() {
    if (!IsPostBack) {
        BindGrid();
    }

    HighlightSelectedNode(tv.Nodes[0], CurrentPath);
}

private void PopulateChildren(TreeNode parent, string selectNodeValue) {
    if (parent.ChildNodes.Count == 0) {
        VirtualDirectory vdir = GetVirtualDirectory(parent.Value);
        foreach (VirtualDirectory childVdir in vdir.Directories) {
            string childValue = parent.Value + "/" + childVdir.Name;
            TreeNode newNode = new TreeNode(childVdir.Name, childValue);
            if (selectNodeValue != null && childValue == selectNodeValue) {
                //newNode.Selected = true;
                newNode.SelectAction = TreeNodeSelectAction.Select;
            }
            parent.ChildNodes.Add(newNode);
        }
    }
}

private bool HighlightSelectedNode(TreeNode node, string path) {
    bool foundIt = false;
    foreach (TreeNode childNode in node.ChildNodes) {
        if (childNode.Value == path) {
            childNode.Selected = true;
            foundIt = true;
            break;
        }
    }
    return foundIt;
}

protected void RedirectToCreatePermission(object sender, EventArgs e) {
    Response.Redirect("createPermission.aspx");
}

public void SelectClick(object sender, EventArgs e) {
    LinkButton button = (LinkButton)sender;

    GridViewRow row = (GridViewRow)button.Parent.Parent;
    SelectedRule = row.RowIndex;
    dataGrid.SelectedIndex = SelectedRule;

    UpdateRowColors(dataGrid, row);
    UpdateUpDownButtons();
}

private void SetItemColorRecursive(Control c, Color col) {
    foreach(Control child in c.Controls) {
        LinkButton button = child as LinkButton;
        if (button != null) {
            button.ForeColor = col;
        }
        Label label = child as Label;
        if (label != null) {
            label.ForeColor = col;
        }
        SetItemColorRecursive(child, col);
    }
}

protected void TreeNodeExpanded(Object sender, TreeNodeEventArgs e) {
    foreach(TreeNode child in e.Node.ChildNodes) {
        PopulateChildren(child, CurrentPath);
    }
}

protected void TreeNodeSelected(object sender, EventArgs e) {
    CurrentPath = ((TreeView)sender).SelectedNode.Value;
    dataGrid.SelectedIndex = -1;
    BindGrid();
}

public void UpdateRowColors(Control dataGrid, Control item) {
    if (item == null) {
        // unexpected condition -exit gracefully
        return;
    }

    string prevItemID = (string)Session[SELECTED_ITEM];
    if (prevItemID != null) {
        GridViewRow prevItem = (GridViewRow) ((GridView)dataGrid).FindControl(prevItemID);
        if (prevItem != null) {
            // REVIEW
            SetItemColorRecursive(prevItem, Color.Black);
            // prevButton.ForeColor = Color.Black;
        }
    }

    SetItemColorRecursive(item, Color.White);
    // Review: best practice for a naming container inside a user control.
    string id = item.UniqueID;
    int i = id.IndexOf(((GridView)dataGrid).ID);
    id = id.Substring(i);
    i = id.IndexOf("$");
    id = id.Substring(i + 1);
    Session[SELECTED_ITEM] = id ;
}

private void UpdateRules() {
    Configuration config = OpenWebConfiguration(CurrentPath, true);
    AuthorizationSection auth = (AuthorizationSection) config.GetSection("system.web/authorization");
    auth.Rules.Clear();
    ArrayList rules = Rules;
    foreach (AuthorizationRule rule in rules) {
        // // Response.Write("rule <br/>");
        auth.Rules.Add(rule);
    }

    // auth.IsModified = true;
    SaveConfig(config);
}

private void UpdateUpDownButtons() {
    int index = SelectedRule;
    moveDown.Enabled = (index < Rules.Count - ParentRuleCount - 1);
    moveUp.Enabled = (index > 0); 

}
</script>


<asp:content runat="server" contentplaceholderid="buttons">
<asp:button ValidationGroup="none" runat="server" id="button1" text="<%$ Resources:Done %>" onclick="ReturnToPreviousPage"/>
</asp:content>

<asp:content runat="server" contentplaceholderid="titleBar">
<asp:literal runat="server" text="<%$ Resources:ManageAccessRules %>" />
</asp:content>

<asp:content runat="server" contentplaceholderid="content" >
<asp:literal runat="server" text="<%$ Resources:Instructions %>" />
<table width="100%">
    <tr>
        <td width="80%">
            <table cellspacing="0" width="100%" cellpadding="4" rules="none" bordercolor="#CCDDEF" border="1" style="border-color:#CCDDEF;border-style:None;border-collapse:collapse;">
                <tr class="callOutStyle">
                    <td colspan="3"><asp:literal runat="server" text="<%$ Resources:ManageAccessRules %>"/></td>
                </tr>
                <tr align="=<% DirectionalityHorizontalAlign.ToString(); %>">
                    <td valign="top" width="200px" align="=<% DirectionalityHorizontalAlign.ToString(); %>">

                                    <asp:panel runat="server" id="panel1" scrollbars="auto" height="150px" width="200px" cssclass="bodyTextNoPadding">
                                        <asp:treeView runat="server" id="tv" onSelectedNodeChanged="TreeNodeSelected" onTreeNodeExpanded="TreeNodeExpanded" nodeStyle-cssClass="bodyTextLowPadding" >
                                            <RootNodeStyle ImageUrl="../../images/folder.gif" />
                                            <ParentNodeStyle ImageUrl="../../images/folder.gif" />
                                            <LeafNodeStyle ImageUrl="../../images/folder.gif" />
                                            <nodestyle cssClass="bodyTextLowPadding"/>
                                            <selectedNodeStyle cssClass="bodyTextLowPaddingSelected"/>
                                        </asp:treeView>
                                    </asp:panel>


                    </td>
                    <td valign="top">
                        <asp:gridview runat="server" id="dataGrid" bordercolor="#CCDDEF" allowsorting="true" gridlines="Horizontal"
                            borderstyle="None" cellpadding="4" autogeneratecolumns="False" onrowdatabound="ItemDataBound" width="100%" UseAccessibleHeader="true">

                            <rowstyle cssclass="gridRowStyle" />
                            <alternatingrowstyle cssclass="gridAlternatingRowStyle" />
                            <headerstyle cssclass="callOutStyle" font-bold="true" />
                            <selectedrowstyle cssclass="gridSelectedRowStyle"/>
                            <pagerstyle forecolor="#000000" backcolor="#EEEEEE"/>
                            <pagersettings mode="Numeric"/>

                            <columns>
                                <asp:templatefield headertext="<%$ Resources:Select%>" visible="false">
                                    <itemtemplate>
                                        <asp:linkbutton runat="server" commandname="Select" forecolor='black' onclick="SelectClick" text=""/>
                                    </itemtemplate>
                                </asp:templatefield>

                                <asp:templatefield headertext="<%$ Resources:Permission %>">
                                    <itemtemplate>
                                        <asp:label runat="server" id="select" enabled="<%# IsEntryDeleteable(((GridViewRow) Container).RowIndex) %>" text="<%#GetAction((AuthorizationRule)Container.DataItem)%>"/>
                                    </itemtemplate>
                                </asp:templatefield>

                                <asp:templatefield headertext="<%$ Resources:UsersAndRoles %>">
                                    <itemtemplate>
                                        <asp:linkbutton runat="server" id="selectme" enabled="<%# IsEntryDeleteable(((GridViewRow) Container).RowIndex) %>" forecolor="black" onclick="SelectClick" text="<%#GetUsersAndRoles((AuthorizationRule)Container.DataItem, true)%>"/>
                                    </itemtemplate>
                                </asp:templatefield>

                                <asp:templatefield headertext="<%$ Resources:Delete %>">
                                    <itemtemplate>
                                        <asp:linkbutton runat="server" id="delete" enabled="<%# IsEntryDeleteable(((GridViewRow) Container).RowIndex) %>" forecolor='black' onClick="DeleteRule" text="<%$ Resources:Delete %>" toolTip='<%# GetToolTip("Delete",GetUsersAndRoles((AuthorizationRule)Container.DataItem, false)) %>'/>
                                    </itemtemplate>
                                </asp:templatefield>
                            </columns>
                        </asp:gridview>

                        <asp:linkButton runat="server" id="linkButton1" cssClass="bodyTextNoPadding" text="<%$ Resources:AddNewAccessRule %>" onClick="RedirectToCreatePermission"/>
                    </td>
                    <td valign="top">
                        <asp:button runat="server" id="moveUp" text="<%$ Resources:MoveUp %>" enabled="false" onClick="MoveRuleUp" width="110px"/>
                        <br/>
                        <asp:button runat="server" id="moveDown" text="<%$ Resources:MoveDown %>" enabled="false" onClick="MoveRuleDown" width="110px"/>
                    </td>
                </tr>
            </table>
        </td>
    </tr>
</table>
</asp:content>

<%-- Confirmation Dialog --%>
<asp:content runat="server" contentplaceholderid="dialogTitle">
<asp:literal runat="server" text="<%$ Resources:RuleManagement %>" />
</asp:content>

<asp:content runat="server" contentplaceholderid="dialogContent">

    <img src="../../Images/alert_lrg.gif"/>
    <asp:literal runat="server" text="<%$ Resources:AreYouSure %>" /> "<asp:Label runat=server id="RuleDescription" />"?
</asp:content>

<asp:content runat="server" contentplaceholderid="dialogBottomLeftButton">
    <asp:Button runat="server" OnClick="Yes_Click" Text="<%$ Resources:Yes %>" width="100"/>
</asp:content>

<asp:content runat="server" contentplaceholderid="dialogBottomRightButton">
    <asp:Button runat="server" OnClick="No_Click" Text="<%$ Resources:No %>" width="100"/>
</asp:content>

