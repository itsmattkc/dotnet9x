<%@ Page masterPageFile="~/WebAdmin.master" inherits="System.Web.Administration.WebAdminPage" %>
<%@ Import Namespace="System.Web.Configuration" %>
<%@ Import Namespace="System.Globalization" %>

<asp:content runat="server" contentplaceholderid="titleBar">
    <asp:literal runat="server" id="AppConfigTitle" text="Help"/>
</asp:content>

<asp:content runat="server" contentplaceholderid="content">

<head>
<title><asp:literal runat="server" text="<%$ Resources: Title00 %>"/></title>

<style id="dynCom" type="text/css">
.section1 {margin-left:25pt;margin-right:50pt}
h1 {font-family:verdana;font-size:1.4em;font-weight:bold}
h2 {font-family:verdana;font-size:1.2em;font-weight:bold;margin-top:50px;margin-bottom:6pt;border-bottom-width:.5pt;border-bottom-style:solid}
h3 {font-family:verdana;font-size:1.1em;font-weight:bold;margin-top:12px;}
h4 {font-family:verdana;font-size:1em;font-weight:bold}
.MsoNormal {font-family:verdana;font-size:1em}
.BulletedList1 {font-family:verdana;font-size:1em}
li {font-family:verdana;font-size:1em;margin-bottom:6pt;margin-top:6pt}
pre {font-family:courier new;font-size:10pt;}
.code {font-family:courier new;font-size:10pt}
.CodeEmbedded {font-family:courier new}
.CodeFeaturedElement{font-family:courier new;font-weight:bold}
.TextinList1 {font-family:verdana;font-size:1em;margin-left:.5in}
.TextinList2 {font-family:verdana;font-size:1em;margin-left:.75in}
.UI {font-family:verdana;color:gray;font-weight:bold}
.LanguageKeyword {font-family:verdana;font-weight:bold}
.UserInputNon-localizable {font-family:verdana;font-weight:bold}
.AlertText {margin-left:.5in;font-family:verdana;font-size:1em}
.AlertTextInList1 {margin-left:.75in;font-family:verdana;font-size:1em}
.AlertTextinList2 {margin-left:1in;font-family:verdana;font-size:1em}
.LabelEmbedded {font-weight:bold;font-family:verdana;}
.LinkID {display: none}
</style>
</head>

<div class=Section1>
<h1><asp:literal runat="server" text="<%$ Resources: WebSiteAdministrationToolProviderTab01 %>"/></h1>

<p class=MsoNormal><asp:literal runat="server" text="<%$ Resources: WebSiteAdministrationToolProviderTab02 %>"/></p>

<h2><asp:literal runat="server" text="<%$ Resources: Introduction01 %>"/></h2>

<p class=MsoNormal><asp:literal runat="server" text="<%$ Resources: Introduction02 %>"/></p>

<ul>
<li><asp:literal runat="server" text="<%$ Resources: Introduction03 %>"/></li>

<li><asp:literal runat="server" text="<%$ Resources: Introduction04 %>"/></li>

<li><asp:literal runat="server" text="<%$ Resources: Introduction05 %>"/></li>
</ul>

<p class=MsoNormal><asp:literal runat="server" text="<%$ Resources: Introduction06 %>"/></p>

<h2><asp:literal runat="server" text="<%$ Resources: ConfiguringProvidersintheWebSiteAdministrationTool01 %>"/></h2>

<p class=MsoNormal><asp:literal runat="server" text="<%$ Resources: ConfiguringProvidersintheWebSiteAdministrationTool02 %>"/></p>

<h2><asp:literal runat="server" text="<%$ Resources: ManagingProviderSettings01 %>"/></h2>

<p class=MsoNormal><asp:literal runat="server" text="<%$ Resources: ManagingProviderSettings02 %>"/></p>

<p class=MsoNormal><asp:literal runat="server" text="<%$ Resources: ManagingProviderSettings03 %>"/></p>

<p class=MsoNormal><asp:literal runat="server" text="<%$ Resources: ManagingProviderSettings04 %>"/></p>

<ul>
<li><asp:literal runat="server" text="<%$ Resources: ManagingProviderSettings05 %>"/></li>

<li><asp:literal runat="server" text="<%$ Resources: ManagingProviderSettings06 %>"/></li>
</ul>

<h3><asp:literal runat="server" text="<%$ Resources: SelectingaSingleProvidervs.DifferentProviders01 %>"/></h3>

<p class=MsoNormal><asp:literal runat="server" text="<%$ Resources: SelectingaSingleProvidervs.DifferentProviders02 %>"/></p>

<p class=MsoNormal><asp:literal runat="server" text="<%$ Resources: SelectingaSingleProvidervs.DifferentProviders03 %>"/></p>

<ul>
<li><asp:literal runat="server" text="<%$ Resources: SelectingaSingleProvidervs.DifferentProviders04 %>"/></li>

<li><asp:literal runat="server" text="<%$ Resources: SelectingaSingleProvidervs.DifferentProviders05 %>"/></li>
</ul>

<h3><asp:literal runat="server" text="<%$ Resources: ConfiguringtheSQLServerProvider01 %>"/></h3>

<p class=MsoNormal><asp:literal runat="server" text="<%$ Resources: ConfiguringtheSQLServerProvider02 %>"/></p>

<p class=MsoNormal><asp:literal runat="server" text="<%$ Resources: ConfiguringtheSQLServerProvider03 %>"/></p>

<p class=MsoNormal><asp:literal runat="server" text="<%$ Resources: ConfiguringtheSQLServerProvider04 %>"/></p>

<p class=MsoNormal><asp:literal runat="server" text="<%$ Resources: ConfiguringtheSQLServerProvider05 %>"/></p>

<pre>
[%system root%]\Microsoft.NET\Framework\versionNumber\aspnet_regsql.exe
</pre>
<p class=MsoNormal><asp:literal runat="server" text="<%$ Resources: ConfiguringtheSQLServerProvider06 %>"/></p>

<h2><asp:literal runat="server" text="<%$ Resources: BehindtheScenes01 %>"/></h2>

<p class=MsoNormal><asp:literal runat="server" text="<%$ Resources: BehindtheScenes02 %>"/></p>

<p class=MsoNormal><asp:literal runat="server" text="<%$ Resources: BehindtheScenes03 %>"/></p>

<pre>
&lt;?xml version="1.0" encoding="utf-8"?&gt;
&lt;configuration&gt;
    &lt;system.web&gt;
        &lt;membership <span class=CodeFeaturedElement>defaultProvider="AspNetSqlMembershipProvider"</span> /&gt;
        &lt;roleManager enabled="true" <span class=CodeFeaturedElement>defaultProvider="AspNetWindowsTokenRoleProvider"</span> /&gt;
        &lt;authentication mode="Forms" /&gt;
    &lt;/system.web&gt;
&lt;/configuration&gt;
</pre>
<h2><asp:literal runat="server" text="<%$ Resources: MoreInformation01 %>"/></h2>

<p class=MsoNormal><asp:literal runat="server" text="<%$ Resources: MoreInformation02 %>"/></p>

<ul>
<li><asp:literal runat="server" text="<%$ Resources: MoreInformation03 %>"/></li>

<li><asp:literal runat="server" text="<%$ Resources: MoreInformation04 %>"/></li>

<li><asp:literal runat="server" text="<%$ Resources: MoreInformation05 %>"/></li>
</ul>

<h2><asp:literal runat="server" text="<%$ Resources: SeeAlso01 %>"/></h2>

<p><a href="WebAdminHelp.aspx"><asp:literal runat="server" text="<%$ Resources: SeeAlso02 %>"/></a></p>

<p><a href="WebAdminHelp_Security.aspx"><asp:literal runat="server" text="<%$ Resources: SeeAlso03 %>"/></a></p>

<p><a href="WebAdminHelp_Application.aspx"><asp:literal runat="server" text="<%$ Resources: SeeAlso04 %>"/></a></p>

<p><a href="WebAdminHelp_Internals.aspx"><asp:literal runat="server" text="<%$ Resources: SeeAlso05 %>"/></a></p>

</div>

</asp:content>
