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
<h1><asp:literal runat="server" text="<%$ Resources: WebSiteAdministrationToolApplicationTab01 %>"/></h1>

<p class=MsoNormal><asp:literal runat="server" text="<%$ Resources: WebSiteAdministrationToolApplicationTab02 %>"/></p>

<h2><asp:literal runat="server" text="<%$ Resources: Introduction01 %>"/></h2>

<p class=MsoNormal><asp:literal runat="server" text="<%$ Resources: Introduction02 %>"/></p>

<ul>
<li><asp:literal runat="server" text="<%$ Resources: Introduction03 %>"/></li>
</ul>

<p class=MsoNormal><asp:literal runat="server" text="<%$ Resources: Introduction04 %>"/></p>

<p class=MsoNormal><asp:literal runat="server" text="<%$ Resources: Introduction05 %>"/></p>

<ul>
<li><asp:literal runat="server" text="<%$ Resources: Introduction06 %>"/></li>
</ul>

<p class=MsoNormal><asp:literal runat="server" text="<%$ Resources: Introduction07 %>"/></p>

<ul>
<li><asp:literal runat="server" text="<%$ Resources: Introduction08 %>"/></li>
</ul>

<p class=MsoNormal><asp:literal runat="server" text="<%$ Resources: Introduction09 %>"/></p>

<ul>
<li><asp:literal runat="server" text="<%$ Resources: Introduction10 %>"/></li>
</ul>

<p class=MsoNormal><asp:literal runat="server" text="<%$ Resources: Introduction11 %>"/></p>

<h2><asp:literal runat="server" text="<%$ Resources: ConfiguringApplicationSettings01 %>"/></h2>

<p class=MsoNormal><asp:literal runat="server" text="<%$ Resources: ConfiguringApplicationSettings02 %>"/></p>

<p class=MsoNormal><asp:literal runat="server" text="<%$ Resources: ConfiguringApplicationSettings03 %>"/></p>

<pre>
labelPageHeading.Text = ConfigurationManager.AppSettings("AppName")
</pre>
<p class=MsoNormal><asp:literal runat="server" text="<%$ Resources: ConfiguringApplicationSettings04 %>"/></p>

<p class=MsoNormal><asp:literal runat="server" text="<%$ Resources: ConfiguringApplicationSettings05 %>"/></p>

<pre>
labelPageHeading.Text = ConfigurationManager.AppSettings["AppName"];
</pre>
<h2><asp:literal runat="server" text="<%$ Resources: TakingApplicationsOfflineandOnline01 %>"/></h2>

<p class=MsoNormal><asp:literal runat="server" text="<%$ Resources: TakingApplicationsOfflineandOnline02 %>"/></p>

<p class=MsoNormal><asp:literal runat="server" text="<%$ Resources: TakingApplicationsOfflineandOnline03 %>"/></p>

<h2><asp:literal runat="server" text="<%$ Resources: ConfiguringSMTPSettings01 %>"/></h2>

<p class=MsoNormal><asp:literal runat="server" text="<%$ Resources: ConfiguringSMTPSettings02 %>"/></p>

<p class=MsoNormal><asp:literal runat="server" text="<%$ Resources: ConfiguringSMTPSettings03 %>"/></p>

<p class=MsoNormal><asp:literal runat="server" text="<%$ Resources: ConfiguringSMTPSettings04 %>"/></p>

<p class=MsoNormal><asp:literal runat="server" text="<%$ Resources: ConfiguringSMTPSettings05 %>"/></p>

<p class=MsoNormal><asp:literal runat="server" text="<%$ Resources: ConfiguringSMTPSettings06 %>"/></p>

<p class=MsoNormal><asp:literal runat="server" text="<%$ Resources: ConfiguringSMTPSettings07 %>"/></p>

<p class=MsoNormal><asp:literal runat="server" text="<%$ Resources: ConfiguringSMTPSettings08 %>"/></p>

<p class=MsoNormal><asp:literal runat="server" text="<%$ Resources: ConfiguringSMTPSettings09 %>"/></p>

<p class=UI><asp:literal runat="server" text="<%$ Resources: ConfiguringSMTPSettings10 %>"/></p>

<p class=MsoNormal><asp:literal runat="server" text="<%$ Resources: ConfiguringSMTPSettings11 %>"/></p>

<p class=MsoNormal><asp:literal runat="server" text="<%$ Resources: ConfiguringSMTPSettings12 %>"/></p>

<p class=UI><asp:literal runat="server" text="<%$ Resources: ConfiguringSMTPSettings13 %>"/></p>

<p class=MsoNormal><asp:literal runat="server" text="<%$ Resources: ConfiguringSMTPSettings14 %>"/></p>

<p class=MsoNormal><asp:literal runat="server" text="<%$ Resources: ConfiguringSMTPSettings15 %>"/></p>

<p class=UI><asp:literal runat="server" text="<%$ Resources: ConfiguringSMTPSettings16 %>"/></p>

<p class=MsoNormal><asp:literal runat="server" text="<%$ Resources: ConfiguringSMTPSettings17 %>"/></p>

<p class=MsoNormal><asp:literal runat="server" text="<%$ Resources: ConfiguringSMTPSettings18 %>"/></p>

<p class=UI><asp:literal runat="server" text="<%$ Resources: ConfiguringSMTPSettings19 %>"/></p>

<p class=MsoNormal><asp:literal runat="server" text="<%$ Resources: ConfiguringSMTPSettings20 %>"/></p>

<p class=MsoNormal><asp:literal runat="server" text="<%$ Resources: ConfiguringSMTPSettings21 %>"/></p>

<p class=MsoNormal><asp:literal runat="server" text="<%$ Resources: ConfiguringSMTPSettings22 %>"/></p>

<h2><asp:literal runat="server" text="<%$ Resources: ConfiguringDebuggingandTracing01 %>"/></h2>

<p class=MsoNormal><asp:literal runat="server" text="<%$ Resources: ConfiguringDebuggingandTracing02 %>"/></p>

<p class=MsoNormal><asp:literal runat="server" text="<%$ Resources: ConfiguringDebuggingandTracing03 %>"/></p>

<p class=UI><asp:literal runat="server" text="<%$ Resources: ConfiguringDebuggingandTracing04 %>"/></p>

<p class=MsoNormal><asp:literal runat="server" text="<%$ Resources: ConfiguringDebuggingandTracing05 %>"/></p>

<p class=UI><asp:literal runat="server" text="<%$ Resources: ConfiguringDebuggingandTracing06 %>"/></p>

<p class=MsoNormal><asp:literal runat="server" text="<%$ Resources: ConfiguringDebuggingandTracing07 %>"/></p>

<p class=MsoNormal><asp:literal runat="server" text="<%$ Resources: ConfiguringDebuggingandTracing08 %>"/></p>

<p class=UI><asp:literal runat="server" text="<%$ Resources: ConfiguringDebuggingandTracing09 %>"/></p>

<p class=MsoNormal><asp:literal runat="server" text="<%$ Resources: ConfiguringDebuggingandTracing10 %>"/></p>

<p class=UI><asp:literal runat="server" text="<%$ Resources: ConfiguringDebuggingandTracing11 %>"/></p>

<p class=MsoNormal><asp:literal runat="server" text="<%$ Resources: ConfiguringDebuggingandTracing12 %>"/></p>

<p class=UI><asp:literal runat="server" text="<%$ Resources: ConfiguringDebuggingandTracing13 %>"/></p>

<p class=MsoNormal><asp:literal runat="server" text="<%$ Resources: ConfiguringDebuggingandTracing14 %>"/></p>

<p class=MsoNormal><asp:literal runat="server" text="<%$ Resources: ConfiguringDebuggingandTracing15 %>"/></p>

<p class=UI><asp:literal runat="server" text="<%$ Resources: ConfiguringDebuggingandTracing16 %>"/></p>

<p class=MsoNormal><asp:literal runat="server" text="<%$ Resources: ConfiguringDebuggingandTracing17 %>"/></p>

<p class=UI><asp:literal runat="server" text="<%$ Resources: ConfiguringDebuggingandTracing18 %>"/></p>

<p class=MsoNormal><asp:literal runat="server" text="<%$ Resources: ConfiguringDebuggingandTracing19 %>"/></p>

<p class=UI><asp:literal runat="server" text="<%$ Resources: ConfiguringDebuggingandTracing20 %>"/></p>

<p class=MsoNormal><asp:literal runat="server" text="<%$ Resources: ConfiguringDebuggingandTracing21 %>"/></p>

<p class=MsoNormal><asp:literal runat="server" text="<%$ Resources: ConfiguringDebuggingandTracing22 %>"/></p>

<p class=UI><asp:literal runat="server" text="<%$ Resources: ConfiguringDebuggingandTracing23 %>"/></p>

<p class=MsoNormal><asp:literal runat="server" text="<%$ Resources: ConfiguringDebuggingandTracing24 %>"/></p>

<p class=UI><asp:literal runat="server" text="<%$ Resources: ConfiguringDebuggingandTracing25 %>"/></p>

<p class=MsoNormal><asp:literal runat="server" text="<%$ Resources: ConfiguringDebuggingandTracing26 %>"/></p>

<p class=MsoNormal><asp:literal runat="server" text="<%$ Resources: ConfiguringDebuggingandTracing27 %>"/></p>

<p class=MsoNormal><asp:literal runat="server" text="<%$ Resources: ConfiguringDebuggingandTracing28 %>"/></p>

<p class=MsoNormal><asp:literal runat="server" text="<%$ Resources: ConfiguringDebuggingandTracing29 %>"/></p>

<p class=UI><asp:literal runat="server" text="<%$ Resources: ConfiguringDebuggingandTracing30 %>"/></p>

<p class=MsoNormal><asp:literal runat="server" text="<%$ Resources: ConfiguringDebuggingandTracing31 %>"/></p>

<p class=UI><asp:literal runat="server" text="<%$ Resources: ConfiguringDebuggingandTracing32 %>"/></p>

<p class=MsoNormal><asp:literal runat="server" text="<%$ Resources: ConfiguringDebuggingandTracing33 %>"/></p>

<h2><asp:literal runat="server" text="<%$ Resources: BehindtheScenes01 %>"/></h2>

<p class=MsoNormal><asp:literal runat="server" text="<%$ Resources: BehindtheScenes02 %>"/></p>

<h3><asp:literal runat="server" text="<%$ Resources: ApplicationSettings01 %>"/></h3>

<p class=MsoNormal><asp:literal runat="server" text="<%$ Resources: ApplicationSettings02 %>"/></p>

<pre>
&lt;configuration&gt;
    &lt;appSettings&gt;
        &lt;add key="ApplicationName" value="MyApplication" /&gt;
    &lt;/appSettings&gt;
&lt;/configuration&gt;
</pre>
<h3><asp:literal runat="server" text="<%$ Resources: TakingApplicationsOfflineandOnline01 %>"/></h3>

<p class=MsoNormal><asp:literal runat="server" text="<%$ Resources: TakingApplicationsOfflineandOnline02 %>"/></p>

<pre>
&lt;configuration&gt;
    &lt;system.Web&gt;
        &lt;httpRuntime enable="False" /&gt;
    &lt;/system.Web&gt;
&lt;/configuration&gt; 
</pre>
<p class=MsoNormal><asp:literal runat="server" text="<%$ Resources: TakingApplicationsOfflineandOnline03 %>"/></p>

<h3><asp:literal runat="server" text="<%$ Resources: SMTPSettings01 %>"/></h3>

<p class=MsoNormal><asp:literal runat="server" text="<%$ Resources: SMTPSettings02 %>"/></p>

<pre>
&lt;configuration&gt;
    &lt;system.net&gt;
        &lt;mailSettings&gt;
            &lt;smtp&gt;
                &lt;network 
                    host="smtp.myhost.com" /&gt;
            &lt;/smtp&gt;
        &lt;/mailSettings&gt;
    &lt;/system.net&gt;
&lt;/configuration&gt;
</pre>
<h3><asp:literal runat="server" text="<%$ Resources: DebuggingandTracing01 %>"/></h3>

<p class=MsoNormal><asp:literal runat="server" text="<%$ Resources: DebuggingandTracing02 %>"/></p>

<pre>
&lt;configuration&gt;
    &lt;system.Web&gt;
        &lt;customErrors defaultRedirect="~/myErrorPage.aspx" /&gt;
        &lt;trace enabled="True" pageOutput="True" localOnly="True" 
                traceMode="SortByCategory"
            requestLimit="10" mostRecent="True" /&gt;
        &lt;compilation debug="True" /&gt;
    &lt;/system.Web&gt;
&lt;/configuration&gt;
</pre>
<p class=MsoNormal><asp:literal runat="server" text="<%$ Resources: DebuggingandTracing03 %>"/></p>

<h2><asp:literal runat="server" text="<%$ Resources: MoreInformation01 %>"/></h2>

<p class=MsoNormal><asp:literal runat="server" text="<%$ Resources: MoreInformation02 %>"/></p>

<ul>
<li><asp:literal runat="server" text="<%$ Resources: MoreInformation03 %>"/></li>

<li><asp:literal runat="server" text="<%$ Resources: MoreInformation04 %>"/></li>

<li><asp:literal runat="server" text="<%$ Resources: MoreInformation05 %>"/></li>

<li><asp:literal runat="server" text="<%$ Resources: MoreInformation06 %>"/></li>
</ul>

<h2><asp:literal runat="server" text="<%$ Resources: SeeAlso01 %>"/></h2>

<p><a href="WebAdminHelp.aspx"><asp:literal runat="server" text="<%$ Resources: SeeAlso02 %>"/></a></p>

<p><a href="WebAdminHelp_Security.aspx"><asp:literal runat="server" text="<%$ Resources: SeeAlso03 %>"/></a></p>

<p><a href="WebAdminHelp_Provider.aspx"><asp:literal runat="server" text="<%$ Resources: SeeAlso04 %>"/></a></p>

<p><a href="WebAdminHelp_Internals.aspx"><asp:literal runat="server" text="<%$ Resources: SeeAlso05 %>"/></a></p>

</div>

</asp:content>
