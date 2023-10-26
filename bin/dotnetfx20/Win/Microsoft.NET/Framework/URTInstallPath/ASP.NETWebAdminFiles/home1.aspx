<%@ Page masterPageFile="~/WebAdminNoButtonRow.master" debug="true" inherits="System.Web.Administration.WebAdminPage"%>
<%@ Import Namespace="System.Web.Administration" %>

<script runat="server" language="cs">
protected override void OnInit(EventArgs e) {
    if (string.Compare(CurrentRequestUrl, Request.CurrentExecutionFilePath) != 0) {
          PushRequestUrl(Request.CurrentExecutionFilePath);
    }
}
</script>

<asp:content runat="server" contentplaceholderid="titleBar">
<asp:literal runat="server" text="<%$ Resources:AccessDenied0 %>"/>
</asp:content>

<asp:content runat="server" contentplaceholderid="content">
<asp:literal runat="server" text="<%$ Resources:AccessDenied1 %>"/>
<br/><br/>
</asp:content>

