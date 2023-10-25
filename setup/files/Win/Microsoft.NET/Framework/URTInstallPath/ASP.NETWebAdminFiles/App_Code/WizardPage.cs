//------------------------------------------------------------------------------
// <copyright file="WizardPage.cs" company="Microsoft">
//     Copyright (c) Microsoft Corporation.  All rights reserved.
// </copyright>
//------------------------------------------------------------------------------

namespace System.Web.Administration {

    using System.Security.Permissions;

    [AspNetHostingPermission(SecurityAction.LinkDemand, Level=AspNetHostingPermissionLevel.Minimal)]
    [AspNetHostingPermission(SecurityAction.InheritanceDemand, Level=AspNetHostingPermissionLevel.Minimal)]
    public abstract class WizardPage : WebAdminPage {
        public abstract void DisableWizardButtons();
        public abstract void EnableWizardButtons();
        public abstract void SaveActiveView();
    }
}


