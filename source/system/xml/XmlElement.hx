// Ported from: System.Xml.XmlElement (minimal shim)
// PORT-NOTE: XmlNode is implemented as an abstract in this port (so that C#'s `node["name"]`
// indexer keeps working); the System.Xml subtypes are thin wrappers over it.
package system.xml;

abstract XmlElement(XmlNode) from XmlNode to XmlNode {
    public inline function new(name:String) this = XmlNode.createElement(name);

    public var Name(get, never):String;
    inline function get_Name():String return this.name;
    public var Value(get, set):String;
    inline function get_Value():String return this.value;
    inline function set_Value(v:String):String return this.value = v;

    public inline function SetAttribute(name:String, value:String):Void this.setAttributeValue(name, value);
    public inline function GetAttribute(name:String):String return this.getAttributeValue(name);
    public inline function HasAttribute(name:String):Bool return this.attributes.exists(name);
}
