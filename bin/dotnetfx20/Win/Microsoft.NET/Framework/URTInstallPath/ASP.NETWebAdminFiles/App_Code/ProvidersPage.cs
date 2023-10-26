//------------------------------------------------------------------------------
// <copyright file="ProvidersPage.cs" company="Microsoft">
//     Copyright (c) Microsoft Corporation.  All rights reserved.
// </copyright>
//------------------------------------------------------------------------------

namespace System.Web.Administration {
    using System;
    using System.Collections;
    using System.Configuration;
    using System.Globalization;
    using System.IO;
    using System.Security;
    using System.Security.Permissions;
    using System.Web.Hosting;
    using System.Xml;
    
    [AspNetHostingPermission(SecurityAction.LinkDemand, Level=AspNetHostingPermissionLevel.Minimal)]
    [AspNetHostingPermission(SecurityAction.InheritanceDemand, Level=AspNetHostingPermissionLevel.Minimal)]
    public class ProvidersPage : WebAdminPage {
        private ArrayList _groupedProvidersList;

        public struct GroupedProperty {
            public string Name;
            public string Description;
            public string MembershipProvider;
            public string RoleProvider;
        }
 
        private string DataDirectoryName {
            get {
                return (string) AppDomain.CurrentDomain.GetData("DataDirectory");
            }
        }

        protected ArrayList GroupedProvidersList {
            get {
                if (_groupedProvidersList == null) {
                    _groupedProvidersList = GetGroupedProvidersFromXMLFile();
                }
                return _groupedProvidersList;
            }
        }
        
        protected override void OnInit(EventArgs e) {
            NavigationBar.SetSelectedIndex(3);
            base.OnInit(e);
        }

        protected ArrayList GetGroupedProvidersFromXMLFile() {
            string pathToXMLFile = DataDirectoryName + @"\GroupedProviders.xml";

            ArrayList arrayOfGroupedProviders = new ArrayList();
            if (!File.Exists(pathToXMLFile)) {
                return arrayOfGroupedProviders;
            }

            XmlTextReader reader = null;
            try {
                reader = new XmlTextReader(pathToXMLFile);
                XmlNameTable nt = new NameTable();
                XmlDocument xmlDoc = new XmlDocument(nt);
                xmlDoc.Load(reader);

                XmlNode root = xmlDoc.SelectSingleNode("Root");
                XmlNode providersNode = root.SelectSingleNode("GroupedProviders");

                // loop thru all of the GroupedProviders
                XmlAttribute nameAttribute = null;
                for (System.Xml.XmlNode oneXmlNode = providersNode.FirstChild; oneXmlNode != null; oneXmlNode = oneXmlNode.NextSibling) {
                    if (oneXmlNode.Name.ToLower() == "groupedprovider") {
                        GroupedProperty oneGroupedProvider = new GroupedProperty();

                        nameAttribute = oneXmlNode.Attributes["name"];
                        oneGroupedProvider.Name = nameAttribute.Value;
        
                        XmlAttribute descriptionAttribute = null;
                        try {
                            descriptionAttribute = oneXmlNode.Attributes["description"];
                            oneGroupedProvider.Description = descriptionAttribute.Value;
                        } catch {
                            oneGroupedProvider.Description = String.Empty;
                        }

                        XmlNode membershipNode = oneXmlNode.SelectSingleNode("MembershipProvider");
                        nameAttribute = membershipNode.Attributes["name"];
                        oneGroupedProvider.MembershipProvider = nameAttribute.Value;

                        XmlNode roleNode = oneXmlNode.SelectSingleNode("RoleProvider");
                        nameAttribute = roleNode.Attributes["name"];
                        oneGroupedProvider.RoleProvider = nameAttribute.Value;
                
                        // Check if the membership/role provider exists in the web.config
                        arrayOfGroupedProviders.Add(oneGroupedProvider);
                    }
                }
            } finally {
                if (reader != null) {
                    reader.Close();
                }
            }

            // loop thru the list and print them out.
            return arrayOfGroupedProviders;
        }
        
        protected string TestConnectionText(bool connectionWorks, bool isSql) {
            if (connectionWorks) {
                return (string)GetGlobalResourceObject("GlobalResources", "GenericSuccess");
            }
            if (!isSql) {
                return (string)GetGlobalResourceObject("GlobalResources", "GenericFailure");
            }

            return (string)GetGlobalResourceObject("GlobalResources", "SpecificFailureCreateDB");
        }
    }
}


