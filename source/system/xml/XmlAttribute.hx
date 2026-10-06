package system.xml;

// Minimal System.Xml.XmlAttribute shim.
class XmlAttribute {
    public var name(default, null):String;
    public var value:String;
    public var ownerElement(default, null):system.xml.XmlNode;

    public function new(name:String, ?value:String, ?ownerElement:system.xml.XmlNode) {
        this.name = name;
        this.value = value != null ? value : "";
        this.ownerElement = ownerElement;
    }

    // PORT-NOTE: .NET 没有公开这个动作（`XmlAttributeCollection.Append` 内部会设置
    // XmlAttribute.OwnerElement），移植层用显式方法表达，由 XmlAttributeCollection.append 调用。
    public function bindOwner(node:system.xml.XmlNode):Void {
        ownerElement = node;
    }

    public var Name(get, never):String;
    inline function get_Name():String return name;
    public var Value(get, set):String;
    function get_Value():String return value;
    function set_Value(v:String):String {
        value = v == null ? "" : v;
        if (ownerElement != null) {
            ownerElement.setAttributeValue(name, value);
        }
        return value;
    }
    public var OwnerElement(get, never):system.xml.XmlNode;
    inline function get_OwnerElement():system.xml.XmlNode return ownerElement;

    public function toString():String return '$name="$value"';
}
