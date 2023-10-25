<%@ Page masterPageFile="~/WebAdminButtonRow.master" inherits="System.Web.Administration.SecurityPage"%>

<%@ Import Namespace="System.Web.Configuration" %>
<%@ Import Namespace="System.Web.Administration" %>
<%@ Import Namespace="System.Web.Hosting" %>

<script runat="server" language="cs">

public void AddPermissionRule(string currentPath, TextBox userName, ListControl roles, CheckBox userRadio, CheckBox roleRadio, CheckBox allUsersRadio, CheckBox anonymousUsersRadio, CheckBox grantRadio, CheckBox denyRadio){
    Configuration config = OpenWebConfiguration(currentPath, true);
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
    this.SaveConfig(config);
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
    base.OnInit(e);
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
}

public void Page_Init() {
    if (IsWindowsAuth()) {
        findUsersLink.Visible = false;
    }
}

public void Page_Load() {
    if(!IsPostBack) {
        if (IsRoleManagerEnabled()) {
            roles.DataSource = (string[])CallWebAdminHelperMethod(false, "GetAllRoles", new object[] {}, null);
            roles.DataBind();
            if (roles.Items.Count == 0) {
                ListItem item = new ListItem((string)GetLocalResourceObject("NoRoles"));
                roles.Items.Add(item);
                roles.Enabled = false;
                roleRadio.Enabled = false;
                roleRadio.Checked = false;
                userRadio.Checked = true;
            }
        }
        else {
            ListItem item = new ListItem((string)GetLocalResourceObject("RolesDisabled"));
            roles.Items.Add(item);
            roles.Enabled = false;
            roleRadio.Enabled = false;
            roleRadio.Checked = false;
            userRadio.Checked = true;
        }

        StringBuilder builder = new StringBuilder();
        bool firstTime = true;
        foreach(string mu in UserCollection.Keys) {
            if (!firstTime) {
                builder.Append(",");
            }
            else {
                firstTime = false;
            }
            builder.Append(mu);
        }
        userName.Text = builder.ToString();
    }
    HighlightSelectedNode(tv.Nodes[0], CurrentPath);
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

protected void TreeNodeExpanded(Object sender, TreeNodeEventArgs e) {
    foreach(TreeNode child in e.Node.ChildNodes) {
        PopulateChildren(child, CurrentPath);
    }
}

protected void TreeNodeSelected(object sender, EventArgs e) {
    CurrentPath = ((TreeView)sender).SelectedNode.Value;
}

protected void UpdateAndReturnToPreviousPage(object sender, EventArgs e) {
    ClearUserCollection();
    if(!IsRuleValid(placeholderValidator, userRadio, userName, roleRadio, roles)) {
        return;
    }
    AddPermissionRule(CurrentPath, userName, roles, userRadio, roleRadio, allUsersRadio, anonymousUsersRadio, grantRadio, denyRadio);
    ReturnToPreviousPage(sender, e);
}

</script>


<asp:content runat="server" contentplaceholderid="buttons">
<asp:button ValidationGroup="none" runat="server" id="button1" text="<%$ Resources:OK %>" onclick="UpdateAndReturnToPreviousPage" width="110"/>
<asp:button runat="server" id="button2" text="<%$ Resources:Cancel %>" onclick="ReturnToPreviousPage" width="110"/>
</asp:content>

<asp:content runat="server" contentplaceholderid="titleBar">
<asp:literal runat="server" text="<%$ Resources:AddNewAccess %>" />
</asp:content>

<asp:content runat="server" contentplaceholderid="content" >
<div style="width:80%">
<asp:literal runat="server" text="<%$ Resources:Instructions %>" />
    </div>
<table width="80%">
    <tr>
        <td width="80%">
            <table cellspacing="0" width="100%" cellpadding="4" rules="all" bordercolor="#CCDDEF" border="1" style="border-color:#CCDDEF;border-style:None;border-collapse:collapse;">
                <tr class="callOutStyle">
                    <td colspan="2"><asp:literal runat="server" text="<%$ Resources:AddNewAccess %>" /></td>
                </tr>

                <tr>
                                <td class="bodyTextNoPadding" width="200px" >
                                    <b><asp:literal runat="server" text="<%$ Resources:SelectDirForRule %>"/></b>
                                    <asp:panel runat="server" id="panel1" scrollbars="auto" height="150px" width="200px" cssclass="bodyTextNoPadding">
                                    <asp:treeview runat="server" id="tv" onTreeNodeExpanded="TreeNodeExpanded" onSelectedNodeChanged="TreeNodeSelected">
                                        <RootNodeStyle ImageUrl="../../images/folder.gif" />
                                        <ParentNodeStyle ImageUrl="../../images/folder.gif" />
                                        <LeafNodeStyle ImageUrl="../../images/folder.gif" />
                                    <nodestyle cssclass="bodyTextLowPadding"/>
                                    <selectednodestyle cssclass="bodyTextLowPaddingSelected"/>
                                    </asp:treeview>

                                    </asp:panel>
                                </td>
                    <td height="100%" valign="top">
                        <table border="0" cellpadding="0" cellspacing="0" class="bodyTextNoPadding" height="100%" width="100%" align="center">
                            <tr>
                                <td width="50%"><b><asp:literal runat="server" text="<%$ Resources:RuleAppliesTo %>"/></b></td>
                                <td><b><asp:literal runat="server" text="<%$ Resources:Permission %>"/></b></td>
                            </tr>
                            <tr>
                                <td width="62%">
                                    <asp:radiobutton runat="server" id="roleRadio" checked="true" groupname="rolesUsers" />
                                    <asp:label runat="server" associatedcontrolid="roleRadio"><asp:literal runat="server" text="<%$ Resources:Role %>"/></asp:label>
                                    <asp:dropdownlist runat="server" id="roles"/>
                                    </td>
                                <td>
                                    <asp:radiobutton runat="server" id="grantRadio" groupname="grantDeny" />
                                    <asp:label runat="server" associatedcontrolid="grantRadio"><asp:literal runat="server" text="<%$ Resources:Allow %>"/></asp:label></td>
                            </tr>
                            <tr>
                                <td width="62%">
                                    <asp:radiobutton runat="server" id="userRadio" groupname="rolesUsers" />
                                    <asp:label runat="server" associatedcontrolid="userRadio"><asp:literal runat="server" text="<%$ Resources:User %>"/></asp:label>
                                    <asp:textbox runat="server" id="userName"/>
                                    <br/><asp:hyperlink runat="server" id="findUsersLink" navigateUrl="../users/findusers.aspx"><asp:literal runat="server" text="<%$ Resources:SearchForUsers %>"/></asp:hyperlink>
                                    </td>
                                <td>
                                    <asp:radioButton runat="server" id="denyRadio" checked="true" groupName="grantDeny"/>
                                    <asp:label runat="server" associatedcontrolid="denyRadio"><asp:literal runat="server" text="<%$ Resources:Deny %>"/></asp:label>
                                </td>
                            </tr>
                            <tr>
                                <td width="62%">
                                    <asp:radiobutton runat="server" id="allUsersRadio" groupname="rolesUsers" />
                                    <asp:label runat="server" associatedcontrolid="allUsersRadio"><asp:literal runat="server" text="<%$ Resources:AllUsers %>"/></asp:label></td>
                                <td>&nbsp;</td>
                            </tr>
                            <tr>
                                <td width="62%">
                                    <asp:radiobutton runat="server" id="anonymousUsersRadio" groupname="rolesUsers" />
                                    <asp:label runat="server" associatedcontrolid="anonymousUsersRadio"><asp:literal runat="server" text="<%$ Resources:AnonymousUsers %>"/></asp:label></td>
                                <td></td>
                            </tr>
                        </table>
                    </td>
                </tr>
            </table>
        </td>
    </tr>
</table>
<asp:customvalidator runat="server" id="placeholderValidator" enableclientscript="false" errormessage="Invalid input" display="dynamic"/>
</asp:content>

