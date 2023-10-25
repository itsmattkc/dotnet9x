<%@ Control Inherits="System.Web.Administration.WebAdminUserControl"%>
<%@ Import Namespace="System.Web.Configuration" %>
<%@ Import Namespace="System.Web.Administration" %>
<%@ Import Namespace="System.Drawing" %>
<%@ Import Namespace="System.Web.Hosting" %>
<%@ Register TagPrefix="user" TagName="confirmation" Src="confirmation.ascx"%>

<script runat="server" language="cs">

private const string SELECTED_RULE = "WebAdminSelectedRule";
private const string RULES = "WebAdminRules";
private const string NO_DELETE_RULES = "WebAdminNoDeleteRules";
private const string PARENT_RULE_COUNT = "WebAdminParentRuleCount";
private const string APP_PATH = "WebAdminApplicationPath";
private const string CURRENT_PATH = "WebAdminCurrentPath";
private const string SELECTED_ITEM = "WebAdminSelectedItem";


private string CurrentPath {
    get {
        return (string)Session[CURRENT_PATH];
    }
    set {
        Session[CURRENT_PATH] = value;
    }
}

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
        return (ArrayList)Session[NO_DELETE_RULES];
    }
    set {
        Session[NO_DELETE_RULES] = value;
    }
}

private ArrayList Rules {
    get {
        return (ArrayList)Session[RULES];
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

public void AddPermissionRule(string currentPath, TextBox userName, ListControl roles, CheckBox userRadio, CheckBox roleRadio, CheckBox allUsersRadio, CheckBox anonymousUsersRadio, CheckBox grantRadio, CheckBox denyRadio){
    Configuration config = ((WebAdminPage)Page).OpenWebConfiguration(currentPath, true);
    AuthorizationSection auth = (AuthorizationSection)config.GetSection("system.web/authorization");

    AuthorizationRule rule = new AuthorizationRule(grantRadio.Checked ? AuthorizationRuleAction.Allow : AuthorizationRuleAction.Deny);

    if (userRadio.Checked) {
        rule.Users.Add(userName.Text);
    }
    else if (roleRadio.Checked) {
        rule.Roles.Add(roles.SelectedItem.Text);
    }
    else if (allUsersRadio.Checked) {
        rule.Users.Add ("*");
    }
    else if (anonymousUsersRadio.Checked) {
        rule.Users.Add("?");
    }

    auth.Rules.Add(rule);
    ((WebAdminPage)Page).SaveConfig(config);
}

protected void AddRule(object sender, EventArgs e) {
    if(!((WebAdminPage)Page).IsRuleValid(placeholderValidator, userRadio, userName, roleRadio, roles)) {
        return;
    }
    AddPermissionRule(CurrentPath, userName, roles, userRadio, roleRadio, allUsersRadio, anonymousUsersRadio, grantRadio, denyRadio);
    BindGrid();
}

private string GetToolTip(string resourceName, string itemName) {
    string tempString = (string) GetLocalResourceObject(resourceName);
    return String.Format((string)GetGlobalResourceObject("GlobalResources","ToolTipFormat"), tempString, itemName);
}

private void BindGrid() {
    string curPath = CurrentPath;
    string parentPath = WebAdminPage.GetParentPath(curPath);
    
    Configuration config = ((WebAdminPage)Page).OpenWebConfiguration(curPath, true);
    AuthorizationSection auth = (AuthorizationSection) config.GetSection("system.web/authorization");

    Configuration parentConfig = ((WebAdminPage)Page).OpenWebConfiguration(parentPath, true);
    AuthorizationSection parentAuth = (AuthorizationSection) parentConfig.GetSection("system.web/authorization");
    ParentRuleCount = parentAuth.Rules.Count;

    GetNotDeletableRules(config);

    ArrayList arr = new ArrayList();
    foreach (AuthorizationRule entry in auth.Rules) {
        arr.Add(entry);
    }
    Rules = arr;
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

    confirmation.DialogContent.Text = String.Format((string)GetLocalResourceObject("AreYouSure"), builder.ToString());
    mv1.ActiveViewIndex = 1;
    Session["ItemIndex"] = item.RowIndex;
    ((WizardPage)Page).DisableWizardButtons();
}

public void OK_Click(object sender, EventArgs e) {
    Rules.RemoveAt((int)Session["ItemIndex"]);
    UpdateRules();
    BindGrid();
    mv1.ActiveViewIndex = 0;
    ((WizardPage)Page).EnableWizardButtons();
}

public void Cancel_Click(object sender, EventArgs e) {
    mv1.ActiveViewIndex = 0;
    ((WizardPage)Page).EnableWizardButtons();
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

private string GetVirtualPath(string path) {
    if (path == null) {
        return null; // REVIEW: Should not happen.
    }
    return path.Substring("IIS://localhost/W3SVC/1/ROOT".Length);
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

protected override void OnInit(EventArgs e) {
    if(!IsPostBack) {
        string appPath = (string)Session[APP_PATH];
        TreeNode n = new TreeNode(GetDirectory(appPath), appPath);
        tv.Nodes.Add(n);
        n.Selected = true;
        PopulateChildren(n, null);
        CurrentPath = appPath;
    }

    if (!((WebAdminPage)Page).IsRoleManagerEnabled()) {
        ListItem item = new ListItem((string)GetLocalResourceObject("RolesDisabled"));
        roles.Items.Add(item);
        roles.Enabled = false;
        roleRadio.Enabled = false;
        roleRadio.Checked = false;
        userRadio.Checked = true;
        base.OnInit(e);
        return;
    }
    roles.DataSource = (string[]) ((WebAdminPage)Page).CallWebAdminHelperMethod(false, "GetAllRoles", new object[] {}, null);
    roles.DataBind();
    if (roles.Items.Count == 0) {
        ListItem item = new ListItem((string)GetLocalResourceObject("NoRoles"));
        roles.Items.Add(item);
        roles.Enabled = false;
        roleRadio.Enabled = false;
        roleRadio.Checked = false;
        userRadio.Checked = true;
    }
    base.OnInit(e);
}

public void Page_Load() {
    Hashtable coll = ((WebAdminPage)Page).UserCollection;
    if (coll != null && coll.Count > 0) {
        bool first = true;
        StringBuilder builder = new StringBuilder();
        foreach(string s in coll.Keys) {
            if (!first) {
                builder.Append(",");
            }
            else {
                first = false;
            }
            builder.Append(s);
        }
        userName.Text = builder.ToString();        
        ((WebAdminPage)Page).ClearUserCollection();
    }
    BindGrid();
}

public void Page_Init() {
    confirmation.DialogTitle.Text = (string)GetLocalResourceObject("DeleteRule"); 
    confirmation.LeftButton.Click += new EventHandler(OK_Click);
    confirmation.RightButton.Click += new EventHandler(Cancel_Click);
    dataGrid.HeaderStyle.HorizontalAlign = DirectionalityHorizontalAlign;
}

private void PopulateChildren(TreeNode parent, string selectNodeValue) {
    if (parent.ChildNodes.Count == 0) {
        VirtualDirectory vdir = ((WebAdminPage)Page).GetVirtualDirectory(parent.Value);
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


private void SearchForUsers(object sender, EventArgs e) {
     ((WizardPage)Page).SaveActiveView();
     Server.Transfer("../users/findusers.aspx");
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
        PopulateChildren(child, null);
    }
}

protected void TreeNodeSelected(object sender, EventArgs e) {
    CurrentPath = ((TreeView)sender).SelectedNode.Value;
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
    ArrayList rules = Rules;
    Configuration config = ((WebAdminPage)Page).OpenWebConfiguration(CurrentPath, true);
    AuthorizationSection auth = (AuthorizationSection) config.GetSection("system.web/authorization");
    auth.Rules.Clear();
    foreach (AuthorizationRule rule in rules) {
        auth.Rules.Add(rule);
    }

    ((WebAdminPage)Page).SaveConfig(config);
}

</script>
<asp:multiview runat="server" id="mv1" activeViewIndex="0">
    <asp:view runat="server">
        <table width=550 class="bodyTextNoPadding" cellpadding="0" cellspacing="0" border="0"><tr><td>
           <asp:literal runat="server" text="<%$ Resources:Instructions %>"/>
         </td></tr></table>
        <br/>
            <table cellspacing="0" width="550" cellpadding="5" class="lrbBorders">
                <tr class="callOutStyle">
                    <td colspan="2"><asp:literal runat="server" text="<%$ Resources:AddNewAccessRule %>"/></td>
                </tr>
                <tr>
                    <td class="bodyTextNoPadding" width="36%" valign="top"><b><asp:literal runat="server" text="<%$ Resources:SelectDirForRule %>"/></b>
                        <table height="90%" cellspacing="0" cellpadding="4" rules="rows" bordercolor="#CCDDEF" border="0" style="border-color:#CCDDEF;border-style:None;width:100%;border-collapse:collapse;">
                            <tr >
                                <td width="200px" >
                                    <asp:panel runat="server" id="panel1" scrollbars="auto" height="150px" width="200px" cssclass="bodyTextNoPadding">
                                    <asp:treeview runat="server" id="tv" onTreeNodeExpanded="TreeNodeExpanded" onSelectedNodeChanged="TreeNodeSelected" >
                                        <RootNodeStyle ImageUrl="../../images/folder.gif" />
                                        <ParentNodeStyle ImageUrl="../../images/folder.gif" /> 
                                        <LeafNodeStyle ImageUrl="../../images/folder.gif" />
                                    <nodestyle cssclass="bodyTextLowPadding"/>
                                    <selectednodestyle cssclass="bodyTextLowPaddingSelected"/>
                                    </asp:treeview>
        
                                    </asp:panel>
                                </td>
                            </tr>
                        </table>
                    </td>
                    <td height="100%" valign="top">
                        <table height="90%"  border="0" cellpadding="6" cellspacing="0" class="bodyTextNoPadding" height="100%" width="100%" align="middle">
                            <tr>
                                <td width="50%" valign="top" ><b><asp:literal runat="server" text="<%$ Resources:RuleAppliesTo %>"/></b></td>
                                <td valign="top"><b><asp:literal runat="server" text="<%$ Resources:Permission %>"/>:</b></td>
                            </tr>
                            <tr>
                                <td width="62%" valign="top" bgcolor="#EEEEEE">
                                    <asp:radiobutton runat="server" id="roleRadio" checked="true" enableviewstate="false" groupname="rolesUsers" />
                                    <asp:label runat="server" associatedcontrolid="roleRadio"><asp:literal runat="server" text="<%$ Resources:Role %>"/></asp:label>
                                    <asp:dropdownlist runat="server" id="roles" enableviewstate="false" style="position:relative; top:2"/>
                                    </td>
                                <td valign="top" >
                                    <asp:radiobutton runat="server" id="grantRadio" groupname="grantDeny" />
                                           <asp:label runat="server" associatedcontrolid="grantRadio"><asp:literal runat="server" text="<%$ Resources:Allow %>"/></asp:label></td>
                            </tr>
                            <tr>
                                <td width="62%" valign="top" bgcolor="#EEEEEE">
                                    <asp:radiobutton runat="server" id="userRadio" enableviewstate="false" groupname="rolesUsers" />
                                    <asp:label runat="server" associatedcontrolid="userRadio"><asp:literal runat="server" text="<%$ Resources:User %>"/></asp:label>
                                    <asp:textbox runat="server" id="userName" style="position:relative; left:10" size="12"/>
                                    </td>
                                <td valign="top">
                                    <%--<input type="radio" checked="checked" name="R1" onclick="javascript:nyiAlert()">--%>
                                    <asp:radioButton runat="server" id="denyRadio" checked="true" groupName="grantDeny"/>
                                    <asp:label runat="server" associatedcontrolid="denyRadio"><asp:literal runat="server" text="<%$ Resources:Deny %>"/></asp:label></td>
                            </tr>
                            <tr>
                                <td width="62%" valign="top" bgcolor="#EEEEEE">
                                    <asp:radiobutton runat="server" id="allUsersRadio" groupname="rolesUsers" />
                                    <asp:label runat="server" associatedcontrolid="allUsersRadio"><asp:literal runat="server" text="<%$ Resources:AllUsers %>"/></asp:label></td>
                                <td>&nbsp;</td>
                            </tr>
                            <tr>
                                <td width="62%" valign="top" bgcolor="#EEEEEE">
                                    <asp:radiobutton runat="server" id="anonymousUsersRadio" groupname="rolesUsers" />                                     
                                    <asp:label runat="server" associatedcontrolid="anonymousUsersRadio"><asp:literal runat="server" text="<%$ Resources:AnonymousUsers %>"/></asp:label></td>
                                <td valign="bottom"><asp:button runat=server id="add" onClick="AddRule" text="<%$ Resources:AddThisRule %>"/></td>
                            </tr>
                            <tr><td><asp:linkbutton runat="server" onclick="SearchForUsers" text="<%$ Resources:SearchForUsers %>"/></td></tr>
                        </table>
                    </td>
                </tr>
                
            </table>
            <asp:customvalidator runat="server" id="placeholderValidator" enableclientscript="false" errormessage="<%$ Resources:InvalidInput %>" display="dynamic"/>
        <br/>
        <span class="bodyTextNoPadding"><asp:literal runat="server" text="<%$ Resources:DimmedRules %>"/>
        </span>                
        <br/><br/>
        
                    <asp:gridview runat="server" id="dataGrid" class="lrbBorders" width="550" allowsorting="true" gridlines="Horizontal" borderstyle="None" cellpadding="5" autogeneratecolumns="False" onrowdatabound="ItemDataBound" UseAccessibleHeader="true">
                    
                    <rowstyle cssclass="gridRowStyle" />
                    <alternatingrowstyle cssclass="gridAlternatingRowStyle" />
                    <headerstyle cssclass="callOutStyle" font-bold=true />
                    <selectedrowstyle cssclass="gridSelectedRowStyle"/>
        
                    <columns>

                    <asp:templatefield headertext="<%$ Resources:Permission %>">
                    <itemtemplate>
                    <asp:label runat="server" id="select" enabled="<%# IsEntryDeleteable(((GridViewRow) Container).RowIndex) %>" forecolor="<%# ((GridViewRow) Container).RowIndex < Rules.Count - ParentRuleCount ? Color.Black : Color.Gray %>" text="<%#GetAction((AuthorizationRule)Container.DataItem)%>"/>
                    </itemtemplate>
                    </asp:templatefield>
        
                    <asp:templatefield headertext="<%$ Resources:UsersAndRoles %>">
                    <itemtemplate>
                    <asp:label runat="server" enabled="<%# IsEntryDeleteable(((GridViewRow) Container).RowIndex) %>" forecolor="black" text="<%#GetUsersAndRoles((AuthorizationRule)Container.DataItem, true)%>"/>
                    </itemtemplate>
                    </asp:templatefield>

                    <asp:templatefield headertext="<%$ Resources:Delete %>">
                    <itemtemplate>
                    <asp:linkbutton runat="server" id="delete" enabled="<%# IsEntryDeleteable(((GridViewRow) Container).RowIndex) %>" forecolor='black' onClick="DeleteRule" text="<%$ Resources:Delete %>" toolTip='<%# GetToolTip("Delete",GetUsersAndRoles((AuthorizationRule)Container.DataItem, false)) %>' />
                    </itemtemplate>
                    </asp:templatefield>
        
                    </columns>
                    <pagerstyle forecolor="#000000" backcolor="#EEEEEE"/>
                    <pagersettings mode="Numeric"/>
                    </asp:gridview>
                    <asp:panel id=instructions/>
                    </asp:panel>
        <br/>
    </asp:view>
    <asp:view runat="server">
       <user:confirmation runat="server" id="confirmation"/>
    </asp:view>
</asp:multiview>
