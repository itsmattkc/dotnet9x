<%@ page masterPageFile="~/WebAdminWithConfirmation.master" inherits="System.Web.Administration.ApplicationConfigurationPage"%>
<%@ Register TagPrefix="appConfig" TagName="appSetting" Src="appSetting.ascx"%>
<%@ Import Namespace="System.Web.Administration" %>
<%@ Import Namespace="System.Web.Configuration" %>

<script runat="server" language="cs">

private WebAdminWithConfirmationMasterPage Master {
    get {
        return (WebAdminWithConfirmationMasterPage)base.Master;
    }
}

private void Page_Load() {
    if (!IsPostBack) {
        string appPath = ApplicationPath;
        if (!String.IsNullOrEmpty(appPath)) {
            AppSettingTitle.Text = String.Format((string)GetLocalResourceObject("TitleForSite"), appPath);
        }
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

    // Check if the name has already existed
    if (appSettingsSection.Settings[name] != null) {
        AppSetting.CustomValidator.IsValid = false;
        AppSetting.CustomValidator.ErrorMessage = (string)GetLocalResourceObject("SettingAlreadyDefinedError");
    }
    else {
        appSettingsSection.Settings.Add(name,value);
        
        SaveConfig(config);

        // Go to confirmation UI
        AppSettingConfirmation.Text = String.Format((string)GetLocalResourceObject("ConfirmationText"), AppSetting.Name);
        Master.SetDisplayUI(true);
    }
}

// Confirmation's related handlers
private void AddAnother_Click(object sender, EventArgs e) {
    AppSetting.ResetUI();
    Master.SetDisplayUI(false);
}

private void OK_Click(object sender, EventArgs e) {
    ReturnToPreviousPage(sender, e);
}

</script>

<%-- Main Content --%>
<asp:content runat="server" contentplaceholderid="titleBar">
    <asp:Literal runat="server" id="AppSettingTitle" Text="<%$ Resources:Title %>"/>
</asp:content>

<asp:content runat="server" contentplaceholderid="content">
    <table height="100%" width="70%" valign="top">
        <tr height="5%">
            <td class="bodyTextNoPadding" valign="top">
                <asp:literal runat="server" Text="<%$ Resources:Instructions %>"/>
            </td>
        </tr>
        <tr><td/></tr>
        <tr valign="top">
            <td>
                <appConfig:appSetting runat="server" id="AppSetting" OnSave="Save"/>
            </td>
        </tr>
    </table>
</asp:content>

<asp:content runat="server" contentplaceholderid="buttons">
    <asp:button ValidationGroup="none" text="<%$ Resources:GlobalResources,BackButtonLabel %>" onclick="ReturnToPreviousPage" runat="server"/>
</asp:content>

<%-- Confirmation Dialog --%>
<asp:content runat="server" contentplaceholderid="dialogTitle">
    <asp:Literal runat="server" Text="<%$ Resources:Title %>"/>
</asp:content>

<asp:content runat="server" contentplaceholderid="dialogContent">
    <asp:Literal runat="server" id="AppSettingConfirmation"/>
</asp:content>

<asp:content runat="server" contentplaceholderid="dialogBottomLeftButton">
    <asp:Button runat="server" OnClick="AddAnother_Click" Text="<%$ Resources:AddAnotherButtonLabel %>" width="140"/>
</asp:content>

<asp:content runat="server" contentplaceholderid="dialogBottomRightButton">
    <asp:Button runat="server" OnClick="OK_Click" Text="<%$ Resources:GlobalResources,OKButtonLabel %>" width="110"/>
</asp:content>
