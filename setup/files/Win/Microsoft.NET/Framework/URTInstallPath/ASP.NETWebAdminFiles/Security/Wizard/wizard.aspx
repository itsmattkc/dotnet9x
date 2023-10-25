<%@ Page Inherits="System.Web.Administration.WizardPage" %>
<%@ Register TagPrefix="user" TagName="authentication" Src="wizardAuthentication.ascx"%>
<%@ Register TagPrefix="user" TagName="createDB" Src="wizardProviderInfo.ascx"%>
<%@ Register TagPrefix="user" TagName="adduser" Src="wizardAddUser.ascx"%>
<%@ Register TagPrefix="user" TagName="createRoles" Src="wizardCreateRoles.ascx"%>
<%@ Register TagPrefix="user" TagName="permissions" Src="wizardPermission.ascx"%>
<%@ Register TagPrefix="user" TagName="finish" Src="wizardFinish.ascx"%>
<%@ Register TagPrefix="user" TagName="init" Src="wizardInit.ascx"%>
<%@ Import Namespace="System.Web.Administration" %>
<%@ Import Namespace="System.Web.Configuration" %>

<script runat="server" language="cs">

private const string SELECTED_NODE = "WebAdminSelectedNode";
private const string COMPLETED_STEP = "WebAdminCompletedStep";

private int CompletedStep {
    get {
        object obj = Page.Session[COMPLETED_STEP];
        return obj == null ? 0 : (int)obj;
    }
    set {
        Page.Session[COMPLETED_STEP] = value;
    }
}

private int SelectedNode {
    get {
        object obj = Session[SELECTED_NODE];
        return obj == null ? 0 : (int)obj;
    }
    set {
        Session[SELECTED_NODE] = value;
    }
}

private void ActiveViewChanged(object sender, EventArgs e) {
    UpdateControls();
}

public void CancelClick(object sender, EventArgs e) {
    Server.Transfer("../security.aspx");
}

public override void DisableWizardButtons() {
    nextButton.Enabled = false;
    prevButton.Enabled = false;
    cancelButton.Enabled = false;
    securityManagement.Visible = false;
}

public override void EnableWizardButtons() {
    UpdateControls();    
    cancelButton.Enabled = true;
    securityManagement.Visible = true;
}

private string GetAltText(string altText) {
    return (string) GetGlobalResourceObject("GlobalResources", altText);
}

public bool IsWindowsAuth() {
    Configuration config = OpenWebConfiguration(ApplicationPath);
    AuthenticationSection auth = (AuthenticationSection)config.GetSection("system.web/authentication");
    return auth.Mode == AuthenticationMode.Windows;
}

// REVIEW: How to keep completed steps in sync with new selections.
public void NavigationTreeNodeChanged(object sender, EventArgs e) {
    TreeView tv = (TreeView) sender;
    int newSelectedIndex = Int32.Parse(tv.SelectedNode.Value);
    centralView.ActiveViewIndex = newSelectedIndex;
    SelectedNode = newSelectedIndex;
    UpdateControls();
    CompletedStep = newSelectedIndex - 1;
}

public void Page_Init() {
    // If returning after leaving a step that wasn't complete, set the correct active view.
    object activeView = Session["WizardActiveView"];
    if (activeView != null) {
        centralView.ActiveViewIndex = (int) activeView;
    }
    Session["WizardActiveView"] = null;

    string htmlText = "<td><img src=\"" + Request.ApplicationPath + "/images/yellowCORNER.gif\" width=\"34\"";
    htmlText = htmlText + " alt=\"" + (string)GetGlobalResourceObject("GlobalResources", "YellowCornerGif") + "\"";
    htmlText = htmlText + " border=\"0\"/></td>";
    if (Directionality == "rtl") {
        yellowCornerElement.Text = "";
        yellowCornerElementBIDI.Text = htmlText;
    } else {
        yellowCornerElement.Text = htmlText;
        yellowCornerElementBIDI.Text = "";
    }

    UpdateControls();
}

public void NextStep(object sender, EventArgs e) {

    if (!((WebAdminUserControl)centralView.GetActiveView().Controls[1]).OnNext()) {
        return;
    }
    if (!IsValid) {
        return;
    }

    // Review: design (perf etc).
    if (centralView.ActiveViewIndex == 1 && IsWindowsAuth()) {
        centralView.ActiveViewIndex = 5;
        UpdateControls();
        return;
    }

    if (centralView.Views.Count - 1 == centralView.ActiveViewIndex) {
        Server.Transfer("../security.aspx");
    }

    centralView.ActiveViewIndex = centralView.ActiveViewIndex + 1;
    UpdateControls();
}

public void Page_Load() {
    nextButton.Focus();
}

private void PrevStep(object sender, EventArgs e) {
    if (!((WebAdminUserControl)centralView.GetActiveView().Controls[1]).OnPrevious()) {
        return;
    }

    // Review: design (perf etc).
    if (centralView.ActiveViewIndex == 5 && IsWindowsAuth()) {
        centralView.ActiveViewIndex = 1;
        UpdateControls();
        return;
    }

    centralView.ActiveViewIndex = centralView.ActiveViewIndex - 1;
    UpdateControls();
}

public override void SaveActiveView() {
    Session["WizardActiveView"] = centralView.ActiveViewIndex;
}

public void UpdateControls() {
    prevButton.Enabled = centralView.ActiveViewIndex > 0;
    navigationTree.Nodes[centralView.ActiveViewIndex].Selected = true;
    nextButton.Enabled = !(centralView.Views.Count - 1 == centralView.ActiveViewIndex);
}
</script>


<html dir="<%=Directionality%>">
<head>
    <title>ASP.Net Web Site Administration Tool</title>
    <link rel="stylesheet" type="text/css" href="../../webAdminStyles.css"/>
</head>
<body leftmargin="0" topmargin="0">
<form runat="server">
    <table border="0" cellpadding="0" cellspacing="0" height="100%" width="100%" >
        <tr>
            <td class="appHeader" colspan="2" height="70" valign="top"><img src="../../images/ASPdotNET_logo.jpg" width="198" height="46" alt="<%#GetAltText("BrandingFull2Gif")%>" border="0">
                <span class="logoText">
                <asp:literal runat="server" text="<%$ Resources:WebAdminTool %>"/>
                </span>
            </td>
        </tr>
        <tr>
            <td class="blueRepeat" colspan="2" height="6" />
            </td>
        </tr>
        <tr>
            <td height="35" class="callOutHeaderStyle" colspan="2" valign="center" ><asp:literal runat="server" text="<%$ Resources: SecuritySetupWizard %>"/></td>
        </tr>
        <tr>
            <td class="darkBlueShadow" height="6"/><td class="lightShadow" height="6"/>
        </tr>
        <tr>
            <%-- REVIEW: Is width working correctly here?  Value seems too small --%>
            <td class="leftWizard" valign="top" width="245px">
                <asp:treeview runat="server" id="navigationTree" backColor="#3266CC" cssClass="leftWizard" forecolor="white" onSelectedNodeChanged="NavigationTreeNodeChanged" width="20px">
                <selectedNodeStyle cssClass="leftWizard" font-bold="true"/>
                <nodeStyle cssClass="leftWizard"/>
                    <nodes>
                        <asp:treenode runat="server" value="0" selectaction="none" selected="true" text="<%$ Resources:Step1Welcome %>"/>
                        <asp:treenode runat="server" value="1" selectaction="none" text="<%$ Resources:Step2AccessMethod %>"/>
                        <asp:treenode runat="server" value="2" selectaction="none" text="<%$ Resources:Step3DataStore %>"/>
                        <asp:treenode runat="server" value="3" selectaction="none" text="<%$ Resources:Step4DefineRoles %>"/>
                        <asp:treenode runat="server" value="4" selectaction="none" text="<%$ Resources:Step5AddUsers %>"/>
                        <asp:treenode runat="server" value="5" selectaction="none" text="<%$ Resources:Step6AddRules %>"/>
                        <asp:treenode runat="server" value="6" selectaction="none" text="<%$ Resources:Step7Complete %>"/>
                    </nodes>
                </asp:treeview>
                <br/><br/><br/>
                <br/><br/><br/>
                <br/><br/><br/><br/><br/><br/>
                 <table border="0">
                <tr>
                    <td style="padding-left:24"><hr style="color:9abbdd;"/></td>
                </tr>
                <tr>
                    <td nowrap="nowrap" style="padding-left:21"><asp:hyperlink id="securityManagement" runat="server" cssClass="leftWizard" text="<%$ Resources:SecurityManagement %>" href="../security.aspx"/> </td></tr>               
                </table>
            </td>
            <%-- Width set to 100% so that width of left hand table cell is correctly rendered. --%>
            <td class="wizardClassNoWatermark" height="100%" valign="top" width="">
                <asp:multiView runat="server" id="centralView" activeViewIndex="0" onActiveViewChanged="ActiveViewChanged">
                    <asp:view runat="server" id="view1">
                        <user:init runat="server" id="init"/>
                    </asp:view>
                    <asp:view runat="server" id="view2">
                        <user:authentication runat="server" id="authentication"/>
                    </asp:view>
                    <asp:view runat="server" id="view3">
                        <user:createDB runat="server" id="createDB"/>
                    </asp:view>
                    <asp:view runat="server" id="view4">
                        <user:createRoles runat="server" id="roles"/>
                    </asp:view>
                    <asp:view runat="server" id="view5">
                        <user:addUser runat="server" id="users"/>
                    </asp:view>
                    <asp:view runat="server" id="view6">
                        <user:permissions runat="server" id="permissions"/>
                    </asp:view>
                    <asp:view runat="server" id="view7">
                        <user:finish runat="server" id="finish"/>
                    </asp:view>
                </asp:multiView>
            </td>
        </tr>
        <tr>
            <td class="leftWizard" width="20"></td>
            <td valign="bottom">
                <table align="right" valign="bottom" width="" height="" cellpadding="0" cellspacing="0" border="0">
                    <tr>
                        <asp:literal runat="server" id="yellowCornerElement"/>
                        <td class="buttonCell" align="left" valign="bottom">&nbsp;&nbsp;
                            <asp:button runat="server" id="prevButton" enabled="false" onClick="PrevStep" text="<%$ Resources:BackButton %>"/>&nbsp;
                            <asp:button runat="server" id="nextButton" onClick="NextStep" text="<%$ Resources:NextButton %>" validationGroup="nextButton"/>&nbsp;&nbsp;&nbsp;
                            <asp:button runat="server" id="cancelButton" onClick="CancelClick" text="<%$ Resources:FinishButton %>"/>
                        </td>
                        <asp:literal runat="server" id="yellowCornerElementBIDI"/>
                    </tr>
                </table>
            </td>
        </tr>
        <tr>
            <td height="3" class="buttonCell" colspan="2"/></td>
        </tr>
    </table>

</form>

</body>

