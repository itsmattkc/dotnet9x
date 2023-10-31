//------------------------------------------------------------------------------
// <copyright file="WebAdminPage.cs" company="Microsoft">
//     Copyright (c) Microsoft Corporation.  All rights reserved.
// </copyright>
//------------------------------------------------------------------------------

namespace System.Web.Administration {
    using System.Web.UI;
    using System.Configuration;
    using System.Web.Configuration;
    using System.Security.Permissions;

    // Base class for use elsewhere in the code directory
    [AspNetHostingPermission(SecurityAction.LinkDemand, Level=AspNetHostingPermissionLevel.Minimal)]
    [AspNetHostingPermission(SecurityAction.InheritanceDemand, Level=AspNetHostingPermissionLevel.Minimal)]
    public abstract class NavigationBar : UserControl {

        public abstract void SetSelectedIndex(int index);
    }
}

