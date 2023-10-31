<%@ page masterPageFile="~/WebAdminButtonRow.master" inherits="System.Web.Administration.ApplicationConfigurationPage"%>
<%@ Register TagPrefix="appConfig" TagName="appSetting" Src="appSetting.ascx"%>
<%@ Import Namespace="System.Web.Administration" %>
<%@ Import Namespace="System.Web.Configuration" %>

<script runat="server" language="cs">

private void Page_Load() {
    if (!IsPostBack) {
        string appPath = ApplicationPath;
        if (!String.IsNullOrEmpty(appPath)) {
            EditAppSettingTitle.Text = String.Format((string)GetLocalResourceObject("TitleForSite"), appPath);
        }

        AppSetting.Name = HttpUtility.HtmlDecode(Request["name"]);
        AppSetting.Value = HttpUtility.HtmlDecode(Request["value"]);
    }
}

private void Save(object sender, EventArgs e) {
    if (!IsValid) {
        return;
    }

    Configuration config = OpenWebConfiguration(ApplicationPath);
    AppSettingsSection appSettingsSection = (AppSettingsSection) config.GetSection("appSettings");
    string name = AppSetting.Name;
    string value = AppSetting.Value;
    if (appSettingsSection.Settings[name] == null)
        appSettingsSection.Settings.Add(name,value);
    else
        appSettingsSection.Settings[name].Value = value;
    SaveConfig(config);
    ReturnToPreviousPage(sender, e);
}

</script>

<asp:content runat="server" contentplaceholderid="titleBar">
    <asp:Literal runat="server" id="EditAppSettingTitle" text="<%$ Resources:Title %>"/>
</asp:content>

<asp:content runat="server" contentplaceholderid="content">
    <table height="100%" width="70%" valign="top">
        <tr height="5%">
            <td class="bodyTextNoPadding" valign="top">
                <asp:Literal runat="server" Text="<%$ Resources:Instructions %>"/>
            </td>
        </tr>
        <tr><td/></tr>
        <tr valign="top">
            <td>
                <appConfig:appSetting runat="server" id="AppSetting" OnSave="Save" InEditMode="true"/>
            </td>
        </tr>
    </table>
</asp:content>

<asp:content runat="server" contentplaceholderid="buttons">
    <asp:button ValidationGroup="none" text="<%$ Resources:GlobalResources,BackButtonLabel %>" onclick="ReturnToPreviousPage" runat="server"/>
</asp:content>
