<%@ Control Inherits="System.Web.Administration.NavigationBar" %>
<%@ Import Namespace="System.Web.Configuration" %>
<%@ Register TagPrefix="admin" Namespace="System.Web.Administration" %>
<%@ Import Namespace="System.Web.Administration" %>
<%@ Import Namespace="System.Web.UI" %>

<script runat="server" language="cs">

int _selectedIndex = 0;
private const string Category_Home = "Home";
private const string Category_Security = "Security";
private const string Category_Application = "Application";
private const string Category_Provider = "Provider";
ArrayList _categoryList = new ArrayList();
private string _directionality;

private string GetCenterClass(int index) {
    if (index == _selectedIndex)
        return "selTabCenter";
    else 
        return "deSTabCenter";
}

private string GetLeftClass(int index) {
    if (Directionality == "rtl") {
        if (index == _selectedIndex)
            return "selTabRight";
        else 
            return "deSTabRight";
    } else {
        if (index == _selectedIndex)
            return "selTabLeft";
        else 
            return "deSTabLeft";
    }
}

private string Directionality {
    get {
        if (String.IsNullOrEmpty(_directionality)) {
            _directionality = ((string) GetGlobalResourceObject("GlobalResources", "HtmlDirectionality")).ToLower();
        }
        return _directionality;
    }
}

private string GetHelpImage() {
    if (Directionality == "rtl") {
        return GetNormalizedUrl("images/Help.jpg");
    } else {
        return GetNormalizedUrl("images/HelpIcon_solid.gif");
    }
}

private string GetLeftImage(int index) {
    if (Directionality == "rtl") {
        if (index == _selectedIndex)
            return GetNormalizedUrl("images/selectedTab_rightCorner.gif");
        else 
            return GetNormalizedUrl("images/unSelectedTab_rightCorner.gif");
    } else {
        if (index == _selectedIndex)
            return GetNormalizedUrl("images/selectedTab_leftCorner.gif");
        else 
            return GetNormalizedUrl("images/unSelectedTab_leftCorner.gif");
    }
}

private string GetRightClass(int index) {
    if (Directionality == "rtl") {
        if (index == _selectedIndex)
            return "selTabLeft";
        else 
            return "deSTabLeft";
    } else {
        if (index == _selectedIndex)
            return "selTabRight";
        else 
            return "deSTabRight";
    }
}

private string GetRightImage(int index) {
    if (Directionality == "rtl") {
        if (index == _selectedIndex)
            return GetNormalizedUrl("images/selectedTab_leftCorner.gif");
        else 
            return GetNormalizedUrl("images/unSelectedTab_leftCorner.gif");
    } else {
        if (index == _selectedIndex)
            return GetNormalizedUrl("images/selectedTab_rightCorner.gif");
        else 
            return GetNormalizedUrl("images/unSelectedTab_rightCorner.gif");
    }
}

private string GetNormalizedUrl(string page) {
    return Request.ApplicationPath + "/" + page;
}

private string GetLocalizedString(string title) {
    
    if (title == Category_Home || 
        title == Category_Security || 
        title == Category_Application || 
        title == Category_Provider) {
        return (string) GetGlobalResourceObject("GlobalResources", title);
    } else {
        return title;
    }
}

private string GetAltText(string altText) {
    return (string) GetGlobalResourceObject("GlobalResources", altText);
}

void Page_Load() {
    if(!Page.IsPostBack) {
        _categoryList = new ArrayList();

        Pair tempPair = new Pair(Category_Home,"default.aspx");
        _categoryList.Add(tempPair);

        tempPair = new Pair(Category_Security,"security/security.aspx");
        _categoryList.Add(tempPair);

        tempPair = new Pair(Category_Application,"appConfig/appConfigHome.aspx");
        _categoryList.Add(tempPair);

        tempPair = new Pair(Category_Provider,"providers/chooseProviderManagement.aspx");
        _categoryList.Add(tempPair);

        imageRepeater.DataSource = _categoryList;
        DataBind();
    }
}

public override void SetSelectedIndex(int index) {
    _selectedIndex = index;
}

private string MouseOver(int index) {
    if (index == _selectedIndex) {
        return String.Empty;
    }
    return "this.className='hoverTabCenter';" + 
        "document.getElementById('left" + index + "').className='hoverTabLeft';" +
        "document.getElementById('right" + index + "').className='hoverTabRight';";
}

private string MouseOut(int index) {
    if (index == _selectedIndex) {
        return String.Empty;
    }
    return "this.className='deSTabCenter';" + 
        "document.getElementById('left" + index + "').className='deSTabLeft';" +
        "document.getElementById('right" + index + "').className='deSTabRight';";
}
</script>
<script language="javascript">
<!--
function __keyPress(event, href) {
    var keyCode;
    if (typeof(event.keyCode) != "undefined") {
        keyCode = event.keyCode;
    }
    else {
        keyCode = event.which;
    }

    if (keyCode == 13) {
        window.location = href;
    }
}
//-->
</script>

            <!-- Top Branding/Navigation Table Region -->
            <table width="100%" height="64" cellspacing="0" cellpadding="0" class="homePageHeader" border="0">
                <tr>
                    <td valign="bottom" nowrap="nowrap"  height="31"><img src="<%#GetNormalizedUrl("images/branding_Full2.gif")%>" width="116" height="30" alt="<%#GetAltText("BrandingFull2Gif")%>" border="0">
                        <span class="webToolBrand">
                        <asp:literal runat="server" text="<%$ Resources: WebSiteAdminTool %>"/>
                        </span>
                    </td>
                    <td align="right" valign="top" nowrap height="31" >
                        <asp:HyperLink runat="server" cssclass="helpHyperLink" NavigateUrl="~/WebAdminHelp.aspx"
                                       tabindex="5" text="<%$ Resources: HowDoIUse %>"
                        />&nbsp; <img src="<%# GetHelpImage() %>" width="24" height="24" alt="<%#GetAltText("HelpIconSolidGif")%>" border="0" style="position:relative; top: 7">&nbsp;</td>
                </tr>
                <tr>
                    <td colspan="2" valign="bottom" nowrap height="33">
                        <%-- Table for the Tab Navigation Model --%>
                        <table id="TabTable" width="100%" cellspacing="0" cellpadding="0" border="0" onselectstart="event.returnValue=false;">
                            <tr>
                                <td  width="4" height="20"  nowrap class="spacerTab">&nbsp;</td>
                                <asp:repeater runat="server" id="imageRepeater">
                                <itemtemplate>

                                <td id='<%# "left" + Container.ItemIndex %>' width="4" height="20" valign="top" nowrap class="<%#GetLeftClass(Container.ItemIndex)%>">
                                <img id='<%# "leftImage" + Container.ItemIndex %>' src="<%#GetLeftImage(Container.ItemIndex)%>" width="4" height="3" alt="" border="0"></td>

                                <td width="81em" height="20" align="center" valign="top" nowrap class="<%#GetCenterClass(Container.ItemIndex)%>" tabindex="0"
                                onclick='window.location = "<%#GetNormalizedUrl((String)((Pair)Container.DataItem).Second)%>"'
                                onmouseover="<%#MouseOver(Container.ItemIndex)%>"  onmouseout="<%#MouseOut(Container.ItemIndex)%>" 
                                 onkeypress="<%# "__keyPress(event, '" + GetNormalizedUrl((String)((Pair)Container.DataItem).Second) + "');" %>">                                 
                                        <%# GetLocalizedString((String) ((Pair)Container.DataItem).First) %>
                                </td>
                                <td id='<%# "right" + Container.ItemIndex %>' width="4" height="20"  align="right" valign="top" nowrap class="<%#GetRightClass(Container.ItemIndex)%>">

                                <img src="<%#GetRightImage(Container.ItemIndex)%>" width="4" height="3" alt="" border="0"></td>
                                <td  width="4" height="20"  nowrap class="spacerTab">
                                &nbsp;
                                </td>
                                </itemtemplate>
                                </asp:repeater>
                                <td  width="" height="20"  nowrap class="spacerTab">&nbsp;</td>
                            </tr>
                        </table>

                    </td>
                </tr>
            </table>




