// Ported from: System.Xml.XmlComment (minimal shim)
// PORT-NOTE: see XmlElement.hx — System.Xml subtypes wrap the XmlNode abstract.
package system.xml;

abstract XmlComment(XmlNode) from XmlNode to XmlNode {
    public inline function new(value:String) this = XmlNode.createComment(value);

    public var Value(get, set):String;
    inline function get_Value():String return this.value;
    inline function set_Value(v:String):String return this.value = v;
}
