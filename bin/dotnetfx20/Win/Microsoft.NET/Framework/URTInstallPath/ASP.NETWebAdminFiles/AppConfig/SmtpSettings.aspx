<%@ page masterPageFile="~/WebAdminWithConfirmation.master" inherits="System.Web.Administration.ApplicationConfigurationPage"%>
<%@ register TagPrefix="webadmin" namespace="System.Web.Administration" %>
<%@ Import Namespace="System.Globalization" %>
<%@ Import Namespace="System.Web.Administration" %>
<%@ Import Namespace="System.Web.Configuration" %>
<%@ Import Namespace="System.Net.Configuration" %>

<script runat="server" language="cs">

private enum AuthenticateMode {
    None = 0,
    Basic = 1,
    NTLM = 2,
}

private int PasswordCharLen {
    get {
        object o = ViewState["!PasswordCharLen"];
        if (o == null) {
            return 0;
        }
        return (int)o;
    }
    set {
        ViewState["!PasswordCharLen"] = value;
    }
}

private WebAdminWithConfirmationMasterPage Master {
    get {
        return (WebAdminWithConfirmationMasterPage)base.Master;
    }
}

private void Authentication_ValueChanged(object sender, EventArgs e) {
    ToggleSenderInfoUI(BasicRadioButton.Checked);
}

private void Page_Load() {
    string appPath = ApplicationPath;
    if (!IsPostBack) {
        if (!String.IsNullOrEmpty(appPath)) {
            ConfigureSMTPTitle.Text = String.Format((string)GetLocalResourceObject("TitleForSite"), appPath);
        }

        Configuration config = OpenWebConfiguration(appPath);
        SmtpSection netSmtpMailSection = (SmtpSection) config.GetSection("system.net/mailSettings/smtp");

        ServerNameTextBox.Text = netSmtpMailSection.Network.Host;
        ServerPortTextBox.Text = Convert.ToString(netSmtpMailSection.Network.Port, CultureInfo.InvariantCulture);

        FromTextBox.Text = netSmtpMailSection.From;

        AuthenticateMode authenticateMode;
        if (netSmtpMailSection.Network.DefaultCredentials) {
            authenticateMode = AuthenticateMode.NTLM;
        } else {
            authenticateMode = AuthenticateMode.None;
            if (!String.IsNullOrEmpty(netSmtpMailSection.Network.UserName)) {
                authenticateMode = AuthenticateMode.Basic;
            }
        }
        
        switch (authenticateMode) {
            case AuthenticateMode.None:
                NoneRadioButton.Checked = true;
                break;
            case AuthenticateMode.Basic:
                BasicRadioButton.Checked = true;
                break;
            case AuthenticateMode.NTLM:
                NTLMRadioButton.Checked = true;
                break;
            default:
                throw new Exception((string)GetLocalResourceObject("UnexpectedSmtpField"));
        }

        if (netSmtpMailSection.Network.UserName != null) {
            UserNameTextBox.Text = netSmtpMailSection.Network.UserName;
        }

        PasswordCharLen = 0;
        PasswordTextBox.Text = String.Empty;
        if (netSmtpMailSection.Network.Password != null) {
            PasswordCharLen = netSmtpMailSection.Network.Password.Length;
            
            StringBuilder szFakePassword = new StringBuilder(25);
            for (int i = 0; i < PasswordCharLen; i++) {
                szFakePassword.Append("*");
            }
            
            PasswordTextBox.Text = szFakePassword.ToString();
        }

        ToggleSenderInfoUI(authenticateMode == AuthenticateMode.Basic);
    }
}

private void SaveButton_Click(object sender, EventArgs e) {
    Configuration config = OpenWebConfiguration(ApplicationPath);
    SmtpSection netSmtpMailSection = (SmtpSection) config.GetSection("system.net/mailSettings/smtp");

    netSmtpMailSection.Network.Host = ServerNameTextBox.Text;
    netSmtpMailSection.Network.Port = Convert.ToInt32(ServerPortTextBox.Text, CultureInfo.InvariantCulture);

    netSmtpMailSection.From = FromTextBox.Text;

    AuthenticateMode authenticationMode = AuthenticateMode.None;
    if (NoneRadioButton.Checked) {
        authenticationMode = AuthenticateMode.None;
    }
    else if (BasicRadioButton.Checked) {
        authenticationMode = AuthenticateMode.Basic;
    }
    else {
        authenticationMode = AuthenticateMode.NTLM;
    }


    if (authenticationMode == AuthenticateMode.None) {
        netSmtpMailSection.Network.DefaultCredentials = false;
        netSmtpMailSection.Network.UserName = String.Empty;
        netSmtpMailSection.Network.Password = String.Empty;
    } else if (authenticationMode == AuthenticateMode.Basic) {
        netSmtpMailSection.Network.DefaultCredentials = false;
        netSmtpMailSection.Network.UserName = UserNameTextBox.Text;
        if (PasswordCharLen != 0) {
            StringBuilder szFakePassword = new StringBuilder(25);
            for (int i = 0; i < PasswordCharLen; i++) {
                szFakePassword.Append("*");
            }
        
            if (0 == string.Compare(PasswordTextBox.Text.ToString(),szFakePassword.ToString())) {
                // user didn't change anything, we don't have to re-set something we didn't change.
            }
            else {
                // password was changed, set it
                netSmtpMailSection.Network.Password = PasswordTextBox.Text;
            }
        }
        else {
            netSmtpMailSection.Network.Password = PasswordTextBox.Text;
        }
    } else {
        netSmtpMailSection.Network.DefaultCredentials = true;
        netSmtpMailSection.Network.UserName = String.Empty;
        netSmtpMailSection.Network.Password = String.Empty;
    }

    SaveConfig(config);

    // Go to confirmation UI
    Master.SetDisplayUI(true);
}

private void ToggleSenderInfoUI(bool enabled) {
    UserNameLabel.Enabled = enabled;
    UserNameTextBox.Enabled = enabled;
    PasswordLabel.Enabled = enabled;
    PasswordTextBox.Enabled = enabled;
}

// Confirmation's related handlers
void ConfirmOK_Click(object sender, EventArgs e) {
    ReturnToPreviousPage(sender, e);
}
</script>

<%-- Main Content --%>
<asp:content runat="server" contentplaceholderid="titleBar">
    <asp:Label runat="server" id="ConfigureSMTPTitle" Text="<%$ Resources:Title %>"/>
</asp:content>

<asp:content runat="server" contentplaceholderid="content">
    <table height="100%" width="90%" cellspacing="0" cellpadding="0">
        <tr class="bodyTextNoPadding">
            <td>
                <asp:Literal runat="server" Text="<%$ Resources:Instructions %>"/><br/>
                <br/>
                <asp:Literal runat="server" Text="<%$ Resources:AuthenticationInfoNote %>"/>
            </td>
        </tr>
        <tr>
            <td>
                &nbsp; 
            </td>
        </tr>
        <tr>
            <td>
                <table cellspacing="0" height="100%" width="60%" cellpadding="4" rules="none"
                       bordercolor="#CCDDEF" border="1" style="border-color:#CCDDEF;border-style:None;border-collapse:collapse;">
                    <tr class="callOutStyle">
                        <td style="padding-left:10;padding-right:10;">
                            <asp:Literal runat="server" Text="<%$ Resources:Title %>"/>
                        </td>
                    </tr>
                    <tr>
                        <td style="padding-left:10;padding-right:10;">
                            <table cellspacing="0" height="100%" width="100%" cellpadding="4" border="0">
                                <tr>
                                    <td>
                                        <table class="bodyText" cellspacing="0" height="100%" width="100%" cellpadding="4" border="0">
                                            <tr>
                                                <td nowrap="nowrap" width="1%">
                                                    <asp:Label runat="server" AssociatedControlID="ServerNameTextBox" Text="<%$ Resources:ServerNameLabel %>"/>
                                                </td>
                                                <td>
                                                    <asp:TextBox runat="server" id="ServerNameTextBox"/>
                                                </td>
                                                <td>
                                                </td>
                                            </tr>
                                            <tr>
                                                <td nowrap="nowrap"  width="1%">
                                                    <asp:Label runat="server" AssociatedControlID="ServerPortTextBox" Text="<%$ Resources:ServerPortLabel %>"/>
                                                </td>
                                                <td>
                                                    <asp:TextBox runat="server" id="ServerPortTextBox" />
                                                </td>
                                                <td>
                                                   <asp:CompareValidator id = "compareValNonNegativeInteger" Type="Integer" ControlToValidate="ServerPortTextBox" 
                                                   ValueToCompare="0" Operator="GreaterThan" ErrorMessage="<%$ Resources:NonNegativeServerPort %>"
                                                   runat="server"/>
                                                </td>
                                            </tr>
                                            <tr>
                                                <td nowrap="nowrap" width="1%">
                                                    <asp:Label runat="server" AssociatedControlID="FromTextBox" Text="<%$ Resources:FromLabel %>"/>
                                                </td>
                                                <td>
                                                    <asp:TextBox runat="server" id="FromTextBox" />
                                                </td>
                                                <td>
                                                </td>
                                            </tr>
                                        </table>
                                    </td>
                                </tr>
                            </table>
                        </td>
                    </tr>
                    <tr>
                        <td style="padding-left:10;padding-right:10;">
                            <table cellspacing="0" height="100%" width="100%" cellpadding="4" border="0">
                                <tr>
                                    <td>
                                        <table class="bodyText" cellspacing="0" height="100%" width="100%" cellpadding="4" border="0">
                                            <tr>
                                                <td colspan="4">
                                                    <asp:Label runat="server" Text="<%$ Resources:AuthenticationLabel %>"/>
                                                </td>
                                            </tr>
                                            <tr>
                                                <td width="1%"/>
                                                <td width="1%" valign="top">
                                                    <asp:RadioButton runat="server" id="NoneRadioButton" GroupName="Authentication"
                                                                     AutoPostBack="true" OnCheckedChanged="Authentication_ValueChanged"/>
                                                </td>
                                                <td width="1%">
                                                    <asp:Label runat="server" AssociatedControlID="NoneRadioButton" Text="<%$ Resources:NoneRadioButtonText %>"/>
                                                </td>
                                                <td/>
                                            </tr>
                                            <tr>
                                                <td width="1%"/>
                                                <td width="1%" valign="top">
                                                    <asp:RadioButton runat="server" id="BasicRadioButton" GroupName="Authentication"
                                                                     AutoPostBack="true" OnCheckedChanged="Authentication_ValueChanged"/>
                                                </td>
                                                <td width="1%" colspan="2">
                                                    <asp:Label runat="server" AssociatedControlID="BasicRadioButton" Text="<%$ Resources:BasicRadioButtonText %>"/><br/>
                                                    <asp:Literal runat="server" Text="<%$ Resources:BasicAuthDesc %>"/>
                                                </td>
                                            </tr>
                                            <tr>
                                                <td width="1%"/>
                                                <td width="1%"/>
                                                <td width="1%">
                                                    <asp:Label id="UserNameLabel" runat="server" AssociatedControlID="UserNameTextBox"
                                                               Text="<%$ Resources:SenderUserNameLabel %>"/>
                                                </td>
                                                <td>
                                                    <asp:TextBox runat="server" id="UserNameTextBox"/>
                                                </td>
                                            </tr>
                                            <tr>
                                                <td width="1%"/>
                                                <td width="1%"/>
                                                <td width="1%">
                                                    <asp:Label id="PasswordLabel" runat="server" AssociatedControlID="PasswordTextBox"
                                                               Text="<%$ Resources:SenderPasswordLabel %>"/>
                                                </td>
                                                <td>
                                                    <%-- We need a special password textbox control to retain the text in asterisks in the textbox --%>
                                                    <webadmin:PasswordValueTextBox runat="server" id="PasswordTextBox" />
                                                </td>
                                            </tr>
                                            <tr>
                                                <td width="1%"/>
                                                <td width="1%" valign="top">
                                                    <asp:RadioButton runat="server" id="NTLMRadioButton" GroupName="Authentication"
                                                                     AutoPostBack="true" OnCheckedChanged="Authentication_ValueChanged"/>
                                                </td>
                                                <td width="1%" colspan="2">
                                                    <asp:Label runat="server" AssociatedControlID="NTLMRadioButton" Text="<%$ Resources:NTLMRadioButtonText %>"/><br/>
                                                    <asp:Literal runat="server" Text="<%$ Resources:NTLMAuthDesc %>"/>
                                                </td>
                                            </tr>
                                        </table>
                                    </td>
                                </tr>
                            </table>
                        </td>
                    </tr>
                    <tr class="userDetailsWithFontSize" valign="top" height="100%">
                        <td style="padding-left:10;padding-right:10;" align="right">
                            <asp:Button runat="server" Text="<%$ Resources:GlobalResources,SaveButtonLabel %>" OnClick="SaveButton_Click" width="100"/>
                        </td>
                    </tr>
                </table>
            </td>
        </tr>
        <tr height="100%"><td/></tr>
    </table>
</asp:content>

<asp:content runat="server" contentplaceholderid="buttons">
    <asp:button ValidationGroup="none" text="<%$ Resources:GlobalResources,BackButtonLabel %>" id="BackButton" onclick="ReturnToPreviousPage" runat="server"/>
</asp:content>

<%-- Confirmation Dialog --%>
<asp:content runat="server" contentplaceholderid="dialogTitle">
    <asp:Literal runat="server" Text="<%$ Resources:Title %>"/>
</asp:content>

<asp:content runat="server" contentplaceholderid="dialogContent">
    <table cellspacing="4" cellpadding="4">
        <tr class="bodyText">
            <td>
                <asp:Literal runat="server" Text="<%$ Resources:ConfirmationText %>"/>
            </td>
        </tr>
    </table>
</asp:content>

<asp:content runat="server" contentplaceholderid="dialogBottomLeftLink">
    <asp:HyperLink runat="server" NavigateUrl="AppConfigHome.aspx" Text="<%$ Resources:AppConfigCommon,AppConfigHomeLinkText %>"/>
</asp:content>

<asp:content runat="server" contentplaceholderid="dialogBottomRightButton">
    <asp:Button runat="server" OnClick="ConfirmOK_Click" Text="<%$ Resources:GlobalResources,OKButtonLabel %>" width="75"/>
</asp:content>
