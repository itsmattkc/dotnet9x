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
<h1><asp:literal runat="server" text="<%$ Resources: WebSiteAdministrationToolSecurityTab01 %>"/></h1>

<p class=MsoNormal><asp:literal runat="server" text="<%$ Resources: WebSiteAdministrationToolSecurityTab02 %>"/></p>

<h2><asp:literal runat="server" text="<%$ Resources: Introduction01 %>"/></h2>

<p class=MsoNormal><asp:literal runat="server" text="<%$ Resources: Introduction02 %>"/></p>

<p class=MsoNormal><asp:literal runat="server" text="<%$ Resources: Introduction03 %>"/></p>

<ul>
<li><asp:literal runat="server" text="<%$ Resources: Introduction04 %>"/></li>
</ul>

<p class=MsoNormal><asp:literal runat="server" text="<%$ Resources: Introduction05 %>"/></p>

<ul>
<li><asp:literal runat="server" text="<%$ Resources: Introduction06 %>"/></li>
</ul>

<p class=MsoNormal><asp:literal runat="server" text="<%$ Resources: Introduction07 %>"/></p>

<p class=MsoNormal><asp:literal runat="server" text="<%$ Resources: Introduction08 %>"/></p>

<ul>
<li><asp:literal runat="server" text="<%$ Resources: Introduction09 %>"/></li>

<li><asp:literal runat="server" text="<%$ Resources: Introduction10 %>"/></li>

<li><asp:literal runat="server" text="<%$ Resources: Introduction11 %>"/></li>
</ul>

<p class=MsoNormal><asp:literal runat="server" text="<%$ Resources: Introduction12 %>"/></p>

<p class=MsoNormal><asp:literal runat="server" text="<%$ Resources: Introduction13 %>"/></p>

<p class=MsoNormal><asp:literal runat="server" text="<%$ Resources: Introduction14 %>"/></p>

<h2><asp:literal runat="server" text="<%$ Resources: CreatingUsers01 %>"/></h2>

<p class=MsoNormal><asp:literal runat="server" text="<%$ Resources: CreatingUsers02 %>"/></p>

<p class=MsoNormal><asp:literal runat="server" text="<%$ Resources: CreatingUsers03 %>"/></p>

<p class=MsoNormal><asp:literal runat="server" text="<%$ Resources: CreatingUsers04 %>"/></p>

<p class=UI><asp:literal runat="server" text="<%$ Resources: CreatingUsers05 %>"/></p>

<p class=MsoNormal><asp:literal runat="server" text="<%$ Resources: CreatingUsers06 %>"/></p>

<p class=UI><asp:literal runat="server" text="<%$ Resources: CreatingUsers07 %>"/></p>

<p class=MsoNormal><asp:literal runat="server" text="<%$ Resources: CreatingUsers08 %>"/></p>

<p class=UI><asp:literal runat="server" text="<%$ Resources: CreatingUsers09 %>"/></p>

<p class=MsoNormal><asp:literal runat="server" text="<%$ Resources: CreatingUsers10 %>"/></p>

<p class=UI><asp:literal runat="server" text="<%$ Resources: CreatingUsers11 %>"/></p>

<p class=MsoNormal><asp:literal runat="server" text="<%$ Resources: CreatingUsers12 %>"/></p>

<p class=MsoNormal><asp:literal runat="server" text="<%$ Resources: CreatingUsers13 %>"/></p>

<p class=UI><asp:literal runat="server" text="<%$ Resources: CreatingUsers14 %>"/></p>

<p class=MsoNormal><asp:literal runat="server" text="<%$ Resources: CreatingUsers15 %>"/></p>

<p class=UI><asp:literal runat="server" text="<%$ Resources: CreatingUsers16 %>"/></p>

<p class=MsoNormal><asp:literal runat="server" text="<%$ Resources: CreatingUsers17 %>"/></p>

<p class=UI><asp:literal runat="server" text="<%$ Resources: CreatingUsers18 %>"/></p>

<p class=MsoNormal><asp:literal runat="server" text="<%$ Resources: CreatingUsers19 %>"/></p>

<p class=UI><asp:literal runat="server" text="<%$ Resources: CreatingUsers20 %>"/></p>

<p class=MsoNormal><asp:literal runat="server" text="<%$ Resources: CreatingUsers21 %>"/></p>

<h2><asp:literal runat="server" text="<%$ Resources: CreatingRoles01 %>"/></h2>

<p class=MsoNormal><asp:literal runat="server" text="<%$ Resources: CreatingRoles02 %>"/></p>

<p class=MsoNormal><asp:literal runat="server" text="<%$ Resources: CreatingRoles03 %>"/></p>

<p class=MsoNormal><asp:literal runat="server" text="<%$ Resources: CreatingRoles04 %>"/></p>

<p class=MsoNormal><asp:literal runat="server" text="<%$ Resources: CreatingRoles05 %>"/></p>

<p class=MsoNormal><asp:literal runat="server" text="<%$ Resources: CreatingRoles06 %>"/></p>

<p class=MsoNormal><asp:literal runat="server" text="<%$ Resources: CreatingRoles07 %>"/></p>

<p class=MsoNormal><asp:literal runat="server" text="<%$ Resources: CreatingRoles08 %>"/></p>

<h2><asp:literal runat="server" text="<%$ Resources: CreatingAccessRules01 %>"/></h2>

<p class=MsoNormal><asp:literal runat="server" text="<%$ Resources: CreatingAccessRules02 %>"/></p>

<p class=MsoNormal><asp:literal runat="server" text="<%$ Resources: CreatingAccessRules03 %>"/></p>

<p class=MsoNormal><asp:literal runat="server" text="<%$ Resources: CreatingAccessRules04 %>"/></p>

<p class=UI><asp:literal runat="server" text="<%$ Resources: CreatingAccessRules05 %>"/></p>

<p class=MsoNormal><asp:literal runat="server" text="<%$ Resources: CreatingAccessRules06 %>"/></p>

<p class=MsoNormal><asp:literal runat="server" text="<%$ Resources: CreatingAccessRules07 %>"/></p>

<p class=UI><asp:literal runat="server" text="<%$ Resources: CreatingAccessRules08 %>"/></p>

<p class=MsoNormal><asp:literal runat="server" text="<%$ Resources: CreatingAccessRules09 %>"/></p>

<p class=UI><asp:literal runat="server" text="<%$ Resources: CreatingAccessRules10 %>"/></p>

<p class=MsoNormal><asp:literal runat="server" text="<%$ Resources: CreatingAccessRules11 %>"/></p>

<p class=UI><asp:literal runat="server" text="<%$ Resources: CreatingAccessRules12 %>"/></p>

<p class=MsoNormal><asp:literal runat="server" text="<%$ Resources: CreatingAccessRules13 %>"/></p>

<p class=MsoNormal><asp:literal runat="server" text="<%$ Resources: CreatingAccessRules14 %>"/></p>

<p class=UI><asp:literal runat="server" text="<%$ Resources: CreatingAccessRules15 %>"/></p>

<p class=MsoNormal><asp:literal runat="server" text="<%$ Resources: CreatingAccessRules16 %>"/></p>

<p class=MsoNormal><asp:literal runat="server" text="<%$ Resources: CreatingAccessRules17 %>"/></p>

<p class=MsoNormal><asp:literal runat="server" text="<%$ Resources: CreatingAccessRules18 %>"/></p>

<p class=MsoNormal><asp:literal runat="server" text="<%$ Resources: CreatingAccessRules19 %>"/></p>

<p class=MsoNormal><asp:literal runat="server" text="<%$ Resources: CreatingAccessRules20 %>"/></p>

<p class=MsoNormal><asp:literal runat="server" text="<%$ Resources: CreatingAccessRules21 %>"/></p>

<p class=MsoNormal><asp:literal runat="server" text="<%$ Resources: CreatingAccessRules22 %>"/></p>

<h2><asp:literal runat="server" text="<%$ Resources: BehindtheScenes01 %>"/></h2>

<p class=MsoNormal><asp:literal runat="server" text="<%$ Resources: BehindtheScenes02 %>"/></p>

<ul>
<li><asp:literal runat="server" text="<%$ Resources: BehindtheScenes03 %>"/></li>

<li><asp:literal runat="server" text="<%$ Resources: BehindtheScenes04 %>"/></li>
</ul>

<h3><asp:literal runat="server" text="<%$ Resources: Web.configSettings01 %>"/></h3>

<p class=MsoNormal><asp:literal runat="server" text="<%$ Resources: Web.configSettings02 %>"/></p>

<p class=MsoNormal><asp:literal runat="server" text="<%$ Resources: Web.configSettings03 %>"/></p>

<pre>
&lt;?xml version="1.0" encoding="utf-8"?&gt;
&lt;configuration&gt;
    &lt;system.web&gt;
        &lt;authorization&gt;
            &lt;allow roles="administrators" /&gt;
            &lt;deny users="?" /&gt;
        &lt;/authorization&gt;
    &lt;/system.web&gt;
&lt;/configuration&gt;
</pre>
<h3><asp:literal runat="server" text="<%$ Resources: Database01 %>"/></h3>

<p class=MsoNormal><asp:literal runat="server" text="<%$ Resources: Database02 %>"/></p>

<h2><asp:literal runat="server" text="<%$ Resources: MoreInformation01 %>"/></h2>

<p class=MsoNormal><asp:literal runat="server" text="<%$ Resources: MoreInformation02 %>"/></p>

<ul>
<li><asp:literal runat="server" text="<%$ Resources: MoreInformation03 %>"/></li>

<li><asp:literal runat="server" text="<%$ Resources: MoreInformation04 %>"/></li>

<li><asp:literal runat="server" text="<%$ Resources: MoreInformation05 %>"/></li>
</ul>

<h2><asp:literal runat="server" text="<%$ Resources: SeeAlso01 %>"/></h2>

<p><a href="WebAdminHelp.aspx"><asp:literal runat="server" text="<%$ Resources: SeeAlso02 %>"/></a></p>

<p><a href="WebAdminHelp_Application.aspx"><asp:literal runat="server" text="<%$ Resources: SeeAlso03 %>"/></a></p>

<p><a href="WebAdminHelp_Provider.aspx"><asp:literal runat="server" text="<%$ Resources: SeeAlso04 %>"/></a></p>

<p><a href="WebAdminHelp_Internals.aspx"><asp:literal runat="server" text="<%$ Resources: SeeAlso05 %>"/></a></p>

</div>

</asp:content>
