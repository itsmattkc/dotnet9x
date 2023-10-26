//------------------------------------------------------------------------------
// <copyright file="PasswordValueTextBox.cs" company="Microsoft">
//     Copyright (c) Microsoft Corporation.  All rights reserved.
// </copyright>
//------------------------------------------------------------------------------

using System.Web.UI;
using System.Web.UI.WebControls;
using System.Security.Permissions;

namespace System.Web.Administration {
    // A password text box that would retain its text as asterisks shown in the
    // textbox so to have the desired UI effect.
    [AspNetHostingPermission(SecurityAction.LinkDemand, Level=AspNetHostingPermissionLevel.Minimal)]
    [AspNetHostingPermission(SecurityAction.InheritanceDemand, Level=AspNetHostingPermissionLevel.Minimal)]
    public class PasswordValueTextBox : TextBox {
        protected override void AddAttributesToRender(HtmlTextWriter writer) {
            TextMode = TextBoxMode.Password;
            base.AddAttributesToRender(writer);
            string s = Text;
            if (s.Length > 0) {
                writer.AddAttribute(HtmlTextWriterAttribute.Value,s);
            }
        }
    }
}
