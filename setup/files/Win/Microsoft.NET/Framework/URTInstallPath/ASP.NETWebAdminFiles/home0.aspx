<%@ Page masterPageFile="~/WebAdminNoButtonRow.master" debug="true" inherits="System.Web.Administration.WebAdminPage"%>
<%@ MasterType virtualPath="~/WebAdminNoButtonRow.master" %>

<script runat="server" language="cs">
protected override void OnInit(EventArgs e) {
    if (string.Compare(CurrentRequestUrl, Request.CurrentExecutionFilePath) != 0) {
          PushRequestUrl(Request.CurrentExecutionFilePath);
    }
}

public void Page_Load() {
    string queryStringAppPath = GetQueryStringAppPath();
    string queryStringPhysPath = GetQueryStringPhysicalAppPath();
    string requestAppPath = HttpContext.Current.Request.ApplicationPath;

    if (queryStringPhysPath != null) {
        string webAdminVersion = "aspnet_webadmin\\" + base.UnderscoreProductVersion + "\\";
        if (queryStringPhysPath.EndsWith(webAdminVersion)) {
             WebAdminToolError.Visible = true;
        }
    }
}

</script>

<asp:content runat="server" contentplaceholderid="titleBar">
<asp:literal runat="server" text="<%$ Resources:ProblemWithApp %>"/>
</asp:content>

<asp:content runat="server" contentplaceholderid="content">
<asp:literal runat="server" text="<%$ Resources:ProblemWithAppMessage %>"/>
<asp:literal runat="server" text="<%$ Resources:NoWebAdminAdministration %>" id="WebAdminToolError" Visible="false" />
</asp:content>
