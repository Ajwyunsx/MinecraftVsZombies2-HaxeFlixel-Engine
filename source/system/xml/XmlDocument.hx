package system.xml;

import Xml.XmlType;
import system.xml.XmlAttribute;
import system.xml.XmlNode;
import system.xml.XmlNode.XmlNodeData;
import system.xml.XmlReader;

// Minimal System.Xml.XmlDocument shim.
// PORT-NOTE: .NET 的 XmlDocument 默认 PreserveWhitespace=false（Load/LoadXml 会把纯空白文本节点
// 丢弃），本 shim 没有暴露 PreserveWhitespace 属性——移植代码里没有任何调用点设置它，
// 因此固定按 .NET 默认行为处理（见 XmlNode.normalizeDocument）。
abstract XmlDocument(XmlNodeData) from XmlNodeData to XmlNodeData {
    public inline function new(data:XmlNodeData) this = data;

    public static function create():XmlDocument {
        var doc = new XmlNodeData(Xml.createDocument());
        return new XmlDocument(doc);
    }
    // PORT-NOTE: 本方法不是 .NET API，语义等价于 `new XmlDocument(); document.LoadXml(content);`
    // ——默认 IgnoreComments=false（保留注释）、PreserveWhitespace=false（丢弃纯空白文本节点）。
    public static function parse(content:String):XmlDocument {
        var parsed = Xml.parse(content);
        XmlNodeData.normalizeDocument(parsed);
        var doc = new XmlNodeData(parsed);
        return new XmlDocument(doc);
    }

    public var documentElement(get, never):XmlNode;
    function get_documentElement():XmlNode {
        if (this.xml.nodeType == XmlType.Document) {
            var root = this.xml.firstElement();
            return root == null ? null : new XmlNode(new XmlNodeData(root, this));
        }
        return new XmlNode(this);
    }

    @:arrayAccess public inline function getChildByName(name:String):XmlNode return this.getChildByName(name);

    public var childNodes(get, never):XmlNodeList;
    inline function get_childNodes():XmlNodeList return this.getChildNodes();

    public var outerXml(get, never):String;
    inline function get_outerXml():String return this.getOuterXml();

    public function createElement(name:String):XmlNode {
        return new XmlNode(new XmlNodeData(Xml.createElement(name), this));
    }
    public function createTextNode(text:String):XmlNode {
        return new XmlNode(new XmlNodeData(Xml.createPCData(text), this));
    }
    public function createCDataSection(text:String):XmlNode {
        return new XmlNode(new XmlNodeData(Xml.createCData(text), this));
    }
    public function createComment(text:String):XmlNode {
        return new XmlNode(new XmlNodeData(Xml.createComment(text), this));
    }
    public function createAttribute(name:String):XmlAttribute {
        return new XmlAttribute(name, "", null);
    }
    public function createDocumentFragment():XmlNode {
        return new XmlNode(new XmlNodeData(Xml.createDocument(), this));
    }

    // PORT-NOTE: .NET 的 XmlDocument.Load(reader) 用读取器返回的节点建树；XmlReaderSettings 的
    // ignoreComments / ignoreProcessingInstructions 决定注释与处理指令是否进 DOM，
    // 而 PreserveWhitespace=false（XmlDocument 默认）决定纯空白文本节点是否进 DOM。
    // haxe 的 Xml.parse 不做这些取舍，所以这里按设置规范化整棵树。
    public function load(reader:XmlReader):Void {
        var parsed = Xml.parse(reader.readToEnd());
        var settings = reader.settings;
        XmlNodeData.normalizeDocument(parsed, settings != null && settings.ignoreComments,
            settings != null && settings.ignoreProcessingInstructions);
        this.xml = parsed;
    }
    public function loadXml(content:String):Void {
        var parsed = Xml.parse(content);
        XmlNodeData.normalizeDocument(parsed);
        this.xml = parsed;
    }
    public function save(writer:system.io.StreamWriter):Void {
        writer.Write(this.getOuterXml());
    }
    public function appendChild(child:XmlNode):XmlNode return this.appendChild(child);
    public function removeChild(child:XmlNode):XmlNode return this.removeChild(child);

    public function toString():String return this.getOuterXml();

    // PORT-NOTE: 同 XmlNode，补齐 PascalCase 别名，兼容直接照抄 C# 的移植代码。
    // PORT-NOTE: abstract 内部 `this` 的类型是底层类型（XmlNodeData），
    // 调用本 abstract 自己定义的方法/属性必须直接写方法名（Haxe abstract 语义）。
    public var DocumentElement(get, never):XmlNode;
    inline function get_DocumentElement():XmlNode return get_documentElement();
    public var ChildNodes(get, never):XmlNodeList;
    inline function get_ChildNodes():XmlNodeList return get_childNodes();
    public var OuterXml(get, never):String;
    inline function get_OuterXml():String return this.getOuterXml();
    public inline function GetChildNode(name:String):XmlNode return this.getChildByName(name);
    public inline function CreateElement(name:String):XmlNode return createElement(name);
    public inline function CreateTextNode(text:String):XmlNode return createTextNode(text);
    public inline function CreateCDataSection(text:String):XmlNode return createCDataSection(text);
    public inline function CreateComment(text:String):XmlNode return createComment(text);
    public inline function CreateAttribute(name:String):XmlAttribute return createAttribute(name);
    public inline function CreateDocumentFragment():XmlNode return createDocumentFragment();
    public inline function LoadXml(content:String):Void loadXml(content);
    public function AppendChild(child:XmlNode):XmlNode return this.appendChild(child);
    public function RemoveChild(child:XmlNode):XmlNode return this.removeChild(child);
}
