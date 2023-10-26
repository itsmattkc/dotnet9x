<%@ Page masterPageFile="~/WebAdminButtonRow.master" inherits="System.Web.Administration.ApplicationConfigurationPage"%>
<%@ Import Namespace="System.Web.Configuration" %>
<%@ Import Namespace="System.Globalization" %>

<script runat="server" language="cs">

private void BackToPreviousPage(object sender, EventArgs e) {
    ReturnToPreviousPage(sender, e);
}

private void Page_Load() {
    if (!IsPostBack) {
        Configuration config = OpenWebConfiguration(ApplicationPath);
        CompilationSection compilationSection = (CompilationSection) config.GetSection("system.web/compilation");
        EnableDebugCheckBox.Checked = compilationSection.Debug;

        TraceSection traceSection = (TraceSection) config.GetSection("system.web/trace");
        DisplayTraceInfoCheckBox.Checked = traceSection.PageOutput;
        DisplayTraceOutputList.SelectedIndex = (traceSection.LocalOnly) ? 0 : 1;

        EnableTraceCheckBox.Checked = traceSection.Enabled;
        SortTraceList.SelectedIndex = (traceSection.TraceMode == TraceDisplayMode.SortByCategory) ? 1 : 0;

        MostRecentTracesList.SelectedIndex = (traceSection.MostRecent) ? 0 : 1;

        int requestLimit = traceSection.RequestLimit;
        switch (traceSection.RequestLimit) {
            case 5:
                RequestLimitList.SelectedIndex = 0;
                break;
            case 15:
                RequestLimitList.SelectedIndex = 2;
                break;
            case 20:
                RequestLimitList.SelectedIndex = 3;
                break;
            case 25:
                RequestLimitList.SelectedIndex = 4;
                break;
            case 30:
                RequestLimitList.SelectedIndex = 5;
                break;
            case 35:
                RequestLimitList.SelectedIndex = 6;
                break;
            case 40:
                RequestLimitList.SelectedIndex = 7;
                break;
            case 45:
                RequestLimitList.SelectedIndex = 8;
                break;
            case 50:
                RequestLimitList.SelectedIndex = 9;
                break;
            default:
                RequestLimitList.SelectedIndex = 1;
                break;
        }

        if (!traceSection.Enabled) {
            ToggleTraceSettingsElements(false);
        }
    }
}

private void ToggleTraceSettingsElements(bool enabled) {
    DisplayTraceInfoCheckBox.Enabled = enabled;
    DisplayTraceOutputList.Enabled = enabled;
    SortTraceList.Enabled = enabled;
    RequestLimitList.Enabled = enabled;
    MostRecentTracesList.Enabled = enabled;
}

private void WebControl_ValueChanged(object sender, EventArgs e) {
    Control control = (Control) sender;
    Configuration config = OpenWebConfiguration(ApplicationPath);
    TraceSection traceSection = (TraceSection) config.GetSection("system.web/trace");

    switch (control.ID) {
        case "EnableDebugCheckBox":
            CompilationSection compilationSection = (CompilationSection) config.GetSection("system.web/compilation");
            compilationSection.Debug = EnableDebugCheckBox.Checked;
            break;
        case "DisplayTraceInfoCheckBox":
            traceSection.PageOutput = DisplayTraceInfoCheckBox.Checked;
            break;
        case "DisplayTraceOutputList":
            traceSection.LocalOnly = (DisplayTraceOutputList.SelectedIndex == 0);
            break;
        case "EnableTraceCheckBox":
            traceSection.Enabled = EnableTraceCheckBox.Checked;
            ToggleTraceSettingsElements(traceSection.Enabled);
            break;
        case "SortTraceList":
            traceSection.TraceMode = (SortTraceList.SelectedIndex == 0) ? TraceDisplayMode.SortByTime : TraceDisplayMode.SortByCategory;
            break;
        case "RequestLimitList":
            traceSection.RequestLimit = Convert.ToInt32(RequestLimitList.SelectedItem.Value, CultureInfo.InvariantCulture);
            break;
        case "MostRecentTracesList":
            traceSection.MostRecent = (MostRecentTracesList.SelectedIndex == 0) ? true : false;
            break;
        // TODO: Remove the exception as this is to capture development error where a control event has not been handled.
        //       Note that it does not need to be localized.
        default:
            throw new HttpException((string)GetLocalResourceObject("InvalidId") + control.ID);
    }

    SaveConfig(config);
}

</script>


<asp:content runat="server" contentplaceholderid="titleBar">
    <asp:Literal runat="server" Text="<%$ Resources:Title %>"/>
</asp:content>

<asp:content runat="server" contentplaceholderid="content">
    <table height="100%" width="100%" valign="top">
        <tr height="1%">
            <td class="bodyTextNoPadding" colspan="4" valign="top">
                <asp:Literal runat="server" Text="<%$ Resources:Instructions %>"/>
            </td>
        </tr>
        <tr valign="top">
            <td>
                <table>
                    <tr>
                        <td>&nbsp;</td>
                        <td valign="top">
                            <table cellspacing="0" height="100%" width="100%" cellpadding="4" rules="all"
                                   border="0" style="border-style:None;border-collapse:collapse;">
                                <tr class="bodyText" valign="top">
                                    <td>
                                        <asp:CheckBox runat="server" id="EnableDebugCheckBox" AutoPostBack="true"
                                                      OnCheckedChanged="WebControl_ValueChanged"
                                        />&nbsp;<asp:Label runat="server" AssociatedControlID="EnableDebugCheckBox" Text="<%$ Resources:EnableDebugLabel %>"/>
                                    </td>
                                </tr>
                                <tr class="bodyText" valign="top">
                                    <td>
                                        <asp:CheckBox runat="server" id="EnableTraceCheckBox" AutoPostBack="true"
                                                      OnCheckedChanged="WebControl_ValueChanged"
                                        />&nbsp;<asp:Label runat="server" AssociatedControlID="EnableTraceCheckBox" Text="<%$ Resources:EnableTraceLabel %>"/>
                                    </td>
                                </tr>
                                <tr height="1%"><td><hr/></td></tr>
                                <tr class="bodyText" valign="top">
                                    <td>
                                        <asp:CheckBox runat="server" id="DisplayTraceInfoCheckBox" AutoPostBack="true"
                                                      OnCheckedChanged="WebControl_ValueChanged"
                                        />&nbsp;<asp:Label runat="server" AssociatedControlID="DisplayTraceInfoCheckBox" Text="<%$ Resources:DisplayTraceInfoLabel %>"/>
                                    </td>
                                </tr>
                                <tr valign="top">
                                    <td>
                                        <asp:Label runat="server" cssClass="bodyTextNoPadding" Text="<%$ Resources:DisplayTraceOutputForLabel %>"/>
                                        <asp:RadioButtonList runat=server id="DisplayTraceOutputList" AutoPostBack="true"
                                                             cssClass="bodyText" OnSelectedIndexChanged="WebControl_ValueChanged">
                                            <asp:ListItem Text="<%$ Resources:LocalRequestsOnlyListItemText %>"/>
                                            <asp:ListItem Text="<%$ Resources:AllRequestsListItemText %>"/>
                                        </asp:RadioButtonList>
                                    </td>
                                </tr>
                                <tr height="1%"><td><hr/></td></tr>
                                <tr valign="top">
                                    <td style="padding-right:10;">
                                        <asp:Label runat="server" cssClass="bodyTextNoPadding" Text="<%$ Resources:SortOrderForTraceResultsLabel %>"/>
                                        <asp:RadioButtonList runat=server id="SortTraceList" AutoPostBack="true"
                                                             cssClass="bodyText" OnSelectedIndexChanged="WebControl_ValueChanged">
                                            <asp:ListItem Text="<%$ Resources:ByTimeListItemText %>"/>
                                            <asp:ListItem Text="<%$ Resources:ByCategoryListItemText %>"/>
                                        </asp:RadioButtonList>
                                    </td>
                                </tr>
                                <tr height="1%"><td><hr/></td></tr>
                                <tr valign="top">
                                    <td style="padding-right:10;">
                                        <asp:Label runat="server" cssClass="bodyTextNoPadding" Text="<%$ Resources:NumberOfTraceRequestsToCache %>"/>
                                        <asp:DropDownList runat=server id="RequestLimitList" AutoPostBack="true"
                                                          cssClass="bodyText" OnSelectedIndexChanged="WebControl_ValueChanged">
                                            <asp:ListItem Value="5"/>
                                            <asp:ListItem Value="10"/>
                                            <asp:ListItem Value="15"/>
                                            <asp:ListItem Value="20"/>
                                            <asp:ListItem Value="25"/>
                                            <asp:ListItem Value="30"/>
                                            <asp:ListItem Value="35"/>
                                            <asp:ListItem Value="40"/>
                                            <asp:ListItem Value="45"/>
                                            <asp:ListItem Value="50"/>
                                        </asp:DropDownList>
                                    </td>
                                </tr>
                                <tr height="1%"><td><hr/></td></tr>
                                <tr valign="top">
                                    <td style="padding-right:10;">
                                        <asp:Label runat="server" cssClass="bodyTextNoPadding" Text="<%$ Resources:WhichTraceResultsToCacheLabel %>"/>
                                        <asp:RadioButtonList runat=server id="MostRecentTracesList" AutoPostBack="true"
                                                             cssClass="bodyText" OnSelectedIndexChanged="WebControl_ValueChanged">
                                            <asp:ListItem Text="<%$ Resources:MostRecentTraceResultsListItemText %>"/>
                                            <asp:ListItem Text="<%$ Resources:OldestTraceResultsListItemText %>"/>
                                        </asp:RadioButtonList>
                                    </td>
                                </tr>
                                <tr class="bodyText" valign="top">
                                    <td style="padding-right:10;">
                                        <asp:HyperLink runat="server" Text="<%$ Resources:ConfigureCustomErrorPagesLinkText %>" NavigateUrl="DefineErrorPage.aspx"/>
                                    </td>
                                </tr>
                            </table>
                        </td>
                    </tr>
                </table>
            </td>
            <td width ="4%"/>
        </tr>
    </table>
</asp:content>

<asp:content runat="server" contentplaceholderid="buttons">
    <asp:button ValidationGroup="none" Text="<%$ Resources:GlobalResources,BackButtonLabel %>" id="BackButton" onclick="BackToPreviousPage" runat="server"/>
</asp:content>
