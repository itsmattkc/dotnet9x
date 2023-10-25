<%@ Import Namespace="System.Collections" %>
<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="System.Xml.Serialization" %>
<%@ Import Namespace="System.Xml" %>
<%@ Import Namespace="System.Xml.Schema" %>
<%@ Import Namespace="System.Web.Services" %>
<%@ Import Namespace="System.Web.Services.Description" %>
<%@ Import Namespace="System.Web.Services.Configuration" %>
<%@ Import Namespace="System" %>
<%@ Import Namespace="System.Globalization" %>
<%@ Import Namespace="System.Resources" %>
<%@ Import Namespace="System.Diagnostics" %>
<%@ Import Namespace="System.Net" %>

<html>

    <script language="C#" runat="server">

    // set this to true if you want to see a POST test form instead of a GET test form
    bool showPost = true;

    // set this to true if you want to see the raw XML as outputted from the XmlWriter (useful for debugging)
    bool dontFilterXml = false;
    
    // set this higher or lower to adjust the depth into your object graph of the sample messages
    int maxObjectGraphDepth = 4;

    // set this higher or lower to adjust the number of array items in sample messages
    int maxArraySize = 2;

    // set this to true to see debug output in sample messages
    bool debug = false;
    
    string soapNs = "http://schemas.xmlsoap.org/soap/envelope/";
    string soapEncNs = "http://schemas.xmlsoap.org/soap/encoding/";
    string soapPrefix = "soap";
   
    string soap12Ns = "http://www.w3.org/2003/05/soap-envelope";
    string soap12EncNs = "http://www.w3.org/2003/05/soap-encoding";
    string soap12Prefix = "soap12";
    string rpcNs = "http://www.w3.org/2003/05/soap-rpc";
    int objectId = 0;

    string msTypesNs = "http://microsoft.com/wsdl/types/";
    string wsdlNs = "http://schemas.xmlsoap.org/wsdl/";

    string urType = "anyType";

    ServiceDescriptionCollection serviceDescriptions;
    XmlSchemas schemas;
    string operationName;
    OperationBinding soapOperationBinding;
    Operation soapOperation;
    OperationBinding soap12OperationBinding;
    Operation soap12Operation;
    OperationBinding httpGetOperationBinding;
    Operation httpGetOperation;
    OperationBinding httpPostOperationBinding;
    Operation httpPostOperation;
    StringWriter writer;
    MemoryStream xmlSrc;
    XmlTextWriter xmlWriter;
    Uri getUrl, postUrl;
    Queue referencedTypes;
    int hrefID;
    bool operationExists = false;
    BasicProfileViolationCollection warnings = new BasicProfileViolationCollection();
    
    int nextPrefix = 1;
    static readonly char[] hexTable = new char[] { '0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 'A', 'B', 'C', 'D', 'E', 'F' };
    bool requestIsLocal = false;

    string OperationName {
        get { return XmlConvert.DecodeName(operationName); }
    }

    string ServiceName { 
        get { return XmlConvert.DecodeName(serviceDescriptions[0].Services[0].Name); }
    }

    string ServiceNamespace {
        get { return serviceDescriptions[0].TargetNamespace; }
    }
    
    BasicProfileViolationCollection Warnings {
        get { 
            return warnings;
        }
    }
    string ServiceDocumentation { 
        get { return serviceDescriptions[0].Services[0].Documentation; }
    }

    string FileName {
        get { 
            return Path.GetFileName(Request.Path);
        }
    }

    string EscapedFileName {
        get { 
            return HttpUtility.UrlEncode(FileName, Encoding.UTF8);
        }
    }

    bool ShowingMethodList {
        get { return operationName == null; }
    }

    bool OperationExists {
        get { return operationExists; }
    }

  
    // encodes a Unicode string into utf-8 bytes then copies each byte into a new Unicode string,
    // escaping bytes > 0x7f, per the URI escaping rules
    static string UTF8EscapeString(string source) {
        byte[] bytes = Encoding.UTF8.GetBytes(source);
        StringBuilder sb = new StringBuilder(bytes.Length); // start out with enough room to hold each byte as a char
        for (int i = 0; i < bytes.Length; i++) {
            byte b = bytes[i];
            if (b > 0x7f) {
                sb.Append('%');
                sb.Append(hexTable[(b >> 4) & 0x0f]);
                sb.Append(hexTable[(b     ) & 0x0f]);
            }
            else
                sb.Append((char)b);
        }
        return sb.ToString();
    }

    string EscapeParam(string param) {
        return HttpUtility.UrlEncode(param, Request.ContentEncoding);
    }

    string GetSoapOperationInput(bool soap12) {
        OperationBinding opBinding = soap12 ? Soap12OperationBinding : SoapOperationBinding;
        if (opBinding == null) return "";
        WriteBegin();

        Port port = FindPort(opBinding.Binding);
        SoapAddressBinding soapAddress = (SoapAddressBinding)port.Extensions.Find(typeof(SoapAddressBinding));

        string action = UTF8EscapeString(((SoapOperationBinding)opBinding.Extensions.Find(typeof(SoapOperationBinding))).SoapAction);

        Uri uri = new Uri(soapAddress.Location, false);

        Write("POST ");
        Write(uri.AbsolutePath);
        Write(" HTTP/1.1");
        WriteLine();

        Write("Host: ");
        Write(uri.Host);
        WriteLine();

        if (soap12) {
            Write("Content-Type: application/soap+xml; charset=utf-8");
        }
        else {
            Write("Content-Type: text/xml; charset=utf-8");
        }
        WriteLine();

        Write("Content-Length: ");
        WriteValue("length");
        WriteLine();

        if (!soap12) {
            Write("SOAPAction: \"");
            Write(action);
            Write("\"");
            WriteLine();
        }

        WriteLine();
        
        Operation op = soap12 ? Soap12Operation : SoapOperation;
        WriteSoapMessage(opBinding.Input, serviceDescriptions.GetMessage(op.Messages.Input.Message), soap12);
        return WriteEnd();
    }

    string GetSoapOperationOutput(bool soap12) {
        OperationBinding opBinding = soap12 ? Soap12OperationBinding : SoapOperationBinding;
        if (opBinding == null) return "";
        WriteBegin();
        if (opBinding.Output == null) {
            Write("HTTP/1.1 202 Accepted");
            WriteLine();
        }
        else {
            Write("HTTP/1.1 200 OK");
            WriteLine();
            if (soap12) {
                Write("Content-Type: application/soap+xml; charset=utf-8");
            }
            else {
                Write("Content-Type: text/xml; charset=utf-8");
            }
            WriteLine();
            Write("Content-Length: ");
            WriteValue("length");
            WriteLine();
            WriteLine();

            Operation op = soap12 ? Soap12Operation : SoapOperation;
            WriteSoapMessage(opBinding.Output, serviceDescriptions.GetMessage(op.Messages.Output.Message), soap12);
        }
        return WriteEnd();
    }

    OperationBinding SoapOperationBinding {
        get { 
            if (soapOperationBinding == null)
                soapOperationBinding = FindBinding(typeof(SoapBinding));
            return soapOperationBinding;
        }
    }

    Operation SoapOperation {
        get { 
            if (soapOperation == null)
                soapOperation = FindOperation(SoapOperationBinding);
            return soapOperation;
        }
    }

    bool ShowingSoap {
        get { 
            return SoapOperationBinding != null; 
        }
    }

    OperationBinding Soap12OperationBinding {
        get { 
            if (soap12OperationBinding == null)
                soap12OperationBinding = FindBinding(typeof(Soap12Binding));
            return soap12OperationBinding;
        }
    }

    Operation Soap12Operation {
        get { 
            if (soap12Operation == null)
                soap12Operation = FindOperation(Soap12OperationBinding);
            return soap12Operation;
        }
    }

    bool ShowingSoap12 {
        get { 
            return Soap12OperationBinding != null; 
        }
    }

    private static string GetEncodedNamespace(string ns) {
        if (ns.EndsWith("/"))
            return ns + "encodedTypes";
        else return ns + "/encodedTypes";
    }

    void WriteSoapMessage(MessageBinding messageBinding, Message message, bool soap12) {
        objectId = 0;
        SoapOperationBinding soapBinding;
        SoapBodyBinding soapBodyBinding;
        
        string envelopeNs;
        string envelopeEncNs;
        string envelopePrefix;

        if (soap12) {
            envelopeNs = soap12Ns;
            envelopeEncNs = soap12EncNs;
            envelopePrefix = soap12Prefix;
            soapBinding = (SoapOperationBinding)Soap12OperationBinding.Extensions.Find(typeof(Soap12OperationBinding));
            soapBodyBinding = (SoapBodyBinding)messageBinding.Extensions.Find(typeof(Soap12BodyBinding));
        }
        else {
            envelopeNs = soapNs;
            envelopeEncNs = soapEncNs;
            envelopePrefix = soapPrefix;
            soapBinding = (SoapOperationBinding)SoapOperationBinding.Extensions.Find(typeof(SoapOperationBinding));
            soapBodyBinding = (SoapBodyBinding)messageBinding.Extensions.Find(typeof(SoapBodyBinding));
        }
        bool rpc = soapBinding != null && soapBinding.Style == SoapBindingStyle.Rpc;
        bool encoded = soapBodyBinding.Use == SoapBindingUse.Encoded;

        xmlWriter.WriteStartDocument();
        xmlWriter.WriteStartElement(envelopePrefix, "Envelope", envelopeNs);
        DefineNamespace("xsi", XmlSchema.InstanceNamespace);
        DefineNamespace("xsd", XmlSchema.Namespace);
        if (encoded) {
            DefineNamespace("soapenc", envelopeEncNs);
            string targetNamespace = message.ServiceDescription.TargetNamespace;
            DefineNamespace("tns", targetNamespace);
            DefineNamespace("types", GetEncodedNamespace(targetNamespace));
            if (soap12) {
                DefineNamespace("rpc", rpcNs);
            }
        }

        SoapHeaderBinding[] headers = (SoapHeaderBinding[])messageBinding.Extensions.FindAll(typeof(SoapHeaderBinding));
        if (headers.Length > 0) {
            xmlWriter.WriteStartElement("Header", envelopeNs);
            foreach (SoapHeaderBinding header in headers) {
                Message headerMessage = serviceDescriptions.GetMessage(header.Message);
                if (headerMessage != null) {
                    MessagePart part = headerMessage.Parts[header.Part];
                    if (part != null) {
                        if (encoded)
                            WriteType(part.Type, part.Type, true, XmlSchemaForm.Qualified, -1, 0, false, soap12);
                        else
                            WriteTopLevelElement(part.Element, 0, soap12);
                    }
                }
            }
            if (encoded)
                WriteQueuedTypes(soap12);
            xmlWriter.WriteEndElement();
        }

        xmlWriter.WriteStartElement("Body", envelopeNs);
        if (soapBodyBinding.Encoding != null && soapBodyBinding.Encoding != String.Empty)
            xmlWriter.WriteAttributeString("encodingStyle", envelopeNs, envelopeEncNs);

        if (rpc) {
            OperationBinding opBinding = soap12 ? Soap12OperationBinding : SoapOperationBinding;
            Operation op = soap12 ? Soap12Operation : SoapOperation;
            string messageName = opBinding.Output == messageBinding ? op.Name + "Response" : op.Name;
            if (encoded) {
                string prefix = null;
                if (soapBodyBinding.Namespace.Length > 0) {
                    prefix = xmlWriter.LookupPrefix(soapBodyBinding.Namespace);
                    if (prefix == null)
                        prefix = "q" + nextPrefix++;
                }
                xmlWriter.WriteStartElement(prefix, messageName, soapBodyBinding.Namespace);
                
                if (soap12 && message.Parts.Count > 0 && opBinding.Output == messageBinding) {
                    xmlWriter.WriteStartElement("result", rpcNs);
                    xmlWriter.WriteAttributeString("xmlns", "");
                    xmlWriter.WriteString(message.Parts[0].Name);
                    xmlWriter.WriteEndElement();
                }
            }
            else {
                xmlWriter.WriteStartElement(messageName, soapBodyBinding.Namespace);
            }
        }
        foreach (MessagePart part in message.Parts) {
            if (encoded) {
                if (rpc)
                    WriteType(new XmlQualifiedName(part.Name, soapBodyBinding.Namespace), part.Type, encoded, XmlSchemaForm.Unqualified, 0, 0, true, soap12);
                else
                    WriteType(part.Type, part.Type, encoded, XmlSchemaForm.Qualified, -1, 0, true, soap12); // id == -1 writes the definition without writing the id attr
            }
            else {
                if (rpc)
                    WriteType(new XmlQualifiedName(part.Name, null), part.Type, encoded, XmlSchemaForm.Unqualified, 0, 0, false, soap12);
                else if (!part.Element.IsEmpty)
                    WriteTopLevelElement(part.Element, 0, soap12);
                else
                    WriteXmlValue("xml");
            }
        }
        if (rpc) {
            xmlWriter.WriteEndElement();
        }
        if (encoded) {
            WriteQueuedTypes(soap12);
        }            
        xmlWriter.WriteEndElement();
        xmlWriter.WriteEndElement();
    }

    string HttpGetOperationInput {
        get { 
            if (TryGetUrl == null) return "";
            WriteBegin();

            Write("GET ");
            Write(TryGetUrl.AbsolutePath);

            Write("?");
            WriteQueryStringMessage(serviceDescriptions.GetMessage(HttpGetOperation.Messages.Input.Message));
            
            Write(" HTTP/1.1");
            WriteLine();

            Write("Host: ");
            Write(TryGetUrl.Host);
            WriteLine();

            return WriteEnd();
        }
    }

    string HttpGetOperationOutput {
        get { 
            if (HttpGetOperationBinding == null) return "";
            if (HttpGetOperationBinding.Output == null) return "";
            Message message = serviceDescriptions.GetMessage(HttpGetOperation.Messages.Output.Message);
            WriteBegin();
            Write("HTTP/1.1 200 OK");
            WriteLine();
            if (message.Parts.Count > 0) {
                Write("Content-Type: text/xml; charset=utf-8");
                WriteLine();
                Write("Content-Length: ");
                WriteValue("length");
                WriteLine();
                WriteLine();

                WriteHttpReturnPart(message.Parts[0].Element);
            }

            return WriteEnd();
        }
    }

    void WriteQueryStringMessage(Message message) {
        bool first = true;
        foreach (MessagePart part in message.Parts) {
            int count = 1;
            string typeName = part.Type.Name;
            if (part.Type.Namespace != XmlSchema.Namespace && part.Type.Namespace != msTypesNs) {
                int arrIndex = typeName.IndexOf("Array");
                if (arrIndex >= 0) {
                    typeName = CodeIdentifier.MakeCamel(typeName.Substring(0, arrIndex));
                    count = 2;
                }
            }
            for (int i=0; i<count; i++) {
                if (first) {
                    first = false; 
                }
                else {
                    Write("&amp;");
                }
                Write("<font class=key>");
                Write(XmlConvert.DecodeName(part.Name));
                Write("</font>=");
            
                WriteValue(typeName);
            }
        }
    }

    OperationBinding HttpGetOperationBinding {
        get { 
            if (httpGetOperationBinding == null)
                httpGetOperationBinding = FindHttpBinding("GET");
            return httpGetOperationBinding;
        }
    }

    Operation HttpGetOperation {
        get { 
            if (httpGetOperation == null)
                httpGetOperation = FindOperation(HttpGetOperationBinding);
            return httpGetOperation;
        }
    }

    bool ShowingHttpGet {
        get { 
            return HttpGetOperationBinding != null; 
        }
    }

    string HttpPostOperationInput {
        get { 
            if (TryPostUrl == null) return "";
            WriteBegin();

            Write("POST ");
            Write(TryPostUrl.AbsolutePath);

            Write(" HTTP/1.1");
            WriteLine();

            Write("Host: ");
            Write(TryPostUrl.Host);
            WriteLine();

            Write("Content-Type: application/x-www-form-urlencoded");
            WriteLine();
            Write("Content-Length: ");
            WriteValue("length");
            WriteLine();
            WriteLine();

            WriteQueryStringMessage(serviceDescriptions.GetMessage(HttpPostOperation.Messages.Input.Message));

            return WriteEnd();
        }
    }

    string HttpPostOperationOutput {
        get { 
            if (HttpPostOperationBinding == null) return "";
            if (HttpPostOperationBinding.Output == null) return "";
            Message message = serviceDescriptions.GetMessage(HttpPostOperation.Messages.Output.Message);
            WriteBegin();
            Write("HTTP/1.1 200 OK");
            WriteLine();
            if (message.Parts.Count > 0) {
                Write("Content-Type: text/xml; charset=utf-8");
                WriteLine();
                Write("Content-Length: ");
                WriteValue("length");
                WriteLine();
                WriteLine();

                WriteHttpReturnPart(message.Parts[0].Element);
            }

            return WriteEnd();
        }
    }

    OperationBinding HttpPostOperationBinding {
        get { 
            if (httpPostOperationBinding == null)
                httpPostOperationBinding = FindHttpBinding("POST");
            return httpPostOperationBinding;
        }
    }

    Operation HttpPostOperation {
        get { 
            if (httpPostOperation == null)
                httpPostOperation = FindOperation(HttpPostOperationBinding);
            return httpPostOperation;
        }
    }

    bool ShowingHttpPost {
        get { 
            return HttpPostOperationBinding != null; 
        }
    }

    MessagePart[] TryGetMessageParts {
        get { 
            if (HttpGetOperationBinding == null) return new MessagePart[0];
            Message message = serviceDescriptions.GetMessage(HttpGetOperation.Messages.Input.Message);
            MessagePart[] parts = new MessagePart[message.Parts.Count];
            message.Parts.CopyTo(parts, 0);
            return parts;
        }
    }

    bool ShowGetTestForm {
        get {
            if (!ShowingHttpGet) return false;
            Message message = serviceDescriptions.GetMessage(HttpGetOperation.Messages.Input.Message);
            foreach (MessagePart part in message.Parts) {
                if (part.Type.Namespace != XmlSchema.Namespace && part.Type.Namespace != msTypesNs)
                    return false;
            }
            return true;
        }
    }            

    Uri TryGetUrl {
        get {
            if (getUrl == null) {
                if (HttpGetOperationBinding == null) return null;
                Port port = FindPort(HttpGetOperationBinding.Binding);
                if (port == null) return null;
                HttpAddressBinding httpAddress = (HttpAddressBinding)port.Extensions.Find(typeof(HttpAddressBinding));
                HttpOperationBinding httpOperation = (HttpOperationBinding)HttpGetOperationBinding.Extensions.Find(typeof(HttpOperationBinding));
                if (httpAddress == null || httpOperation == null) return null;
                getUrl = new Uri(httpAddress.Location + httpOperation.Location);
            }
            return getUrl;
        }
    }

    MessagePart[] TryPostMessageParts {
        get { 
            if (HttpPostOperationBinding == null) return new MessagePart[0];
            Message message = serviceDescriptions.GetMessage(HttpPostOperation.Messages.Input.Message);
            MessagePart[] parts = new MessagePart[message.Parts.Count];
            message.Parts.CopyTo(parts, 0);
            return parts;
        }
    }

    bool ShowPostTestForm {
        get {
            if (!ShowingHttpPost) return false;
            Message message = serviceDescriptions.GetMessage(HttpPostOperation.Messages.Input.Message);
            foreach (MessagePart part in message.Parts) {
                if (part.Type.Namespace != XmlSchema.Namespace && part.Type.Namespace != msTypesNs)
                    return false;
            }
            return true;
        }
    }            

    Uri TryPostUrl {
        get {
            if (postUrl == null) {
                if (HttpPostOperationBinding == null) return null;
                Port port = FindPort(HttpPostOperationBinding.Binding);
                if (port == null) return null;
                HttpAddressBinding httpAddress = (HttpAddressBinding)port.Extensions.Find(typeof(HttpAddressBinding));
                HttpOperationBinding httpOperation = (HttpOperationBinding)HttpPostOperationBinding.Extensions.Find(typeof(HttpOperationBinding));
                if (httpAddress == null || httpOperation == null) return null;
                postUrl = new Uri(httpAddress.Location + httpOperation.Location);
            }
            return postUrl;
        }
    }

    void WriteHttpReturnPart(XmlQualifiedName elementName) {
        if (elementName == null || elementName.IsEmpty) {
            Write("&lt;?xml version=\"1.0\"?&gt;");
            WriteLine();
            WriteValue("xml");
        }
        else {
            xmlWriter.WriteStartDocument();
            WriteTopLevelElement(elementName, 0, false);
        }
    }

    XmlSchemaType GetPartType(MessagePart part) {
        if (part.Element != null && !part.Element.IsEmpty) {
            XmlSchemaElement element = (XmlSchemaElement)schemas.Find(part.Element, typeof(XmlSchemaElement));
            if (element != null) return element.SchemaType;
            return null;
        }
        else if (part.Type != null && !part.Type.IsEmpty) {
            XmlSchemaType xmlSchemaType = (XmlSchemaType)schemas.Find(part.Type, typeof(XmlSchemaSimpleType));
            if (xmlSchemaType != null) return xmlSchemaType;
            xmlSchemaType = (XmlSchemaType)schemas.Find(part.Type, typeof(XmlSchemaComplexType));
            return xmlSchemaType;
        }
        return null;
    }

    void WriteTopLevelElement(XmlQualifiedName name, int depth, bool soap12) {
        WriteTopLevelElement((XmlSchemaElement)schemas.Find(name, typeof(XmlSchemaElement)), name.Namespace, depth, soap12);
    }

    void WriteTopLevelElement(XmlSchemaElement element, string ns, int depth, bool soap12) {
        WriteElement(element, ns, XmlSchemaForm.Qualified, false, 0, depth, false, soap12);
    }

    class QueuedType {
        internal XmlQualifiedName name;
        internal XmlQualifiedName typeName;
        internal XmlSchemaForm form;
        internal int id;
        internal int depth;
        internal bool writeXsiType;
    }
    
    void WriteQueuedTypes(bool soap12) {
        while (referencedTypes.Count > 0) {
            QueuedType q = (QueuedType)referencedTypes.Dequeue();
            WriteType(q.name, q.typeName, true, q.form, q.id, q.depth, q.writeXsiType, soap12);
        }
    }
    
    void AddQueuedType(XmlQualifiedName name, XmlQualifiedName type, int id, int depth, bool writeXsiType) {
        AddQueuedType(name, type, XmlSchemaForm.Unqualified, id, depth, writeXsiType);
    }

    void AddQueuedType(XmlQualifiedName name, XmlQualifiedName typeName, XmlSchemaForm form, int id, int depth, bool writeXsiType) {
        QueuedType q = new QueuedType();
        q.name = name;
        q.typeName = typeName;
        q.form = form;
        q.id = id;
        q.depth = depth;
        q.writeXsiType = writeXsiType;
        referencedTypes.Enqueue(q);
    }

    void WriteType(XmlQualifiedName name, XmlQualifiedName typeName, int id, int depth, bool writeXsiType, bool soap12) {
        WriteType(name, typeName, true, XmlSchemaForm.None, id, depth, writeXsiType, soap12);
    }

    void WriteType(XmlQualifiedName name, XmlQualifiedName typeName, bool encoded, XmlSchemaForm form, int id, int depth, bool writeXsiType, bool soap12) {
        XmlSchemaElement element = new XmlSchemaElement();
        element.Name = name.Name;
        element.MaxOccurs = 1;
        element.Form = form;
        element.SchemaTypeName = typeName;
        WriteElement(element, name.Namespace, encoded, id, depth, writeXsiType, soap12);
    }

    void WriteElement(XmlSchemaElement element, string ns, bool encoded, int id, int depth, bool writeXsiType, bool soap12) {
        XmlSchemaForm form = element.Form;
        if (form == XmlSchemaForm.None) {
            XmlSchema schema = schemas[ns];
            if (schema != null) form = schema.ElementFormDefault;
        }
        WriteElement(element, ns, form, encoded, id, depth, writeXsiType, soap12);
    }

    void WriteElement(XmlSchemaElement element, string ns, XmlSchemaForm form, bool encoded, int id, int depth, bool writeXsiType, bool soap12) {
        if (element == null) return;
        int count = element.MaxOccurs > 1 ? maxArraySize : 1;

        for (int i = 0; i < count; i++) {
            XmlQualifiedName elementName = (element.QualifiedName == null || element.QualifiedName.IsEmpty ? new XmlQualifiedName(element.Name, ns) : element.QualifiedName);
            if (encoded && count > 1) {
                elementName = new XmlQualifiedName("Item", null);
            }

            if (IsRef(element.RefName)) {
                WriteTopLevelElement(element.RefName, depth, soap12);
                continue;
            }
            
            if (encoded) {
                string prefix = null;
                if (form != XmlSchemaForm.Unqualified && elementName.Namespace.Length > 0) {
                    prefix = xmlWriter.LookupPrefix(elementName.Namespace);
                    if (prefix == null)
                        prefix = "q" + nextPrefix++;
                }
                
                if (id != 0 && !soap12) { // intercept array definitions
                    XmlSchemaComplexType ct = null;
                    if (IsStruct(element, out ct)) {
                        XmlQualifiedName typeName = element.SchemaTypeName;
                        XmlQualifiedName baseTypeName = GetBaseTypeName(ct);
                        if (baseTypeName != null && IsArray(baseTypeName))
                            typeName = baseTypeName;
                        if (typeName != elementName) {
                            WriteType(typeName, element.SchemaTypeName, true, form, id, depth, writeXsiType, soap12);
                            return;
                        }
                    }
                }
                xmlWriter.WriteStartElement(prefix, elementName.Name, form != XmlSchemaForm.Unqualified ? elementName.Namespace : "");
            }
            else
                xmlWriter.WriteStartElement(elementName.Name, form != XmlSchemaForm.Unqualified ? elementName.Namespace : "");

            XmlSchemaSimpleType simpleType = null;
            XmlSchemaComplexType complexType = null;

            if (IsPrimitive(element.SchemaTypeName)) {
                if (writeXsiType) WriteTypeAttribute(element.SchemaTypeName);
                WritePrimitive(element.SchemaTypeName);
            }
            else if (IsEnum(element.SchemaTypeName, out simpleType)) {
                if (writeXsiType) WriteTypeAttribute(element.SchemaTypeName);
                WriteEnum(simpleType);
            }
            else if (IsStruct(element, out complexType)) {
                if (depth >= maxObjectGraphDepth)
                    WriteNullAttribute(encoded, soap12);
                else if (encoded) {
                    if (id != 0 || soap12) {
                        // id == -1 means write the definition without writing the id
                        if (id > 0 || soap12) {
                            WriteIDAttribute(id, soap12);
                        }
                        WriteComplexType(complexType, ns, encoded, depth, writeXsiType, soap12);
                    }
                    else {
                        int href = hrefID++;
                        WriteHref(href, soap12);
                        AddQueuedType(elementName, element.SchemaTypeName, XmlSchemaForm.Qualified, href, depth, true);
                    }
                }
                else {
                    WriteComplexType(complexType, ns, encoded, depth, false, soap12);
                }
            }
            else if (IsByteArray(element, out simpleType)) {
                WriteByteArray(simpleType);
            }
            else if (IsSchemaRef(element.RefName)) {
                WriteXmlValue("schema");
            }
            else if (IsUrType(element.SchemaTypeName)) {
                WriteTypeAttribute(new XmlQualifiedName(GetXmlValue("type"), null));
            }
            else {
                if (debug) {
                    WriteDebugAttribute("error", "Unknown type");
                    WriteDebugAttribute("elementName", element.QualifiedName.ToString());
                    WriteDebugAttribute("typeName", element.SchemaTypeName.ToString());
                    WriteDebugAttribute("type", element.SchemaType != null ? element.SchemaType.ToString() : "null");
                }
            }
            xmlWriter.WriteEndElement();
            xmlWriter.Formatting = Formatting.Indented;
        }
    }

    bool IsArray(XmlQualifiedName typeName) {
        return (typeName.Namespace == soapEncNs && typeName.Name == "Array");
    }

    bool IsPrimitive(XmlQualifiedName typeName) {
        return (!typeName.IsEmpty && 
                (typeName.Namespace == XmlSchema.Namespace || typeName.Namespace == msTypesNs) &&
                typeName.Name != urType);
    }

    bool IsRef(XmlQualifiedName refName) {
        return refName != null && !refName.IsEmpty && !IsSchemaRef(refName);
    }

    bool IsSchemaRef(XmlQualifiedName refName) {
        return refName != null && refName.Name == "schema" && refName.Namespace == XmlSchema.Namespace;
    }

    bool IsUrType(XmlQualifiedName typeName) {
        return (!typeName.IsEmpty && typeName.Namespace == XmlSchema.Namespace && typeName.Name == urType);
    }

    bool IsEnum(XmlQualifiedName typeName, out XmlSchemaSimpleType type) {
        XmlSchemaSimpleType simpleType = null;
        if (typeName != null && !typeName.IsEmpty) {
            simpleType = (XmlSchemaSimpleType)schemas.Find(typeName, typeof(XmlSchemaSimpleType));
            if (simpleType != null) {
                type = simpleType;
                return true;
            }
        }
        type = null;
        return false;
    }

    bool IsStruct(XmlSchemaElement element, out XmlSchemaComplexType type) {
        XmlSchemaComplexType complexType = null;

        if (!element.SchemaTypeName.IsEmpty) {
            complexType = (XmlSchemaComplexType)schemas.Find(element.SchemaTypeName, typeof(XmlSchemaComplexType));
            if (complexType != null) {
                type = complexType;
                return true;
            }
        }
        if (element.SchemaType != null && element.SchemaType is XmlSchemaComplexType) {
            complexType = element.SchemaType as XmlSchemaComplexType;
            if (complexType != null) {
                type = complexType;
                return true;
            }
        }
        type = null;
        return false;
    }

    bool IsByteArray(XmlSchemaElement element, out XmlSchemaSimpleType type) {
        if (element.SchemaTypeName.IsEmpty && element.SchemaType is XmlSchemaSimpleType) {
            type = element.SchemaType as XmlSchemaSimpleType;
            return true;
        }
        type = null;
        return false;
    }
    
    XmlQualifiedName ArrayItemType(string typeDef) {
        string ns;
        string name;

        int nsLen = typeDef.LastIndexOf(':');

        if (nsLen <= 0) {
            ns = "";
        }
        else {
            ns = typeDef.Substring(0, nsLen);
        }
        int nameLen = typeDef.IndexOf('[', nsLen + 1);

        if (nameLen <= nsLen) {
            return new XmlQualifiedName(urType, XmlSchema.Namespace);
        }
        name = typeDef.Substring(nsLen + 1, nameLen - nsLen - 1);

        return new XmlQualifiedName(name, ns);
    }

    void WriteByteArray(XmlSchemaSimpleType dataType) {
        WriteXmlValue("bytes");
    }

    void WriteEnum(XmlSchemaSimpleType dataType) {
        if (dataType.Content is XmlSchemaSimpleTypeList) { // "flags" enum -- appears inside a list
            XmlSchemaSimpleTypeList list = (XmlSchemaSimpleTypeList)dataType.Content;
            dataType = list.ItemType;
        }

        bool first = true;
        if (dataType.Content is XmlSchemaSimpleTypeRestriction) {
            XmlSchemaSimpleTypeRestriction restriction = (XmlSchemaSimpleTypeRestriction)dataType.Content;
            foreach (XmlSchemaFacet facet in restriction.Facets) {
                if (facet is XmlSchemaEnumerationFacet) {
                    if (!first) xmlWriter.WriteString(" or "); else first = false;
                    WriteXmlValue(facet.Value);
                }
            }
        }
    }

    void WriteArrayTypeAttribute(XmlQualifiedName type, int maxOccurs, bool soap12) {
        StringBuilder sb = new StringBuilder(type.Name);
        sb.Append("[");
        sb.Append(maxOccurs.ToString(CultureInfo.InvariantCulture));
        sb.Append("]");
        string prefix = DefineNamespace("q1", type.Namespace);
        if (soap12) {
            XmlQualifiedName typeName = new XmlQualifiedName(type.Name, prefix);
            xmlWriter.WriteAttributeString("itemType", soap12EncNs, typeName.ToString());
            xmlWriter.WriteAttributeString("arraySize", soap12EncNs, maxOccurs.ToString(CultureInfo.InvariantCulture));
        }
        else {
            XmlQualifiedName typeName = new XmlQualifiedName(sb.ToString(), prefix);
            xmlWriter.WriteAttributeString("arrayType", soapEncNs, typeName.ToString());
        }
    }

    void WriteTypeAttribute(XmlQualifiedName type) {
        string prefix = DefineNamespace("s0", type.Namespace);
        xmlWriter.WriteStartAttribute("type", XmlSchema.InstanceNamespace);
        xmlWriter.WriteString(new XmlQualifiedName(type.Name, prefix).ToString());
        xmlWriter.WriteEndAttribute();
    }

    void WriteNullAttribute(bool encoded, bool soap12) {
        if (encoded && !soap12)
            xmlWriter.WriteAttributeString("null", XmlSchema.InstanceNamespace, "1");
        else
            xmlWriter.WriteAttributeString("nil", XmlSchema.InstanceNamespace, "true");
    }

    void WriteIDAttribute(int href, bool soap12) {
        if (soap12) {
            xmlWriter.WriteAttributeString("id", soap12EncNs, "id" + objectId.ToString(CultureInfo.InvariantCulture));
            objectId++;
        }
        else {
            xmlWriter.WriteAttributeString("id", "id" + href.ToString(CultureInfo.InvariantCulture));
        }
    }

    void WriteHref(int href, bool soap12) {
        if (soap12) {
            xmlWriter.WriteAttributeString("ref", "id" + href.ToString(CultureInfo.InvariantCulture));
        }
        else {
            xmlWriter.WriteAttributeString("href", "#id" + href.ToString(CultureInfo.InvariantCulture));
        }
    }

    void WritePrimitive(XmlQualifiedName name) {
        if (name.Namespace == XmlSchema.Namespace && name.Name == "QName") {
            DefineNamespace("q1", "http://tempuri.org/SampleNamespace");
            WriteXmlValue("q1:QName");
        }
        else
            WriteXmlValue(name.Name);
    }
        
    XmlQualifiedName GetBaseTypeName(XmlSchemaComplexType complexType) {
        if (complexType.ContentModel is XmlSchemaComplexContent) {
            XmlSchemaComplexContent content = (XmlSchemaComplexContent)complexType.ContentModel;
            if (content.Content is XmlSchemaComplexContentRestriction) {
                XmlSchemaComplexContentRestriction restriction = (XmlSchemaComplexContentRestriction)content.Content;
                return restriction.BaseTypeName;
            }
        }
        return null;
    }

    internal class TypeItems {
        internal XmlSchemaObjectCollection Attributes = new XmlSchemaObjectCollection();
        internal XmlSchemaAnyAttribute AnyAttribute;
        internal XmlSchemaObjectCollection Items = new XmlSchemaObjectCollection();
        internal XmlQualifiedName baseSimpleType;
    }

    TypeItems GetTypeItems(XmlSchemaComplexType type) {
        TypeItems items = new TypeItems();
        if (type == null)
            return items;

        XmlSchemaParticle particle = null;
        if (type.ContentModel != null) {
            XmlSchemaContent content = type.ContentModel.Content;
            if (content is XmlSchemaComplexContentExtension) {
                XmlSchemaComplexContentExtension extension = (XmlSchemaComplexContentExtension)content;
                items.Attributes = extension.Attributes;
                items.AnyAttribute = extension.AnyAttribute;
                particle = extension.Particle;
            }
            else if (content is XmlSchemaComplexContentRestriction) {
                XmlSchemaComplexContentRestriction restriction = (XmlSchemaComplexContentRestriction)content;
                items.Attributes = restriction.Attributes;
                items.AnyAttribute = restriction.AnyAttribute;
                particle = restriction.Particle;
            }
            else if (content is XmlSchemaSimpleContentExtension) {
                XmlSchemaSimpleContentExtension extension = (XmlSchemaSimpleContentExtension)content;
                items.Attributes = extension.Attributes;
                items.AnyAttribute = extension.AnyAttribute;
                items.baseSimpleType = extension.BaseTypeName;
            }
            else if (content is XmlSchemaSimpleContentRestriction) {
                XmlSchemaSimpleContentRestriction restriction = (XmlSchemaSimpleContentRestriction)content;
                items.Attributes = restriction.Attributes;
                items.AnyAttribute = restriction.AnyAttribute;
                items.baseSimpleType = restriction.BaseTypeName;
            }
        }
        else {
            items.Attributes = type.Attributes;
            items.AnyAttribute = type.AnyAttribute;
            particle = type.Particle;
        }
        if (particle != null) {
            bool sort = false;
            if (particle is XmlSchemaGroupRef) {
                XmlSchemaGroupRef refGroup = (XmlSchemaGroupRef)particle;

                XmlSchemaGroup group = (XmlSchemaGroup)schemas.Find(refGroup.RefName, typeof(XmlSchemaGroup));
                if (group != null) {
                    items.Items = group.Particle.Items;
                    sort = group.Particle is XmlSchemaChoice || group.Particle is XmlSchemaAll;
                }
            }
            else if (particle is XmlSchemaGroupBase) {
                items.Items = ((XmlSchemaGroupBase)particle).Items;
                sort = particle is XmlSchemaChoice || particle is XmlSchemaAll;
            }
            if (sort) {
                ArrayList list = new ArrayList();
                for (int i = 0; i < items.Items.Count; i++) {
                    list.Add(items.Items[i]);
                }
                list.Sort(new XmlSchemaObjectComparer());
                XmlSchemaObjectCollection sortedItems = new XmlSchemaObjectCollection();
                for (int i = 0; i < list.Count; i++) {
                    sortedItems.Add((XmlSchemaObject)list[i]);
                }
                items.Items = sortedItems;
            }
        }
        return items;
    }
    
    internal class XmlSchemaObjectComparer : IComparer {
        public int Compare(object o1, object o2) {
            return string.Compare(NameOf((XmlSchemaObject)o1), NameOf((XmlSchemaObject)o2), StringComparison.Ordinal);
        }

        internal static string NameOf(XmlSchemaObject o) {
            if (o is XmlSchemaElement) {
                return ((XmlSchemaElement)o).Name;
            }
            else if (o is XmlSchemaAny) {
                return "*";
            }
            else {
                return "**";
            }
        }
    }
   
    void WriteComplexType(XmlSchemaComplexType type, string ns, bool encoded, int depth, bool writeXsiType, bool soap12) {
        bool wroteArrayType = false;
        bool isSoapArray = false;
        TypeItems typeItems = GetTypeItems(type);
        if (encoded) {
            /*
              Check to see if the type looks like the new WSDL 1.1 array delaration:

              <xsd:complexType name="ArrayOfInt">
                <xsd:complexContent mixed="false">
                  <xsd:restriction base="soapenc:Array">
                    <xsd:attribute ref="soapenc:arrayType" wsdl:arrayType="xsd:int[]" />
                  </xsd:restriction>
                </xsd:complexContent>
              </xsd:complexType>

            */

            XmlQualifiedName itemType = null;
            XmlQualifiedName topItemType = null;
            string brackets = "";
            XmlSchemaComplexType t = type;
            XmlQualifiedName baseTypeName = GetBaseTypeName(t);
            TypeItems arrayItems = typeItems;
            while (t != null) {
                XmlSchemaObjectCollection attributes = arrayItems.Attributes;
                t = null; // if we don't set t after this stop looping
                if (baseTypeName != null && IsArray(baseTypeName) && attributes.Count > 0) {
                    XmlSchemaAttribute refAttr = attributes[0] as XmlSchemaAttribute;
                    if (refAttr != null) {
                        XmlQualifiedName qnameArray = refAttr.RefName;
                        if (qnameArray.Namespace == soapEncNs && qnameArray.Name == "arrayType") {
                            isSoapArray = true;
                            XmlAttribute typeAttribute = refAttr.UnhandledAttributes[0];
                            if (typeAttribute.NamespaceURI == wsdlNs && typeAttribute.LocalName == "arrayType") {
                                itemType = ArrayItemType(typeAttribute.Value);
                                if (topItemType == null)
                                    topItemType = itemType;
                                else
                                    brackets += "[]";

                                if (!IsPrimitive(itemType)) {
                                    t = (XmlSchemaComplexType)schemas.Find(itemType, typeof(XmlSchemaComplexType));
                                    arrayItems = GetTypeItems(t);
                                }
                            }
                        }
                    }
                }
            }
            if (itemType != null) {
                wroteArrayType = true;
                if (IsUrType(itemType))
                    WriteArrayTypeAttribute(new XmlQualifiedName(GetXmlValue("type") + brackets, null), maxArraySize, soap12);
                else
                    WriteArrayTypeAttribute(new XmlQualifiedName(itemType.Name + brackets, itemType.Namespace), maxArraySize, soap12);
                
                for (int i = 0; i < maxArraySize; i++) {
                    WriteType(new XmlQualifiedName("Item", null), topItemType, 0, depth+1, false, soap12);
                }
            }
        }

        if (writeXsiType && !wroteArrayType) {
            WriteTypeAttribute(type.QualifiedName);
        }

        if (!isSoapArray) {
            foreach (XmlSchemaAttribute attr in typeItems.Attributes) {
                if (attr != null && attr.Use != XmlSchemaUse.Prohibited) {
                    if (attr.Form == XmlSchemaForm.Qualified && attr.QualifiedName != null)
                        xmlWriter.WriteStartAttribute(attr.Name, attr.QualifiedName.Namespace);
                    else
                        xmlWriter.WriteStartAttribute(attr.Name, null);

                    XmlSchemaSimpleType dataType = null;

                    // special code for the QNames
                    if (attr.SchemaTypeName.Namespace == XmlSchema.Namespace && attr.SchemaTypeName.Name == "QName") {
                        WriteXmlValue("q1:QName");
                        xmlWriter.WriteEndAttribute();
                        DefineNamespace("q1", "http://tempuri.org/SampleNamespace");
                    }
                    else {
                        if (IsPrimitive(attr.SchemaTypeName)) 
                            WriteXmlValue(attr.SchemaTypeName.Name);
                        else if (IsEnum(attr.SchemaTypeName, out dataType))
                            WriteEnum(dataType);
                        xmlWriter.WriteEndAttribute();
                    }
                }
            }
        }

        XmlSchemaObjectCollection items = typeItems.Items;
        foreach (object item in items) {
            if (item is XmlSchemaElement) {
                WriteElement((XmlSchemaElement)item, ns, encoded, 0, depth + 1, encoded, soap12);
            }
            else if (item is XmlSchemaAny) {
                XmlSchemaAny any = (XmlSchemaAny)item;
                XmlSchema schema = schemas[any.Namespace];
                if (schema == null) {
                    WriteXmlValue("xml");
                }
                else {
                    foreach (object schemaItem in schema.Items) {
                        if (schemaItem is XmlSchemaElement) {
                            if (IsDataSetRoot((XmlSchemaElement)schemaItem))
                                WriteXmlValue("dataset");
                            else
                                WriteTopLevelElement((XmlSchemaElement)schemaItem, any.Namespace, depth + 1, soap12);
                        }
                    }
                }
            }
        }
    }

    bool IsDataSetRoot(XmlSchemaElement element) {
        if (element.UnhandledAttributes == null) return false;
        foreach (XmlAttribute a in element.UnhandledAttributes) {
            if (a.NamespaceURI == "urn:schemas-microsoft-com:xml-msdata" && a.LocalName == "IsDataSet")
                return true;
        }
        return false;
    }

    void WriteBegin() {
        writer = new StringWriter();
        xmlSrc = new MemoryStream();
        xmlWriter = new XmlTextWriter(xmlSrc, new UTF8Encoding(false));
        xmlWriter.Formatting = Formatting.Indented;
        xmlWriter.Indentation = 2;
        referencedTypes = new Queue();
        hrefID = 1;
    }

    string WriteEnd() {
        xmlWriter.Flush();
        xmlSrc.Position = 0;
        StreamReader reader = new StreamReader(xmlSrc, Encoding.UTF8);
        writer.Write(HtmlEncode(reader.ReadToEnd()));
        return writer.ToString();
    }

    string HtmlEncode(string text) {
        StringBuilder sb = new StringBuilder();
        for (int i=0; i<text.Length; i++) {
            char c = text[i];
            if (c == '&') {
                string special = ReadComment(text, i);
                if (special.Length > 0) {
                    sb.Append(Server.HtmlDecode(special));
                    i += (special.Length + "&lt;!--".Length + "--&gt;".Length - 1);
                }
                else
                    sb.Append("&amp;");
            }
            else if (c == '<')
                sb.Append("&lt;");
            else if (c == '>')
                sb.Append("&gt;");
            else
                sb.Append(c);
        }
        return sb.ToString();
    }

    string ReadComment(string text, int index) {
        if (dontFilterXml) return String.Empty;
        if (string.Compare(text, index, "&lt;!--", 0, "&lt;!--".Length, StringComparison.Ordinal) == 0) {
            int start = index + "&lt;!--".Length;
            int end = text.IndexOf("--&gt;", start);
            if (end < 0) return String.Empty;
            return text.Substring(start, end-start);
        }
        return String.Empty;
    }

    void Write(string text) {
        writer.Write(text);
    }

    void WriteLine() {
        writer.WriteLine();
    }

    void WriteValue(string text) {
        Write("<font class=value>" + text + "</font>");
    }

    void WriteStartXmlValue() {
        xmlWriter.WriteString("<!--<font class=value>");
    }

    void WriteEndXmlValue() {
        xmlWriter.WriteString("</font>-->");
    }

    void WriteDebugAttribute(string text) {
        WriteDebugAttribute("debug", text);
    }

    void WriteDebugAttribute(string id, string text) {
        xmlWriter.WriteAttributeString(id, text);
    }

    string GetXmlValue(string text) {
        return "<!--<font class=value>" + text + "</font>-->";
    }

    void WriteXmlValue(string text) {
        xmlWriter.WriteString(GetXmlValue(text));
    }

    string DefineNamespace(string prefix, string ns) {
        if (ns == null || ns == String.Empty) return null;
        string existingPrefix = xmlWriter.LookupPrefix(ns);
        if (existingPrefix != null && existingPrefix.Length > 0)
            return existingPrefix;
        xmlWriter.WriteAttributeString("xmlns", prefix, null, ns);
        return prefix;
    }

    Port FindPort(Binding binding) {
        foreach (ServiceDescription description in serviceDescriptions) {
            foreach (Service service in description.Services) {
                foreach (Port port in service.Ports) {
                    if (port.Binding.Name == binding.Name &&
                        port.Binding.Namespace == binding.ServiceDescription.TargetNamespace) {
                        return port;
                    }
                }
            }
        }
        return null;
    }

    OperationBinding FindBinding(Type bindingType) {
        OperationBinding nextBestMatch = null;
        foreach (ServiceDescription description in serviceDescriptions) {
            foreach (Binding binding in description.Bindings) {
                object ext = binding.Extensions.Find(bindingType);
                if (ext == null) continue;
                foreach (OperationBinding operationBinding in binding.Operations) {
                    string messageName = operationBinding.Input.Name;
                    if (messageName == null || messageName.Length == 0) 
                        messageName = operationBinding.Name;
                    if (messageName == operationName) {
                        if (ext.GetType() != bindingType) continue;
                        else return operationBinding;
                    }
                }
            }
        }
        return nextBestMatch;
    }

    OperationBinding FindHttpBinding(string verb) {
        foreach (ServiceDescription description in serviceDescriptions) {
            foreach (Binding binding in description.Bindings) {
                HttpBinding httpBinding = (HttpBinding)binding.Extensions.Find(typeof(HttpBinding));
                if (httpBinding == null) 
                    continue;
                if (httpBinding.Verb != verb) 
                    continue;
                foreach (OperationBinding operationBinding in binding.Operations) {
                    string messageName = operationBinding.Input.Name;
                    if (messageName == null || messageName.Length == 0) 
                        messageName = operationBinding.Name;
                    if (messageName == operationName) 
                        return operationBinding;
                }
            }
        }
        return null;
    }

    Operation FindOperation(OperationBinding operationBinding) {
        PortType portType = serviceDescriptions.GetPortType(operationBinding.Binding.Type);
        foreach (Operation operation in portType.Operations) {
            if (operation.IsBoundBy(operationBinding)) {
                return operation;
            }
        }
        return null;
    }

    string GetLocalizedText(string name) {
      return GetLocalizedText(name, new object[0]);
    }

    string GetLocalizedText(string name, object[] args) {
      ResourceManager rm = (ResourceManager)Application["RM"];
      string val = rm.GetString("HelpGenerator" + name);
      if (val == null) return String.Empty;
      return String.Format(val, args);
    }

    void Page_Load(object sender, EventArgs e) {
        if (Application["RM"] == null) {
            lock (this.GetType()) {
                if (Application["RM"] == null) {
                    Application["RM"] = new ResourceManager("System.Web.Services", typeof(System.Web.Services.WebService).Assembly);
                }
            }
        }

        operationName = Request.QueryString["op"];

        // Slots filled on HttpContext:
        // "wsdls"              A ServiceDescriptionCollection representing what is displayed for .asmx?wsdl
        // "schemas"            An XmlSchemas object containing schemas associated with .asmx?wsdl
        // "wsdlsWithPost"      Wsdls the same as "wsdls", plus bindings for the HttpPost protocol.
        // "schemasWithPost"    Schemas corresponding to "wsdlsWithPost".
        // The objects stored at "wsdlsWithPost" and "schemasWithPost" are available if
        // the HttpPost protocol is turned on in config.
        
        // Obtain WSDL contract from Http Context

        XmlSchemas schemasToUse;
        serviceDescriptions = (ServiceDescriptionCollection) Context.Items["wsdlsWithPost"];
        if (serviceDescriptions != null) {
            requestIsLocal = true;
            schemasToUse = (XmlSchemas) Context.Items["schemasWithPost"];
        }
        else {
            serviceDescriptions = (ServiceDescriptionCollection) Context.Items["wsdls"];
            schemasToUse = (XmlSchemas) Context.Items["schemas"];
        }
        
        
        schemas = new XmlSchemas();
        foreach (XmlSchema schema in schemasToUse) {
            schemas.Add(schema);
        }
        foreach (ServiceDescription description in serviceDescriptions) {
            foreach (XmlSchema schema in description.Types.Schemas) {
                schemas.Add(schema);
            }
        }

        SortedList methodsTable = new SortedList(StringComparer.Ordinal);
        operationExists = false;
        
        
        foreach (ServiceDescription description in serviceDescriptions) {
            foreach (PortType portType in description.PortTypes) {
                foreach (Operation operation in portType.Operations) {
                    string messageName = operation.Messages.Input.Name;
                    if (messageName == null || messageName.Length == 0) 
                        messageName = operation.Name;
                    if (messageName == operationName) 
                        operationExists = true;
                    if (messageName == null)
                        messageName = String.Empty;
                    methodsTable[messageName] = operation;
                }
            }
        }
        bool checkClaims = ((WsiProfiles)Context.Items["conformanceWarnings"] & WsiProfiles.BasicProfile1_1) != 0;
        if (checkClaims) {
            warnings = new BasicProfileViolationCollection();
            WebServicesInteroperability.CheckConformance(WsiProfiles.BasicProfile1_1, serviceDescriptions, warnings);
        }
        MethodList.DataSource = methodsTable;
        // Databind all values within the page
        Page.DataBind();
    }

  </script>

  <head runat=server>

    <link rel="alternate" type="text/xml" href='<%#Uri.EscapeUriString(Request.Path).Replace("#", "%23") + "?disco"%>'/>

    <style type="text/css">
    
		BODY { <%#GetLocalizedText("StyleBODY")%> }
		#content { <%#GetLocalizedText("Stylecontent")%> }
		A:link { <%#GetLocalizedText("StyleAlink")%> }
		A:visited { <%#GetLocalizedText("StyleAvisited")%> }
		A:active { <%#GetLocalizedText("StyleAactive")%> }
		A:hover { <%#GetLocalizedText("StyleAhover")%> }
		P { <%#GetLocalizedText("StyleP")%> }
		pre { <%#GetLocalizedText("Stylepre")%> }
		td { <%#GetLocalizedText("Styletd")%> }
		h2 { <%#GetLocalizedText("Styleh2")%> }
		h3 { <%#GetLocalizedText("Styleh3")%> }
		ul { <%#GetLocalizedText("Styleul")%> }
		ol { <%#GetLocalizedText("Styleol")%> }
		li { <%#GetLocalizedText("Styleli")%> }
		font.value { <%#GetLocalizedText("Stylefontvalue")%> }
		font.key { <%#GetLocalizedText("Stylefontkey")%> }
		font.error { <%#GetLocalizedText("StylefontError")%> }
		.heading1 { <%#GetLocalizedText("Styleheading1")%> }
		.button { <%#GetLocalizedText("Stylebutton")%> }
		.frmheader { <%#GetLocalizedText("Stylefrmheader")%> }
		.frmtext { <%#GetLocalizedText("Stylefrmtext")%> }
		.frmInput { <%#GetLocalizedText("StylefrmInput")%> }
		.intro { <%#GetLocalizedText("Styleintro")%> }
           
    </style>

    <title><%#ServiceName + " " + GetLocalizedText("WebService")%></title>

  </head>

  <body>

    <div id="content">

      <p class="heading1"><%#ServiceName%></p><br>

      <span visible='<%#ShowingMethodList && ServiceDocumentation.Length > 0%>' runat=server>
          <p class="intro"><%#ServiceDocumentation%></p>
      </span>

      <span visible='<%#ShowingMethodList%>' runat=server>

          <p class="intro"><%#GetLocalizedText("OperationsIntro", new object[] { EscapedFileName + "?WSDL" })%> </p>
          
          <asp:repeater id="MethodList" runat=server>
      
            <headertemplate>
              <ul>
            </headertemplate>
      
            <itemtemplate>
              <li>
                <a href="<%#EscapedFileName%>?op=<%#EscapeParam(DataBinder.Eval(Container.DataItem, "Key").ToString())%>"><%#XmlConvert.DecodeName((string)DataBinder.Eval(Container.DataItem, "Value.Name"))%></a>
                <span visible='<%#((string)DataBinder.Eval(Container.DataItem, "Key")) != (string)DataBinder.Eval(Container.DataItem, "Value.Name") %>' runat=server>
                  <br>MessageName="<%#DataBinder.Eval(Container.DataItem, "Key")%>"
                </span>
                <span visible='<%#((string)DataBinder.Eval(Container.DataItem, "Value.Documentation")).Length>0%>' runat=server>
                  <br><%#DataBinder.Eval(Container.DataItem, "Value.Documentation")%>
                </span>
              </li>
              <p>
            </itemtemplate>
            <footertemplate>
              </ul>
            </footertemplate>
      
          </asp:repeater>
      </span>

      <span visible='<%#!ShowingMethodList && OperationExists%>' runat=server>
          <p class="intro"><%#GetLocalizedText("LinkBack", new object[] { EscapedFileName })%></p>
          <h2><%#OperationName%></h2>
          <p class="intro"><%#SoapOperationBinding == null ? "" : SoapOperation.Documentation%></p>

          <h3><%#GetLocalizedText("TestHeader")%></h3>
          
          <% if (!showPost) { 
                 if (!ShowingHttpGet) { %>
                     <%#GetLocalizedText("NoHttpGetTest")%>
              <% }
                 else {
                     if (!ShowGetTestForm) { %>
                        <%#GetLocalizedText("NoTestNonPrimitive")%>
                  <% }
                     else { %>

                      <%#GetLocalizedText("TestText")%>

                      <form target="_blank" action='<%#TryGetUrl == null ? "" : TryGetUrl.AbsoluteUri%>' method="GET">
                        <asp:repeater datasource='<%#TryGetMessageParts%>' runat=server>

                        <headertemplate>
                           <table cellspacing="0" cellpadding="4" frame="box" bordercolor="#dcdcdc" rules="none" style="border-collapse: collapse;">
  						   <tr visible='<%# TryGetMessageParts.Length > 0%>' runat=server>
                            <td class="frmHeader" background="#dcdcdc" style="border-right: 2px solid white;"><%#GetLocalizedText("Parameter")%></td>
                            <td class="frmHeader" background="#dcdcdc"><%#GetLocalizedText("Value")%></td>
                          </tr>
                        </headertemplate>

                        <itemtemplate>
                          <tr>
                            <td class="frmText" style="color: #000000; font-weight:normal;"><%# XmlConvert.DecodeName(((MessagePart)Container.DataItem).Name) %>:</td>
                            <td><input class="frmInput" type="text" size="50" name="<%# XmlConvert.DecodeName(((MessagePart)Container.DataItem).Name) %>"></td>
                          </tr>
                        </itemtemplate>

                        <footertemplate>
                          <tr>
                            <td></td>
                            <td align="right"> <input type="submit" value="<%#GetLocalizedText("InvokeButton")%>" class="button"></td>
                          </tr>
                          </table>
                        </footertemplate>
                    </asp:repeater>

                      </form>
                  <% } 
                 }
             }
             else { // showPost
                 if (!ShowingHttpPost) { 
                    if (requestIsLocal) { %>
                        <%#GetLocalizedText("NoTestNonPrimitive")%>
                 <% }
                    else { %>
                        <%#GetLocalizedText("NoTestFormRemote")%>
                 <% }
                 }
                 else {
                     if (!ShowPostTestForm) { %>
                        <%#GetLocalizedText("NoTestNonPrimitive")%>
                     
                  <% }
                     else { %>                      

                    
                      <%#GetLocalizedText("TestText")%>



                      <form target="_blank" action='<%#TryPostUrl == null ? "" : TryPostUrl.AbsoluteUri%>' method="POST">                      
                        <asp:repeater datasource='<%#TryPostMessageParts%>' runat=server>

                        <headertemplate>
                          <table cellspacing="0" cellpadding="4" frame="box" bordercolor="#dcdcdc" rules="none" style="border-collapse: collapse;">
                          <tr visible='<%# TryPostMessageParts.Length > 0%>' runat=server>
                            <td class="frmHeader" background="#dcdcdc" style="border-right: 2px solid white;"><%#GetLocalizedText("Parameter")%></td>
                            <td class="frmHeader" background="#dcdcdc"><%#GetLocalizedText("Value")%></td>
                          </tr>
                        </headertemplate>

                        <itemtemplate>
                          <tr>
                            <td class="frmText" style="color: #000000; font-weight: normal;"><%# XmlConvert.DecodeName(((MessagePart)Container.DataItem).Name) %>:</td>
                            <td><input class="frmInput" type="text" size="50" name="<%# XmlConvert.DecodeName(((MessagePart)Container.DataItem).Name) %>"></td>
                          </tr>
                        </itemtemplate>                        
						
                        <footertemplate>
                        <tr>
                          <td></td>
                          <td align="right"> <input type="submit" value="<%#GetLocalizedText("InvokeButton")%>" class="button"></td>
                        </tr>
                        </table>
                      </footertemplate>
                    </asp:repeater>

                    </form>
                  <% }
                 }
             } %>
          <span visible='<%#ShowingSoap%>' runat=server>
              <h3><%#GetLocalizedText("SoapTitle")%></h3>
              <p><%#GetLocalizedText("SoapText")%></p>

              <pre><%#GetSoapOperationInput(false)%></pre>

              <pre><%#GetSoapOperationOutput(false)%></pre>
          </span>

          <span visible='<%#ShowingSoap12%>' runat=server>
              <h3><%#GetLocalizedText("Soap1_2Title")%></h3>
              <p><%#GetLocalizedText("Soap1_2Text")%></p>

              <pre><%#GetSoapOperationInput(true)%></pre>

              <pre><%#GetSoapOperationOutput(true)%></pre>
          </span>

          <span visible='<%#ShowingHttpGet%>' runat=server>
              <h3><%#GetLocalizedText("HttpGetTitle")%></h3>
              <p><%#GetLocalizedText("HttpGetText")%></p>

              <pre><%#HttpGetOperationInput%></pre>

              <pre><%#HttpGetOperationOutput%></pre>
          </span>

          <span visible='<%#ShowingHttpPost%>' runat=server>
              <h3><%#GetLocalizedText("HttpPostTitle")%></h3>
              <p><%#GetLocalizedText("HttpPostText")%></p>

              <pre><%#HttpPostOperationInput%></pre>

              <pre><%#HttpPostOperationOutput%></pre>
          </span>

      </span>
      

    <span visible='<%#ShowingMethodList%>' runat=server>
        <span visible='<%#Warnings.Count > 0%>' runat=server>
            <hr>
            <h3><font class="error"><%#GetLocalizedText("ServiceConformance")%></font></h3>
            <p class="intro"><%#GetLocalizedText("ServiceConformanceDetails")%></p>
            <p class="intro"><%#GetLocalizedText("ServiceConformanceConfig")%></p>
            <pre>&lt;configuration&gt;
  &lt;system.web&gt;
    &lt;webServices&gt;
      &lt;conformanceWarnings&gt;
        &lt;<font class=value>remove name='BasicProfile1_1'</font>/&gt;
      &lt;/conformanceWarnings&gt;
    &lt;/webServices&gt;
  &lt;/system.web&gt;
&lt;/configuration&gt;</pre>

        <h3><%#GetLocalizedText("ServiceConformanceList")%></h3>
        
        <asp:repeater datasource='<%#Warnings%>' runat=server>
            <itemtemplate>
                <br><font class=error><%#((BasicProfileViolation)Container.DataItem).NormativeStatement%></font>: <%#((BasicProfileViolation)Container.DataItem).Details%>
                
                <asp:repeater datasource='<%#((BasicProfileViolation)Container.DataItem).Elements%>' runat=server>
                    <itemtemplate>
                        <br>  
                        -  <%#Container.DataItem%>
                    </itemtemplate>   
                </asp:repeater>

                <span visible='<%#((BasicProfileViolation)Container.DataItem).Recommendation != null%>' runat=server>
                    <br><font class=key><%#GetLocalizedText("Recommendation")%>:</font> <%#((BasicProfileViolation)Container.DataItem).Recommendation%>
                </span>
                <br>                
            </itemtemplate>
        </asp:repeater>
        <br>
            <p class="intro"><%#GetLocalizedText("ServiceConformanceHelp")%></p>
        </span>
    </span>
    
      <span visible='<%#ShowingMethodList && ServiceNamespace == "http://tempuri.org/"%>' runat=server>
          <hr>
          <h3><%#GetLocalizedText("DefaultNamespaceWarning1")%></h3>
          <h3><%#GetLocalizedText("DefaultNamespaceWarning2")%></h3>
          <p class="intro"><%#GetLocalizedText("DefaultNamespaceHelp1")%></p>
          <p class="intro"><%#GetLocalizedText("DefaultNamespaceHelp2")%></p>
          <p class="intro"><%#GetLocalizedText("DefaultNamespaceHelp3")%></p>
          <p class="intro">C#</p>
          <pre>[WebService(Namespace="http://microsoft.com/webservices/")]
public class MyWebService {
    // <%#GetLocalizedText("Implementation")%>
}</pre>
          <p class="intro">Visual Basic</p>
          <pre>&lt;WebService(Namespace:="http://microsoft.com/webservices/")&gt; Public Class MyWebService
    ' <%#GetLocalizedText("Implementation")%>
End Class</pre>

          <p class="intro">C++</p>
          <pre>[WebService(Namespace="http://microsoft.com/webservices/")]
public ref class MyWebService {
    // <%#GetLocalizedText("Implementation")%>
};</pre>
          <p class="intro"><%#GetLocalizedText("DefaultNamespaceHelp4")%></p>
          <p class="intro"><%#GetLocalizedText("DefaultNamespaceHelp5")%></p>
          <p class="intro"><%#GetLocalizedText("DefaultNamespaceHelp6")%></p>
      </span>

      <span visible='<%#!ShowingMethodList && !OperationExists%>' runat=server>
          <%#GetLocalizedText("LinkBack", new object[] { EscapedFileName })%>
          <h2><%#GetLocalizedText("MethodNotFound")%></h2>
          <%#GetLocalizedText("MethodNotFoundText", new object[] { Server.HtmlEncode(OperationName), ServiceName })%>
      </span>

    
  </body>
</html>
