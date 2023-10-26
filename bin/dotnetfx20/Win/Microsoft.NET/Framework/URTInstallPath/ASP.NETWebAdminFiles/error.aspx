<%@ Page inherits="System.Web.Administration.WebAdminPage"%>
<%@ Import Namespace="System.Web.Administration" %>

<script runat=server language="cs">

protected string GetNormalizedUrl(string page) {
    return Request.ApplicationPath + "/" + page;
}

private string GetAltText(string altText) {
    return (string) GetGlobalResourceObject("GlobalResources", altText);
}

private string GetHelpImage() {
    if (Directionality == "rtl") {
        return GetNormalizedUrl("images/Help.jpg");
    } else {
        return GetNormalizedUrl("images/HelpIcon_solid.gif");
    }
}

protected override void OnInit(EventArgs e) {
    if (string.Compare(CurrentRequestUrl, Request.CurrentExecutionFilePath) != 0) {
          PushRequestUrl(Request.CurrentExecutionFilePath);
    }

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

    linkliteral.Text="<link rel=\"stylesheet\" type=\"text/css\" href=\""+ Request.ApplicationPath + "/webAdminStyles.css\"/>";
}

public void Page_Load() {
    // If a page throws an exception on GET, we should remove it from the stack so that ReturnToPreviousPage doesn't
    // result in an endless loop.
    if (Request.HttpMethod == "GET") {
        ClearBadStackPage();
    }

    DataBind();
    if (!Request.IsLocal) {
        mv1.ActiveViewIndex = 1; 
        button1.Visible = false;
    }
    
    Exception ex = WebAdminPage.GetCurrentException(Context);
    if (ex != null) {
        exceptionMessageLabel0.Visible = true;
        exceptionMessageLabel1.Text = ex.Message + " " + ex.StackTrace;
    }
}

public void Page_PreRender() {
    Stack stack = (Stack) Session["WebAdminUrlStack"];
    if (stack == null || stack.Count <= 1) {
        returnToPrevPagePlaceholder.Visible = false;
    }
}

</script>

<html dir="<%=Directionality%>">
<head>
    <title><asp:literal runat="server" text="<%$ Resources: GlobalResources, PageTitle %>" /> </title>
    <asp:literal runat="server" id="linkliteral"/>
    </head>
<body ms_positioning="GridLayout" leftmargin="0" topmargin="0">
    <form id="Form1" method="post" runat="server">
        <table align="left" border="0" cellpadding="0" cellspacing="0" height="100%" width="100%">
            <tr><td>
            <table width="100%" height="64" cellspacing="0" cellpadding="0" border="0" class="homePageHeader">
                <tr>
                    <td valign="top" nowrap  height="31"><img src="<%# GetNormalizedUrl("images/branding_Full2.gif")%>" width="116" height="30" alt="<%# GetAltText("BrandingFull2Gif") %>" border="0">
                        <span class="webToolBrand">
                        <asp:literal runat="server" text="<%$ Resources: WebAdminTool %>"/>
                        </span>
                    </td>
                    <td align="right" valign="top" nowrap height="31" >
                    <asp:HyperLink runat="server" cssclass="helpHyperLink" NavigateUrl="~/WebAdminHelp.aspx"
                                   tabindex="5" Text="<%$ Resources: HowDoIUse %>"
                    />&nbsp; <img src="<%# GetHelpImage() %>" width="24" height="24" alt="<%# GetAltText("HelpIconSolidGif") %>" border="0" style="position:relative; top: 7">&nbsp;</td>
                </tr><tr><td  width="" height="20" colspan="2" nowrap class="spacerTab">&nbsp;</td></tr>
                </table>
                </td>
                </tr>
                <tr>
                            <td class="bodyText">
                                <asp:multiview runat="server" id="mv1" activeViewIndex="0">
                                <asp:view runat="server">
                                    <asp:literal runat="server" text="<%$ Resources: ErrorEncountered %>"/>                                    
                                    <br/><br/>
                                    <asp:label runat="server" id="exceptionMessageLabel0" text="<%$ Resources: FollowingMayHelp %>" visible="false" enableviewstate="false"/>
                                    <asp:label runat="server" font-bold="true" id="exceptionMessageLabel1" enableviewstate="false"/>
                                </asp:view>
                                <asp:view runat="server">
                                <asp:literal runat="server" text="<%$ Resources: RemoteAccessNotAllowed %>"/>                                    
                                         </asp:view>
                                         </asp:multiview>
                                </tr>
            <tr>
                <td align="right" class="buttonRow" colspan="2" height="100%" valign="bottom">
                <asp:placeholder runat="server" id="returnToPrevPagePlaceholder">
                    <table  width="" height="100%" cellpadding="0" cellspacing="0" border="0">
                        <tr>
                                    <td align="right" valign="bottom">
                                
                                        <table align="right" valign="bottom" cellpadding="0" cellspacing="0" border="0">
                                            <tr>
                                                <asp:literal runat="server" id="yellowCornerElement"/>
                                                <td class="buttonCell" align="left" valign="middle">
                                                    <asp:literal runat="server" id="arrowElement" />            
                                                    &nbsp;&nbsp;
                                                    <asp:button runat="server" id="button1" onClick="ReturnToPreviousPage" text="<%$ Resources:ReturnToPrev %>"/>
                                                </td>
                                                <asp:literal runat="server" id="yellowCornerElementBIDI"/>
                                            </tr>
                                        </table>
                                </td>
                        </tr>
                    </table>
                </asp:placeholder>
                </td>
            </tr>
            <tr>
                <td class="bottomRow" colspan="2" height="31" valign="top">
                </td>
            </tr>
        </table>
    </form>
</body>
</html>
