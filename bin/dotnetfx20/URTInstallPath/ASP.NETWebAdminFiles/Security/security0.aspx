<%@ Page masterPageFile="~/WebAdminButtonRow.master" debug="true" inherits="System.Web.Administration.SecurityPage"%>
<%@ Import Namespace="System.Web.Administration" %>

<script runat="server" language="cs">
public void Page_Load() {
    Exception ex = WebAdminPage.GetCurrentException(Context);
    if (ex != null) {
		exceptionMessageLabel0.Visible = true;
		exceptionMessageLabel1.Text = ex.Message;
	}
}

public void RedirectToChooseProvider(object sender, EventArgs e) {
    PopPrevRequestUrl();
    PushRequestUrl("~/security/security.aspx");
    Response.Redirect("../Providers/chooseProviderManagement.aspx");
}
</script>


<asp:content runat="server" contentplaceholderid="titleBar">
<asp:literal runat="server" text="<%$ Resources: ProblemWithDataStore %>"/>
</asp:content>

<asp:content runat="server" contentplaceholderid="content">
<asp:literal runat="server" text="<%$ Resources: ProblemWithDataStoreExplanation %>"/>
<br/><br/>
<asp:label runat="server" id="exceptionMessageLabel0" text="<%$ Resources: ExceptionMessage %>" visible="false" enableviewstate="false"/>
<asp:label runat="server" font-bold="true" id="exceptionMessageLabel1" enableviewstate="false"/>
</asp:content>

<asp:content runat="server" contentplaceholderid="buttons">
<asp:button ValidationGroup="none" runat="server" id="button1" onClick="RedirectToChooseProvider" text="<%$ Resources: ChooseDataStore %>"/>
</asp:content>

