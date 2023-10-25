<%@ Control %>
<%@ Import Namespace="System.Web.Administration" %>
<%@ Import Namespace="System.Web.Configuration" %>
<%@ Import Namespace="System.Globalization" %>

<script runat="server" language="cs">
public Literal DialogContent {
    get {
        return dialogContent;
    }
}

public Literal DialogTitle {
    get {
        return dialogTitle;
    }
}

public Button LeftButton {
    get {
        return leftButton;
    }
}

public Button RightButton {
    get {
        return rightButton;
    }
}
</script>


<table height="100%" width="100%">
            <tr height="70%">
                <td width="60%">
                    <table cellspacing="0" height="100%" width="100%" cellpadding="4" rules="none"
                           bordercolor="#CCDDEF" border="1" style="border-color:#CCDDEF;border-style:None;border-collapse:collapse;">
                        <tr class="callOutStyle">
                            <td style="padding-left:10;padding-right:10;" colspan="3">
                                <asp:literal runat="server" id="dialogTitle"/>
                            </td>
                        </tr>
                        <tr class="bodyText" height="100%" valign="top">
                            <td style="padding-left:10;padding-right:10;" colspan="3">
                                <asp:literal runat="server" id="dialogContent"/>
                            </td>
                        </tr>
                        <tr class="userDetailsWithFontSize" valign="top" height="5%">
                            <td style="padding-left:10;padding-right:10;" align="left"><%-- place holder for a link. --%></td>
                            <td style="padding-left:10;padding-right:10;" align="right"><asp:button runat="server" id="leftButton" forecolor="black" text="<%$ Resources:OkButton %>" width="75"/></td>
                            <td style="padding-left:10;padding-right:10;" align="right" width="1%">
                                <asp:button runat="server" id="rightButton" forecolor="black" text="<%$ Resources:CancelButton %>" width="75"/>
                            </td>
                        </tr>
                    </table>
                </td>
                <td/>
            </tr>
            <tr><td colspan="2"/></tr>            
</table>
