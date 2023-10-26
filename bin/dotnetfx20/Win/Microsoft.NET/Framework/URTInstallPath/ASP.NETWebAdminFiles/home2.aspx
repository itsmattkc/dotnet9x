<%@ Page masterPageFile="WebAdminNoButtonRow.master" inherits="System.Web.Administration.WebAdminPage"%>

<script runat="server" language="cs">
protected override void OnInit(EventArgs e) {
    if (string.Compare(CurrentRequestUrl, Request.CurrentExecutionFilePath) != 0) {
          PushRequestUrl(Request.CurrentExecutionFilePath);
    }
}
</script>

<asp:content runat="server" contentplaceholderid="titleBar">
<asp:literal runat="server" text="<%$ Resources: ToolHasTimedOut %>"/>
</asp:content>

<asp:content runat="server" contentplaceholderid="content">
<table width="100%">
    <tr>
        <td width="62%" class="bodyText" valign="top">
            <div style="font-size:1.5em; font-weight:bold">
		<asp:literal runat="server" text="<%$ Resources:ToolTimedOut %>"/>
            </div>
            <br/><br/><br/><br/><br/>
            <asp:literal runat="server" text="<%$ Resources: ExplainTimeOut %>"/></td>
        <td align="right" valign="bottom" width="38%"></td>
    </tr>
</table>
</asp:content>

