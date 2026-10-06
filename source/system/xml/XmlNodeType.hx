package system.xml;

// Minimal System.Xml.XmlNodeType shim (values match .NET's XmlNodeType).
enum abstract XmlNodeType(Int) {
    var None = 0;
    var Element = 1;
    var Attribute = 2;
    var Text = 3;
    var CDATA = 4;
    var EntityReference = 5;
    var Entity = 6;
    var ProcessingInstruction = 7;
    var Comment = 8;
    var Document = 9;
    var DocumentType = 10;
    var DocumentFragment = 11;
    var Notation = 12;
    var Whitespace = 13;
    var SignificantWhitespace = 14;
    var EndElement = 15;
    var EndEntity = 16;
    var XmlDeclaration = 17;
}
