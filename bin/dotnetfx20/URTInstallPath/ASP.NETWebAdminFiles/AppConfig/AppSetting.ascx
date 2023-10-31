<%@ Control Inherits="System.Web.Administration.WebAdminUserControl"%>
<%@ Import Namespace="System.Drawing" %>
<%@ Import Namespace="System.Web.Administration" %>
<%@ Import Namespace="System.Web.Configuration" %>

<script runat="server" language="cs">

public CustomValidator CustomValidator {
    get {
        return CustomVal;
    }
}

public bool InEditMode {
    get {
        return !NameTextBox.Enabled;
    }
    set {
        NameTextBox.Enabled = !value;
    }
}

public String Name {
    get {
        return NameTextBox.Text;
    }
    set {
        NameTextBox.Text = value;
    }
}

public String Value {
    get {
        return ValueTextBox.Text;
    }
    set {
        ValueTextBox.Text = value;
    }
}

public event EventHandler Save {
    add {
        SaveButton.Click += value;
    }
    remove {
        SaveButton.Click -= value;
    }
}

public void ResetUI() {
    NameTextBox.Text = null;
    ValueTextBox.Text = null;
}

</script>

<table cellspacing="0" height="1%" width="80%" rules="none"
       bordercolor="#CCDDEF" border="1" style="border-color:#CCDDEF;border-style:None;border-collapse:collapse;">
    <tr class="callOutStyle" valign="top" height="5%" cellpadding="4">
        <td style="padding-left:10;padding-right:10;"><asp:Literal runat="server" text="<%$ Resources:AppSettingTitle %>"/></td>
    </tr>
    <tr>
        <td>
            <table class="bodyText" cellpadding="4">
                <tr>
                    <%-- An invisible textbox at the end of the line is to submit the page on enter, raising server side onclick --%>
                    <td><asp:Label runat="server" AssociatedControlID="NameTextBox" Text="<%$ Resources:NameLabel %>" /></td>
                    <td><asp:TextBox runat=server id="NameTextBox" width="155"/>&nbsp;<input type="text" style="visibility:hidden;width:0px;" /></td>
                </tr>
                <tr>
                    <td><asp:Label runat="server" AssociatedControlID="ValueTextBox" Text="<%$ Resources:ValueLabel %>" /></td>
                    <td><asp:TextBox runat=server id="ValueTextBox" width="155"/></td>
                </tr>
            </table>
        </td>
    </tr>
    <tr class="userDetailsWithFontSize" valign="top" height="5%">
        <td>
            <table height="100%" width="100%">
                <tr>
                    <td class="bodyText">
                        <asp:ValidationSummary runat="server" HeaderText="<%$ Resources:GlobalResources,ErrorHeader %>"/>
                        <asp:RequiredFieldValidator runat="server" ControlToValidate="NameTextBox"
                                                    ErrorMessage="<%$ Resources:NameRequiredError %>" Display="none"/>
                        <asp:RegularExpressionValidator id="NameValidator" ControlToValidate="NameTextBox" ErrorMessage="<%$ Resources:NameTooLongError %>" ValidationExpression=".{0,256}" Display="none" runat="server"/>
                        <asp:RegularExpressionValidator id="ValueValidator" ControlToValidate="ValueTextBox" ErrorMessage="<%$ Resources:ValueTooLongError %>" ValidationExpression=".{0,256}" Display="none" runat="server"/>
                        <asp:CustomValidator runat="server" Display="none" Enabled="false" id="CustomVal"/>
                        
                    </td>
                    <td style="padding-right:10;" align="right" width="20%" valign="top">
                        <asp:Button runat=server id="SaveButton" Text="<%$ Resources:GlobalResources,SaveButtonLabel %>" width="100"/>
                    </td>
                </tr>
            </table>
        </td>
    </tr>
</table>
