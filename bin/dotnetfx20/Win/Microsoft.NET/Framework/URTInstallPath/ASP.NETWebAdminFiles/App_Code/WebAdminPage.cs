//------------------------------------------------------------------------------
// <copyright file="WebAdminPage.cs" company="Microsoft">
//     Copyright (c) Microsoft Corporation.  All rights reserved.
// </copyright>
//------------------------------------------------------------------------------

namespace System.Web.Administration {
    using System.Collections;
    using System.Collections.Specialized;
    using System.Configuration;
    using System.Diagnostics;
    using System.Globalization;
    using System.Reflection;
    using System.Security;
    using System.Text;
    using System.Web;
    using System.Web.Configuration;
    using System.Web.Hosting;
    using System.Web.Management;
    using System.Web.Security;
    using System.Web.SessionState;
    using System.Web.UI;
    using System.Web.UI.WebControls;
    using System.Security.Permissions;

    [AspNetHostingPermission(SecurityAction.LinkDemand, Level=AspNetHostingPermissionLevel.Minimal)]
    [AspNetHostingPermission(SecurityAction.InheritanceDemand, Level=AspNetHostingPermissionLevel.Minimal)]
    public class WebAdminPage : Page {
        private const string APP_PATH = "WebAdminApplicationPath";
        private const string APP_PHYSICAL_PATH = "WebAdminPhysicalPath";
        private const string CURRENT_EXCEPTION = "WebAdminCurrentException";
        private const string CURRENT_PROVIDER = "WebAdminCurrentProvider";
        private const string CURRENT_ROLE = "WebAdminCurrentRoleName";
        private const string CURRENT_USER = "WebAdminCurrentUser";
        private const string CURRENT_USER_COLLECTION = "WebAdminUserCollection";
        private const string URL_STACK = "WebAdminUrlStack";
        private string _directionality;
        private NavigationBar _navigationBar = null;

        public WebAdminRemotingManager RemotingManager {
            get {
                return (WebAdminRemotingManager)Session["WebAdminRemotingManager"];
            }
        }

        public object CallWebAdminHelperMethod(bool isMembership, string methodName, object[] parameters, Type[] paramTypes) {
            object returnObject = null;
            object tempObject = null;

            tempObject = RemotingManager.ConfigurationHelperInstance;
            if (tempObject != null) {
                string methodName2 = string.Empty;
                string typeFullName = WebAdminRemotingManager.AssemblyVersionString;
                if (isMembership) {
                    methodName2 = "CallMembershipProviderMethod";
                } else {
                    methodName2 = "CallRoleProviderMethod";
                }
                Type tempType = Type.GetType(typeFullName);

                BindingFlags allBindingFlags = BindingFlags.Instance | BindingFlags.Public | BindingFlags.NonPublic;
                MethodInfo method = tempType.GetMethod(methodName2, allBindingFlags);
                if (method != null) {
                    object[] newParameters = new object[]{methodName, parameters, paramTypes};
                    try {
                        object[] returnArrayObj = (object[]) method.Invoke(tempObject, newParameters);
                        if (returnArrayObj != null) {
                            returnObject = returnArrayObj[0];
                        }
                    } catch (Exception ex) {
                        if (ex.InnerException != null) {
                            if (ex.InnerException.InnerException != null) {
                                throw new WebAdminException(ex.InnerException.InnerException.Message);
                            } else {
                                throw new WebAdminException(ex.InnerException.Message);
                            }
                        } else {
                            throw new WebAdminException(ex.Message);
                        }
                    }
                }
            }

            return returnObject;
        }

        public VirtualDirectory GetVirtualDirectory(string virtualDir) {
            return RemotingManager.GetVirtualDirectory(virtualDir);
        }

        public void SaveConfig(Configuration config) {
            RemotingManager.ShutdownTargetApplication();
            config.NamespaceDeclared = true;

            // check if session expired
            if (String.IsNullOrEmpty(ApplicationPath) || String.IsNullOrEmpty((string)Session[APP_PHYSICAL_PATH])) {
                Server.Transfer("~/home2.aspx");
            }

            config.Save(ConfigurationSaveMode.Minimal);
        }


        public string ApplicationPath {
            get {
                return (string)Session[APP_PATH];
            }
        }

        protected virtual bool CanSetApplicationPath {
            get {
                return false;
            }
        }

        protected string CurrentProvider {
            get {
                object obj = (object)Session[CURRENT_PROVIDER];
                if (obj != null) {
                    return (string)Session[CURRENT_PROVIDER];
                } 
                return String.Empty;
            }
            set {
                Session[CURRENT_PROVIDER] = value;
            }
        }

        protected string CurrentRequestUrl {
            get {
                Stack stack = (Stack) Session[URL_STACK];
                if (stack != null && stack.Count > 0) {
                    return(string)stack.Peek();
                }
                return string.Empty;
            }
        }

        protected string CurrentRole {
            get {
                object obj = (object)Session[CURRENT_ROLE];
                if (obj != null) {
                    return (string)Session[CURRENT_ROLE];
                }
                return String.Empty;
            }
            set {
                Session[CURRENT_ROLE] = value;
            }
        }

        protected string CurrentUser {
            get {
                object obj = (string)Session[CURRENT_USER];
                if (obj != null) {
                    return (string)Session[CURRENT_USER];
                }
                return String.Empty;
            }
            set {
                Session[CURRENT_USER] = value;
            }
        }

        public string Directionality {
            get {
                if (String.IsNullOrEmpty(_directionality)) {
                    _directionality = ((string) GetGlobalResourceObject("GlobalResources", "HtmlDirectionality")).ToLower();
                }
                return _directionality;
            }
        }

        public HorizontalAlign DirectionalityHorizontalAlign {
           get {
                if (Directionality == "rtl") {
                    return HorizontalAlign.Right;
                } else {
                    return HorizontalAlign.Left;
                }
           }
        }

        public Hashtable UserCollection {
            get {
                Hashtable table = (Hashtable) Session[CURRENT_USER_COLLECTION];
                if (table == null) {
                    Session[CURRENT_USER_COLLECTION] = table = new Hashtable();
                }
                return table;
            }
        }

        public NavigationBar NavigationBar {
            get {
                return _navigationBar;
            }
            set {
                _navigationBar = value;
            }
        }

        public string UnderscoreProductVersion {
            get {
                return Environment.Version.ToString(3).Replace(".", "_");
            }
        }

        public static Exception GetCurrentException(HttpContext c) {
            return (Exception)c.Session[CURRENT_EXCEPTION];
        }

        public static void SetCurrentException(HttpContext c, Exception ex) {
            c.Session[CURRENT_EXCEPTION] = ex;
        }

        protected void ClearBadStackPage() {
            Stack stack = (Stack) Session[URL_STACK];
            if (stack == null || stack.Count < 2) {
                return;
            }
            stack.Pop(); // current url
            stack.Pop(); // prev url
            // push current url back on stack.
            if (string.Compare(CurrentRequestUrl, Request.CurrentExecutionFilePath) != 0) {
                PushRequestUrl(Request.CurrentExecutionFilePath);
            }
        }

        public void ClearUserCollection() {
            Session[CURRENT_USER_COLLECTION] = null;
        }

        public static string GetParentPath(string path) {
            if (String.IsNullOrEmpty(path) || path[0] != '/')
                return null;

            int index = path.LastIndexOf('/');
            if (index < 0)
                return null;

            // parent for the root app is machine.config (null)
            if (path == "/")
                return null;

            string returnPath = path.Substring(0, index);
            if (returnPath.Length == 0 || returnPath == "/") {
               // for cassini, if returning /
               // then return null instead.
                returnPath = null;
            }

            return returnPath;
        }
       
        protected string GetQueryStringAppPath() {
            return Request.QueryString["applicationUrl"];
        }

        protected string GetQueryStringPhysicalAppPath() {
            return Request.QueryString["applicationPhysicalPath"];
        }

        public bool IsRoleManagerEnabled() {
            try {
                RoleManagerSection roleSection = null;
                Configuration config = OpenWebConfiguration(ApplicationPath);
                roleSection = (RoleManagerSection)config.GetSection("system.web/roleManager");
                return roleSection.Enabled;
            } catch {
                return false;
            }
        }

        public bool IsRuleValid(BaseValidator placeHolderValidator, RadioButton userRadio, TextBox userName, RadioButton roleRadio, DropDownList roles) {
            if (userRadio.Checked && userName.Text.Trim().Length == 0) {
                placeHolderValidator.ErrorMessage = ((string)GetGlobalResourceObject("GlobalResources", "NonemptyUser"));
                placeHolderValidator.IsValid = false;
                return false;
            }
            if (roleRadio.Checked && roles.SelectedItem == null) {
                placeHolderValidator.ErrorMessage = ((string)GetGlobalResourceObject("GlobalResources", "NonemptyRole"));
                placeHolderValidator.IsValid = false;
                return false;
            }
            if (userRadio.Checked) {
                string userNameString = userName.Text.Trim();
                if (-1 != userNameString.IndexOf('*')) {
                    placeHolderValidator.ErrorMessage = ((string)GetGlobalResourceObject("GlobalResources", "InvalidRuleName"));
                    placeHolderValidator.IsValid = false;
                    return false;
                }
            }
            return true;
        }

        public bool IsWindowsAuth() {
            Configuration config = OpenWebConfiguration(ApplicationPath);
            AuthenticationSection auth = (AuthenticationSection)config.GetSection("system.web/authentication");
            return auth.Mode == AuthenticationMode.Windows;
        }

        protected void ItemDataBound(object sender, System.Web.UI.WebControls.DataGridItemEventArgs e) {
            ListItemType itemType = e.Item.ItemType;
            if ((itemType == ListItemType.Pager) ||
                (itemType == ListItemType.Header) ||
                (itemType == ListItemType.Footer)) {
                return;
            }
            foreach (Control c in e.Item.Cells[0].Controls) {
                LinkButton button = c as LinkButton;
                if (button == null) {
                    continue;
                }
                e.Item.Attributes["onclick"] = GetPostBackClientHyperlink(button, String.Empty);
           }
        }

        public Configuration OpenWebConfiguration(string path) {
            return OpenWebConfiguration(path, false);
        }

        public Configuration OpenWebConfiguration(string path, bool getWebConfigForSubDir) {
            string appPhysPath = (string)Session[APP_PHYSICAL_PATH];
            return OpenWebConfiguration(path, appPhysPath, getWebConfigForSubDir);
        }

        private Configuration OpenWebConfiguration(string path, string appPhysPath, bool getWebConfigForSubDir) {
            // check if session expired
            if (String.IsNullOrEmpty(ApplicationPath) || String.IsNullOrEmpty((string)Session[APP_PHYSICAL_PATH])) {
                Server.Transfer("~/home2.aspx");
            }

            if (String.IsNullOrEmpty(path)) {
                return WebConfigurationManager.OpenWebConfiguration(null);
            }

            string appVPath = (string)Session[APP_PATH];
            if (!getWebConfigForSubDir) {
                appVPath = path;
            }

            WebConfigurationFileMap fileMap = new WebConfigurationFileMap();
            fileMap.VirtualDirectories.Add(appVPath, new VirtualDirectoryMapping(appPhysPath, true));
            return WebConfigurationManager.OpenMappedWebConfiguration(fileMap, path);
        }

        protected override void OnInit(EventArgs e) {
            string applicationPath = ApplicationPath;
            string queryStringAppPath = GetQueryStringAppPath();
            string applicationPhysicalPath = GetQueryStringPhysicalAppPath();
            string requestAppPath = HttpContext.Current.Request.ApplicationPath;
            string currExFilePath = Request.CurrentExecutionFilePath;

            if (applicationPhysicalPath != null) {
                string webAdminVersion = "aspnet_webadmin\\" + UnderscoreProductVersion + "\\";
                if (applicationPhysicalPath.EndsWith(webAdminVersion)) {
                    queryStringAppPath = requestAppPath;
                }
            }

            SetApplicationPath();
            
            if (string.Compare(CurrentRequestUrl, Request.CurrentExecutionFilePath) != 0) {
                PushRequestUrl(Request.CurrentExecutionFilePath);
            }

            base.OnInit(e);
        }

        protected void PopulateRepeaterDataSource(Repeater repeater) {
            // display alphabet row only if language is has Alphabet resource
            ArrayList arr = new ArrayList();
            String chars = ((string)GetGlobalResourceObject("GlobalResources", "Alphabet"));
            foreach (String s in chars.Split(';')) {
                arr.Add(s);
            }
            if (arr.Count == 0) {
                repeater.Visible = false;
            } else {
                arr.Add((string)GetGlobalResourceObject("GlobalResources", "All"));
                repeater.DataSource = arr;
                repeater.Visible = true;
            }
        }

        protected string PopPrevRequestUrl() {
            Stack stack = (Stack) Session[URL_STACK];
            if (stack == null || stack.Count < 2) {
                return string.Empty;
            }
            stack.Pop(); // discard current url
            return(string) stack.Pop();
        }

        protected void PushRequestUrl(string s) {
            Stack stack = (Stack) Session[URL_STACK];
            if (stack == null) {
                Session[URL_STACK] = stack = new Stack();
            }
            stack.Push(s);
        }

        protected void ReturnToPreviousPage(object sender, EventArgs e) {
            string prevRequest = PopPrevRequestUrl();
            Response.Redirect(prevRequest, false);  // note: string.Empty ok here.
        }

        protected void RetrieveLetter(object sender, RepeaterCommandEventArgs e, GridView dataGrid) {
            RetrieveLetter(sender, e, dataGrid, (string)GetGlobalResourceObject("GlobalResources", "All"));
        }

        protected void RetrieveLetter(object sender, RepeaterCommandEventArgs e, GridView dataGrid, string all) {
            RetrieveLetter(sender, e, dataGrid, all, null);
        }

        protected void RetrieveLetter(object sender, RepeaterCommandEventArgs e, GridView dataGrid, string all, MembershipUserCollection users) {
            dataGrid.PageIndex = 0;
            int total = 0;
            string arg = e.CommandArgument.ToString();

            if (arg == all) {
                dataGrid.DataSource = (users == null) ? (MembershipUserCollection)CallWebAdminHelperMethod(true, "GetAllUsers", new object[] {0, Int32.MaxValue, total}, new Type[] {typeof(int),typeof(int),Type.GetType("System.Int32&")}) : users;
            }
            else {
                dataGrid.DataSource = (MembershipUserCollection)CallWebAdminHelperMethod(true, "FindUsersByName", new object[] {(string) arg + "%", 0, Int32.MaxValue, total}, new Type[] {typeof(string), typeof(int), typeof(int), Type.GetType("System.Int32&")});
            }
            dataGrid.DataBind();
        }

        protected void SetApplicationPath() {
            if (!VerifyAppValid()) {
                Server.Transfer("~/error.aspx");
            }
        }

        // At point when app is set, verify it is valid (i.e., permissions are proper and app exists).
        private bool VerifyAppValid() {

            // check if session expired
            if (String.IsNullOrEmpty(ApplicationPath) || String.IsNullOrEmpty((string)Session[APP_PHYSICAL_PATH])) {
                Server.Transfer("~/home2.aspx");
            }

            try {
                Configuration config = OpenWebConfiguration(ApplicationPath);
                SaveConfig(config);
            }
            catch (Exception e) {
                Exception ex = new Exception((string) e.ToString());
                SetCurrentException(Context, ex);
                return false;
            }
            return true;
        }
    }

    [AspNetHostingPermission(SecurityAction.LinkDemand, Level=AspNetHostingPermissionLevel.Minimal)]
    [AspNetHostingPermission(SecurityAction.InheritanceDemand, Level=AspNetHostingPermissionLevel.Minimal)]
    public sealed class WebAdminModule : IHttpModule {
        private const string APP_PATH = "WebAdminApplicationPath";
        private const string APP_PHYSICAL_PATH = "WebAdminPhysicalPath";
        private const string REMOTING_MANAGER = "WebAdminRemotingManager";
        
        private void ApplicationError(object sender, EventArgs e) {            
            Exception exception  = ((HttpApplication)sender).Server.GetLastError().InnerException;
            HttpContext context = ((HttpApplication)sender).Context;
            string redirectUrl = "~/error.aspx";
            if (String.IsNullOrEmpty(redirectUrl)) {
                return;
            }

            WebAdminPage.SetCurrentException(context, exception);

            ((HttpApplication)sender).Server.Transfer(String.Format(CultureInfo.InvariantCulture, redirectUrl), true);
        }

        public void Init(HttpApplication application) {
            application.Error += (new EventHandler(this.ApplicationError));
            application.AcquireRequestState += new EventHandler(this.OnEnter);
        }

        public void Dispose() {
        }

        private void OnEnter(Object sender, EventArgs eventArgs) {
            HttpApplication application = (HttpApplication)sender;

            if (!application.Context.Request.IsLocal) {
                SecurityException securityException = new SecurityException((string)HttpContext.GetGlobalResourceObject("GlobalResources", "WebAdmin_ConfigurationIsLocalOnly"));
                WebAdminPage.SetCurrentException(application.Context, securityException);
                application.Server.Transfer("~/error.aspx");
            }

            if (application != null) {
                SetSessionVariables(application);
            }
            application.Response.Cache.SetCacheability(HttpCacheability.NoCache);
        }

        private void SetSessionVariables(HttpApplication application) {
            string queryStringAppPath = string.Empty;
            string queryStringApplicationPhysicalPath = string.Empty;
            string applicationPath = string.Empty;
            string applicationPhysicalPath = string.Empty;
            string setAppPath = string.Empty;
            string setAppPhysPath = string.Empty;

            try {
                SecurityPermission permission = new SecurityPermission(PermissionState.Unrestricted);
                permission.Demand();
            } catch {
                Exception permissionException = new Exception((string)HttpContext.GetGlobalResourceObject("GlobalResources", "FullTrustRequired"));
                WebAdminPage.SetCurrentException(application.Context, permissionException);
                application.Server.Transfer("~/error.aspx");
            }

            if (application.Context.Request != null) {
                queryStringAppPath = (string) application.Context.Request.QueryString["applicationUrl"];
                queryStringApplicationPhysicalPath = (string) application.Context.Request.QueryString["applicationPhysicalPath"];
            }

            if (application.Context.Session != null) {
                if (application.Context.Session[APP_PATH] != null) {
                    applicationPath = (string)application.Context.Session[APP_PATH];
                }
                if (application.Context.Session[APP_PHYSICAL_PATH] != null) {
                    applicationPhysicalPath = (string)application.Context.Session[APP_PHYSICAL_PATH];
                }
            }

            if ((String.IsNullOrEmpty(queryStringAppPath) && applicationPath == null) ||
               (String.IsNullOrEmpty(queryStringApplicationPhysicalPath) && applicationPhysicalPath == null) ) {
                application.Server.Transfer("~/home0.aspx", false);
                return;
            }

            if (!String.IsNullOrEmpty(queryStringAppPath)) {
                setAppPath = queryStringAppPath;
            } else if (!String.IsNullOrEmpty(applicationPath)) {
                setAppPath = applicationPath;
            }

            if (!String.IsNullOrEmpty(queryStringApplicationPhysicalPath)) {
                setAppPhysPath = queryStringApplicationPhysicalPath;
            } else if (!String.IsNullOrEmpty(applicationPhysicalPath)) {
                setAppPhysPath = applicationPhysicalPath;
            }

            if (application.Context.Session != null) {
                application.Context.Session[APP_PATH] = setAppPath;
                application.Context.Session[APP_PHYSICAL_PATH] = setAppPhysPath;
                application.Context.Session[REMOTING_MANAGER] = new WebAdminRemotingManager(setAppPath, setAppPhysPath, application.Context.Session);
            }
        }
    }

    public sealed class WebAdminMembershipProvider : MembershipProvider {

        public WebAdminMembershipProvider() {
        }

        public WebAdminRemotingManager RemotingManager {
            get {
                return (WebAdminRemotingManager) HttpContext.Current.Session["WebAdminRemotingManager"];

            }
        }

        public object CallWebAdminMembershipProviderHelperMethod(string methodName, object[] parameters, Type[] paramTypes) {
            object returnObject = null;
            object tempObject = null;

            tempObject = RemotingManager.ConfigurationHelperInstance;
            if (tempObject != null) {
                string typeFullName = WebAdminRemotingManager.AssemblyVersionString;
                Type tempType = Type.GetType(typeFullName);

                BindingFlags allBindingFlags = BindingFlags.Instance | BindingFlags.Public | BindingFlags.NonPublic;
                MethodInfo method = tempType.GetMethod("CallMembershipProviderMethod", allBindingFlags);
                if (method != null) {
                    object[] newParameters = new object[]{methodName, parameters, paramTypes};
                    object[] returnArrayObj = (object[]) method.Invoke(tempObject, newParameters);
                    if (returnArrayObj != null) {
                        returnObject = returnArrayObj[0];
                    }
                }
            }

            return returnObject;
        }

        public object[] CallWebAdminMembershipProviderHelperMethodOutParams(string methodName, object[] parameters, Type[] paramTypes) {
            object[] returnObjectArray = new object[0];

            object tempObject = RemotingManager.ConfigurationHelperInstance;
            if (tempObject != null) {
                string typeFullName = WebAdminRemotingManager.AssemblyVersionString;
                Type tempType = Type.GetType(typeFullName);

                BindingFlags allBindingFlags = BindingFlags.Instance | BindingFlags.Public | BindingFlags.NonPublic;
                MethodInfo method = tempType.GetMethod("CallMembershipProviderMethod", allBindingFlags);
                if (method != null) {
                    object[] newParameters = new object[]{methodName, parameters, paramTypes};
                    object[] returnArrayObj = (object[]) method.Invoke(tempObject, newParameters);
                    if (returnArrayObj != null) {
                        returnObjectArray = returnArrayObj;
                    }
                }
            }

            return returnObjectArray;
        }

        public object GetWebAdminMembershipProviderHelperProperty(string propertyName) {
            object returnObject = null;
            object tempObject = null;
            tempObject = RemotingManager.ConfigurationHelperInstance;
            if (tempObject != null) {
                string typeFullName = WebAdminRemotingManager.AssemblyVersionString;
                Type tempType = Type.GetType(typeFullName);

                BindingFlags allBindingFlags =  BindingFlags.Instance | BindingFlags.Public | BindingFlags.NonPublic;
                MethodInfo method = tempType.GetMethod("GetMembershipProviderProperty", allBindingFlags);
                if (method != null) {
                    object[] newParameters = new object[]{propertyName};
                    returnObject = method.Invoke(tempObject, newParameters);
                }
            }

            return returnObject;
        }

        public override string ApplicationName
        {
            get { return (string)GetWebAdminMembershipProviderHelperProperty("ApplicationName"); }
            set {;}
        }

        public override bool EnablePasswordRetrieval{
            get {
                return (bool)GetWebAdminMembershipProviderHelperProperty("EnablePasswordRetrieval");
            }
        }

        public override bool EnablePasswordReset
        {
            get{
                return (bool)GetWebAdminMembershipProviderHelperProperty("EnablePasswordReset");
            }
        }

        public override bool RequiresQuestionAndAnswer
        {
            get {
                return (bool)GetWebAdminMembershipProviderHelperProperty("RequiresQuestionAndAnswer");
            }
        }

        public override bool RequiresUniqueEmail
        {
            get {
                return (bool)GetWebAdminMembershipProviderHelperProperty("RequiresUniqueEmail");
            }
        }

        public override int MaxInvalidPasswordAttempts
        {
            get {
                return (int)GetWebAdminMembershipProviderHelperProperty("MaxInvalidPasswordAttempts");
            }
        }

        public override int PasswordAttemptWindow
        {
            get {
                return (int)GetWebAdminMembershipProviderHelperProperty("PasswordAttemptWindow");
            }
        }

        public override MembershipPasswordFormat PasswordFormat
        {
            get {
                return (MembershipPasswordFormat)GetWebAdminMembershipProviderHelperProperty("PasswordFormat");
            }
        }

        public override int MinRequiredPasswordLength
        {
            get { return (int)GetWebAdminMembershipProviderHelperProperty("MinRequiredPasswordLength"); }
        }

        public override int MinRequiredNonAlphanumericCharacters
        {
            get { return (int)GetWebAdminMembershipProviderHelperProperty("MinRequiredNonAlphanumericCharacters"); }
        }

        public override string PasswordStrengthRegularExpression
        {
            get { return (string)GetWebAdminMembershipProviderHelperProperty("PasswordStrengthRegularExpression"); }
        }

        public override bool ChangePassword(string name, string oldPwd, string newPwd)
        {
            return (bool)CallWebAdminMembershipProviderHelperMethod("ChangePassword", new object[]{name, oldPwd, newPwd}, new Type[] {typeof(string), typeof(string), typeof(string)});
        }

        public override bool ChangePasswordQuestionAndAnswer(string name, string password, string newPwdQuestion, string newPwdAnswer)
        {
            return (bool)CallWebAdminMembershipProviderHelperMethod("ChangePasswordQuestionAndAnswer", new object[]{name, password, newPwdQuestion, newPwdAnswer}, new Type[] {typeof(string), typeof(string), typeof(string), typeof(string)});
        }

        public override MembershipUser CreateUser( string username, 
                                                   string password, 
                                                   string email,
                                                   string passwordQuestion,
                                                   string passwordAnswer,
                                                   bool   isApproved,
                                                   object providerUserKey,
                                                   out    MembershipCreateStatus status)
        {
            MembershipUser TempUser = null;
            status = MembershipCreateStatus.InvalidUserName;
            string  typeFullName = "System.Web.Security.MembershipCreateStatus&, " + typeof(HttpContext).Assembly.GetName().ToString();
            Type tempType = Type.GetType(typeFullName);

            object[] returnAndOutParams = CallWebAdminMembershipProviderHelperMethodOutParams("CreateUser", new object[]{username, password, email, passwordQuestion, passwordAnswer, isApproved, providerUserKey, status} , new Type[] {typeof(string), typeof(string), typeof(string), typeof(string), typeof(string), typeof(bool), typeof(object), tempType});
            if (returnAndOutParams != null) {
                TempUser = (MembershipUser) returnAndOutParams[0];
                status = (MembershipCreateStatus) returnAndOutParams[8];
            }

            if (status != MembershipCreateStatus.Success) {
                return null;
            }
            else {
                return TempUser;
            }
        }

        public override bool DeleteUser(string name, bool deleteAllRelatedContent)
        {
              return (bool)CallWebAdminMembershipProviderHelperMethod("DeleteUser", new object[]{name, deleteAllRelatedContent}, new Type[] {typeof(string), typeof(bool)});
        }

        public override MembershipUserCollection GetAllUsers(int pageIndex, int pageSize, out int totalRecords)
        {
            totalRecords = 0;
            MembershipUserCollection TempList = (MembershipUserCollection) CallWebAdminMembershipProviderHelperMethod("GetAllUsers", new object[]{pageIndex, pageSize, totalRecords}, new Type[] {typeof(int), typeof(int),Type.GetType("System.Int32&")});
            MembershipUserCollection NewList = new MembershipUserCollection();
            foreach (MembershipUser TempItem in TempList)
            {
                MembershipUser NewUser = new MembershipUser(this.Name,
                                                    TempItem.UserName,
                                                    TempItem.ProviderUserKey,
                                                    TempItem.Email,
                                                    TempItem.PasswordQuestion,
                                                    TempItem.Comment,
                                                    TempItem.IsApproved,
                                                    TempItem.IsLockedOut,
                                                    TempItem.CreationDate,
                                                    TempItem.LastLoginDate,
                                                    TempItem.LastActivityDate,
                                                    TempItem.LastPasswordChangedDate,
                                                    TempItem.LastLockoutDate );
           
                NewList.Add(NewUser);
            }
            
            return NewList;
        }

        public override MembershipUserCollection FindUsersByEmail(string emailToMatch, int pageIndex, int pageSize, out int totalRecords)
        {
            totalRecords = 0;
            MembershipUserCollection TempList = (MembershipUserCollection) CallWebAdminMembershipProviderHelperMethod("FindUsersByEmail", new object[]{emailToMatch, pageIndex, pageSize, totalRecords}, new Type[] {typeof(string), typeof(int), typeof(int),Type.GetType("System.Int32&")});
            MembershipUserCollection NewList = new MembershipUserCollection();
            foreach (MembershipUser TempItem in TempList)
            {
                MembershipUser NewUser = new MembershipUser(this.Name,
                                                    TempItem.UserName,
                                                    TempItem.ProviderUserKey,
                                                    TempItem.Email,
                                                    TempItem.PasswordQuestion,
                                                    TempItem.Comment,
                                                    TempItem.IsApproved,
                                                    TempItem.IsLockedOut,
                                                    TempItem.CreationDate,
                                                    TempItem.LastLoginDate,
                                                    TempItem.LastActivityDate,
                                                    TempItem.LastPasswordChangedDate,
                                                    TempItem.LastLockoutDate );
           
                NewList.Add(NewUser);
            }
            
            return NewList;
        }

        public override int GetNumberOfUsersOnline()
        {
            return (int) CallWebAdminMembershipProviderHelperMethod("GetNumberOfUsersOnline", new object[]{}, null);
        }

        public override string GetPassword(string name, string answer)
        {
            return (string) CallWebAdminMembershipProviderHelperMethod("GetPassword", new object[]{name, answer}, new Type[] {typeof(string), typeof(string)});
        }

        public override MembershipUser GetUser(string name, bool userIsOnline)
        {
            MembershipUser TempUser = (MembershipUser)CallWebAdminMembershipProviderHelperMethod("GetUser", new object[]{name, userIsOnline}, new Type[] {typeof(string), typeof(bool)});
            MembershipUser NewUser = new MembershipUser(this.Name,
                                                    TempUser.UserName,
                                                    TempUser.ProviderUserKey,
                                                    TempUser.Email,
                                                    TempUser.PasswordQuestion,
                                                    TempUser.Comment,
                                                    TempUser.IsApproved,
                                                    TempUser.IsLockedOut,
                                                    TempUser.CreationDate,
                                                    TempUser.LastLoginDate,
                                                    TempUser.LastActivityDate,
                                                    TempUser.LastPasswordChangedDate,
                                                    TempUser.LastLockoutDate );
            
            return NewUser;
        }

        public override string GetUserNameByEmail(string email)
        {
            return (string)CallWebAdminMembershipProviderHelperMethod("GetUserNameByEmail", new object[]{email}, new Type[] {typeof(string)});
        }

        public override string ResetPassword(string name, string answer)
        {
            return (string)CallWebAdminMembershipProviderHelperMethod("ResetPassword", new object[]{name, answer}, new Type[] {typeof(string), typeof(string)});
        }

        public override void UpdateUser(MembershipUser user)
        {
            string  typeFullName = "System.Web.Security.MembershipUser, " + typeof(HttpContext).Assembly.GetName().ToString();;
            Type tempType = Type.GetType(typeFullName);

            CallWebAdminMembershipProviderHelperMethod("UpdateUser", new object[] {(MembershipUser) user}, new Type[] {tempType});
        }

        public override bool ValidateUser(string name, string password)
        {
            return (bool)CallWebAdminMembershipProviderHelperMethod("ValidateUser", new object[]{name, password}, new Type[] {typeof(string), typeof(string)});
        }

        public override MembershipUser GetUser( object providerUserKey, bool userIsOnline )
        {
            return (MembershipUser)CallWebAdminMembershipProviderHelperMethod("GetUser", new object[]{providerUserKey, userIsOnline}, new Type[] {typeof(object), typeof(bool)});
        }

        public override bool UnlockUser( string name )
        {
            return (bool)CallWebAdminMembershipProviderHelperMethod("UnlockUser", new object[]{name}, new Type[] {typeof(string)});
        }

        public override void Initialize(string name, NameValueCollection config)
        {
            if (String.IsNullOrEmpty(name)) {
                name = "WebAdminMembershipProvider";
            }

            base.Initialize(name, config);
        }

        public override MembershipUserCollection FindUsersByName(string usernameToMatch, int pageIndex, int pageSize, out int totalRecords)
        {
            totalRecords = 0;
            MembershipUserCollection TempList = (MembershipUserCollection)CallWebAdminMembershipProviderHelperMethod("FindUsersByName", new object[]{usernameToMatch, pageIndex, pageSize, totalRecords}, new Type[] {typeof(string), typeof(int), typeof(int), Type.GetType("System.Int32&")});
            MembershipUserCollection NewList = new MembershipUserCollection();
            foreach (MembershipUser TempItem in TempList)
            {
                MembershipUser NewUser = new MembershipUser(this.Name,
                                                    TempItem.UserName,
                                                    TempItem.ProviderUserKey,
                                                    TempItem.Email,
                                                    TempItem.PasswordQuestion,
                                                    TempItem.Comment,
                                                    TempItem.IsApproved,
                                                    TempItem.IsLockedOut,
                                                    TempItem.CreationDate,
                                                    TempItem.LastLoginDate,
                                                    TempItem.LastActivityDate,
                                                    TempItem.LastPasswordChangedDate,
                                                    TempItem.LastLockoutDate );
           
                NewList.Add(NewUser);
            }
            
            return NewList;
        }
    }

    public sealed class WebAdminRemotingManager : MarshalByRefObject {
        private ApplicationManager _appManager;
        private string _applicationMetaPath;
        private string _applicationPhysicalPath;
        private HttpSessionState _session;
        private object _configurationHelper;
        private static string _assemblyVersion;
        
        public WebAdminRemotingManager(string applicationMetaPath, string applicationPhysicalPath, HttpSessionState session) {
            _applicationMetaPath = applicationMetaPath;
            _applicationPhysicalPath = applicationPhysicalPath;
            _session = session;
        }

        public override Object InitializeLifetimeService(){
            return null; // never expire lease
        }

        public static string AssemblyVersionString {
            get {
                if (String.IsNullOrEmpty(_assemblyVersion)) {
                    _assemblyVersion = "System.Web.Administration.WebAdminConfigurationHelper, " + typeof(HttpContext).Assembly.GetName().ToString();
                }
                return _assemblyVersion;
            }
        }

        private ApplicationManager AppManager {
            get {
                if (_appManager == null) {
                    return _appManager = ApplicationManager.GetApplicationManager();
                }
                return _appManager;
            }
        }
        
        protected string ApplicationMetaPath {
            get {
                return _applicationMetaPath;
            }
        }

        public string ApplicationPhysicalPath {
            get {
                return _applicationPhysicalPath;
            }
            set {
                _applicationPhysicalPath = value;
                // Set provider proxy references to null, to account for the edge case where ApplicationPhysicalPath is set twice.
                // Notes: this does not shut down the target appdomain, which is the desired behavior, since, in the unlikely case where the
                // ApplicationPhysicalPath is changed, the change is likely to be reverted.  Resetting the providers is necessary because
                // the existing providers point to the old target appdomain.
                ResetProviders();  
            }
        }

        public object ConfigurationHelperInstance {
            get {
                return CreateConfigurationHelper();
            }
        }

        private HttpSessionState Session {
            get {
                return _session;
            }
        }

        public string TargetAppId {
            get {
                if (Session["WebAdminTargetAppId"] != null) {
                    return (string)Session["WebAdminTargetAppId"];
                } else {
                    return string.Empty;
                }
             }
            set {
                Session["WebAdminTargetAppId"] = value;
            }
        }

        private object CreateConfigurationHelper() {
            if (_configurationHelper != null) {
                return _configurationHelper;
            }
            string appPath = ApplicationMetaPath;
            string appPhysPath = ApplicationPhysicalPath;
            string targetAppId = String.Empty;

            string typeFullName = WebAdminRemotingManager.AssemblyVersionString;
            Type tempType = Type.GetType(typeFullName);

             // Put together some unique app id
             string appId = (String.Concat(appPath, appPhysPath).GetHashCode()).ToString("x", CultureInfo.InvariantCulture);

             _configurationHelper = (object)ApplicationManager.GetApplicationManager().CreateObject(appId, tempType, appPath, appPhysPath, false, true);
            TargetAppId = appId;

            return _configurationHelper;
        }

        private void EnsureTargetAppId() {
            if (TargetAppId != null) {
                return;
            }
            // In some cases, the target appdomain exists before the AppId is discovered by AppManager.CreateObjectWithDefaultAppHostAndAppId
            // (for example if the target app is already running).  In this case, retrieve one of the 
            // providers (we make an arbitrary choice to retrieve the membership provider).  This forces the object to 
            // discover the target appid.  
            
            CreateConfigurationHelper(); // Retrieves the target appid.
        }

        public VirtualDirectory GetVirtualDirectory(string virtualDir) {
            VirtualDirectory vdir = null;
            object configHelperObject = ConfigurationHelperInstance;
            if (configHelperObject != null) {
                string typeFullName = WebAdminRemotingManager.AssemblyVersionString;
                Type tempType = Type.GetType(typeFullName);

                BindingFlags allBindingFlags = BindingFlags.Instance | BindingFlags.Public | BindingFlags.NonPublic;
                MethodInfo method = tempType.GetMethod("GetVirtualDirectory", allBindingFlags);
                if (method != null) {
                    vdir = (VirtualDirectory) method.Invoke(configHelperObject, new object[]{virtualDir});
                }
            }

            return vdir;
        }

        public void ResetProviders() {
            _configurationHelper = null;
            TargetAppId = null;
        }

        public void ShutdownTargetApplication() {
            // CONSIDER: Rather than calling EnsureTargetAppId(), is there a method on AppManager that can tell us whether
            // an appdomain exists based on the Id, and another method that creates the "default Id" from the application 
            // path and physical path?  This prevents the following two lines from creating the appdomain and immediately 
            // shutting it down in the (edge) case where the target appdomain doesn't exist.
 
            EnsureTargetAppId();
            AppManager.ShutdownApplication(TargetAppId);

            // ResetProviders to ensure that the value of TargetAppId is in sync with the provider proxies.  Calling 
            // property get for a provider proxy sets TargetAppId to the correct value.
            ResetProviders();
        }
    }

    [AspNetHostingPermission(SecurityAction.LinkDemand, Level=AspNetHostingPermissionLevel.Minimal)]
    [AspNetHostingPermission(SecurityAction.InheritanceDemand, Level=AspNetHostingPermissionLevel.Minimal)]
    public class WebAdminUserControl : UserControl {
        private string _directionality;

        public enum DatabaseType {
            Access = 0,
            Sql = 1,
        }

        public string Directionality {
            get {
                if (String.IsNullOrEmpty(_directionality)) {
                    _directionality = ((string) GetGlobalResourceObject("GlobalResources", "HtmlDirectionality")).ToLower();
                }
                return _directionality;
            }
        }

        public HorizontalAlign DirectionalityHorizontalAlign {
           get {
                if (Directionality == "rtl") {
                    return HorizontalAlign.Right;
                } else {
                    return HorizontalAlign.Left;
                }
           }
        }

        public virtual bool OnNext() {
            return true; // move to next control.  Override to return false if next should not be honored.
        }

        public virtual bool OnPrevious() {
            return true; // move to next control.  Override to return false if prev should not be honored.
        }
    }


    [Serializable]
    public class WebAdminException : Exception
    {
        public WebAdminException() {}
 
        public WebAdminException( string message )
            : base( message )
        {}
    }
}
