<%@ Page masterPageFile="~/WebAdmin.master" inherits="System.Web.Administration.ApplicationConfigurationPage"%>
<%@ Import Namespace="System.Web.Configuration" %>
<%@ Import Namespace="System.Globalization" %>

<script runat="server" language="cs">

public void Page_Load() {
    if (!IsPostBack) {
        string appPath = ApplicationPath;
        if (!String.IsNullOrEmpty(appPath)) {
            AppConfigTitle.Text = String.Format((string)GetLocalResourceObject("TitleForSite"), appPath);
        }

        Configuration config = OpenWebConfiguration(appPath);
        AppSettingsSection appSettingsSection = (AppSettingsSection) config.GetSection("appSettings");
        string numOfAppSettings = appSettingsSection.Settings.Count.ToString(CultureInfo.InvariantCulture);
        NumOfAppSettings.Text = String.Format((string)GetLocalResourceObject("NumOfAppSettings"), numOfAppSettings);
    }
    UpdateApplicationOnlineUI();
}

private void ToggleApplicationOnline(object sender, EventArgs e) {
    Configuration config = OpenWebConfiguration(ApplicationPath);
    HttpRuntimeSection httpRuntimeSection = (HttpRuntimeSection) config.GetSection("system.web/httpRuntime");
    bool httpRuntimeSectionEnabled = httpRuntimeSection.Enable;

    httpRuntimeSection.Enable = !httpRuntimeSectionEnabled;
    SaveConfig(config);

    UpdateApplicationOnlineUI();
}

private void UpdateApplicationOnlineUI() {
    Configuration config = OpenWebConfiguration(ApplicationPath);
    HttpRuntimeSection httpRuntimeSection = (HttpRuntimeSection) config.GetSection("system.web/httpRuntime");

    if (httpRuntimeSection.Enable) {
        applicationOnlineState.Text = (string)GetLocalResourceObject("ApplicationStateOnline");
        toggleApplication.Text = (string)GetLocalResourceObject("TakeApplicationOffline");
    }
    else {
        applicationOnlineState.Text = (string)GetLocalResourceObject("ApplicationStateOffline");
        toggleApplication.Text = (string)GetLocalResourceObject("TakeApplicationOnline");
    }
}


</script>


<asp:content runat="server" contentplaceholderid="titleBar">
    <asp:literal runat="server" id="AppConfigTitle" text="<%$ Resources:Title %>"/>
</asp:content>

<asp:content runat="server" contentplaceholderid="content">
    <table height="100%" width="100%" valign="top">
        <tr height="10%">
            <td class="bodyTextNoPadding" colspan="5" valign="top">
                <asp:Literal runat="server" text="<%$ Resources:Instructions %>"/>
            </td>
        </tr>
        <tr>
            <td width="32%" valign="top">
                            <table cellspacing="0" height="100%" width="100%" cellpadding="4" rules="all"
                                   bordercolor="#CCDDEF" border="1" style="border-style:None;border-collapse:collapse;">
                                <tr class="callOutStyle" height="1%">
                                    <td style="padding-left:10;padding-right:10;">
                                        <asp:Literal runat="server" text="<%$ Resources:AppSettingsTitle %>"/>
                                    </td>
                                </tr>
                                <tr class="bodyText" valign="top">
                                    <td style="padding-left:10;padding-right:10;">
                                        <asp:Label runat=server id="NumOfAppSettings"/><br/>
                                        <br/>
                                        <asp:HyperLink id="CreateAppSettingsLink" runat="server" Text="<%$ Resources:CreateAppSettingsLinkText %>" NavigateUrl="CreateAppSetting.aspx"/><br/>
                                        <asp:HyperLink runat="server" Text="<%$ Resources:ManageAppSettingsLinkText %>" NavigateUrl="ManageAppSettings.aspx"/>
                                    </td>
                                </tr>
                            </table>
            </td>
            <td width ="1%"/>
            <td width="34%" valign="top">
                <table cellspacing="0" height="100%" width="100%" cellpadding="0" border="0">
                    <tr height="49%">
                        <td>
                            <table cellspacing="0" height="100%" width="100%" cellpadding="4" rules="all"
                                   bordercolor="#CCDDEF" border="1" style="border-style:None;border-collapse:collapse;">
                                <tr class="callOutStyle">
                                    <td style="padding-left:10;padding-right:10;"><asp:Literal runat="server" text="<%$ Resources:SMTPSettingsTitle %>"/></td>
                                </tr>
                                <tr class="bodyText"  height="100%" valign="top">
                                    <td style="padding-left:10;padding-right:10;">
                                        <asp:HyperLink runat="server" text="<%$ Resources:SMTPSettingsLinkText %>" NavigateUrl="SmtpSettings.aspx"/><br/>
                                    </td>
                                </tr>
                            </table>
                        </td>
                    </tr>
                </table>
            </td>
            <td width ="1%"/>
            <td width="32%" valign="top">
                <table cellspacing="0" height="100%" width="100%" cellpadding="0" border="0">
                    <tr height="49%">
                        <td>
                            <table cellspacing="0" height="100%" width="100%" cellpadding="4" rules="all"
                                   bordercolor="#CCDDEF" border="1" style="border-style:None;border-collapse:collapse;">
                                <tr class="callOutStyle" height="1%">
                                    <td style="padding-left:10;padding-right:10;">
                                        <asp:Literal runat="server" text="<%$ Resources:AppStatusTitle %>"/>
                                    </td>
                                </tr>
                                <tr class="bodyText" valign="top">
                                    <td style="padding-left:10;padding-right:10;">
                                        <asp:Label runat=server id="applicationOnlineState"/><br/>
                                        <br/>
                                        <asp:linkButton runat="server" id="toggleApplication" onclick="ToggleApplicationOnline" />
                                    </td>
                                </tr>
                            </table>
                        </td>
                    </tr>
                    <tr height="2%"><td>&nbsp;</td></tr>
                    <tr height="49%">
                        <td>
                            <table cellspacing="0" height="100%" width="100%" cellpadding="0" rules="all"
                                   bordercolor="#CCDDEF" border="1" style="border-style:None;border-collapse:collapse;">
                                <tr class="callOutStyle">
                                    <td style="padding-left:10;padding-right:10;"><asp:Literal runat="server" text="<%$ Resources:DebugAndTraceTitle %>"/></td>
                                </tr>
                                <tr class="bodyText" height="100%" valign="top">
                                    <td style="padding-left:10;padding-right:10;">
                                        <asp:HyperLink runat="server" text="<%$ Resources:DebugAndTraceLinkText %>" NavigateUrl="DebugAndTrace.aspx"/><br/>
                                        <br/>
                                        <asp:HyperLink runat="server" text="<%$ Resources:DefineErrorPageLinkText %>" NavigateUrl="DefineErrorPage.aspx"/>
                                    </td>
                                </tr>
                            </table>
                        </td>
                    </tr>
                </table>
            </td>
        </tr>
    </table>
</asp:content>

