package system.xml;

import Xml.XmlType;
import system.xml.XmlAttribute;
import system.xml.XmlAttributeCollection;
import system.xml.XmlNodeList;
import system.xml.XmlNodeType;

// Minimal System.Xml.XmlNode shim (abstract over XmlNodeData so that C#'s indexer
// `node["childName"]` keeps working through @:arrayAccess; haxe's Xml API is used underneath).
abstract XmlNode(XmlNodeData) from XmlNodeData to XmlNodeData {
    public inline function new(data:XmlNodeData) this = data;

    @:arrayAccess public inline function getChildByName(name:String):XmlNode return this.getChildByName(name);

    public var name(get, set):String;
    inline function get_name():String return this.getName();
    inline function set_name(v:String):String { this.setName(v); return v; }

    public var innerText(get, set):String;
    inline function get_innerText():String return this.getInnerText();
    inline function set_innerText(v:String):String { this.setInnerText(v); return v; }

    public var innerXml(get, set):String;
    inline function get_innerXml():String return this.getInnerXml();
    inline function set_innerXml(v:String):String { this.setInnerXml(v); return v; }

    public var outerXml(get, never):String;
    inline function get_outerXml():String return this.getOuterXml();

    public var value(get, set):String;
    inline function get_value():String return this.getValue();
    inline function set_value(v:String):String { this.setValue(v); return v; }

    public var childNodes(get, never):XmlNodeList;
    inline function get_childNodes():XmlNodeList return this.getChildNodes();

    public var attributes(get, never):XmlAttributeCollection;
    inline function get_attributes():XmlAttributeCollection return this.getAttributes();

    public var parentNode(get, never):XmlNode;
    inline function get_parentNode():XmlNode return this.getParentNode();

    public var ownerDocument(get, never):XmlDocument;
    inline function get_ownerDocument():XmlDocument return new XmlDocument(this.ownerDocument);

    public var nodeType(get, never):XmlNodeType;
    inline function get_nodeType():XmlNodeType return this.getNodeType();

    public var firstChild(get, never):XmlNode;
    inline function get_firstChild():XmlNode return this.getFirstChild();

    public var lastChild(get, never):XmlNode;
    inline function get_lastChild():XmlNode return this.getLastChild();

    public function appendChild(child:XmlNode):XmlNode return this.appendChild(child);
    public function removeChild(child:XmlNode):XmlNode return this.removeChild(child);
    public function insertBefore(newChild:XmlNode, refChild:XmlNode):XmlNode return this.insertBefore(newChild, refChild);
    public function hasChildNodes():Bool return this.hasChildNodes();

    public function selectSingleNode(path:String):XmlNode return this.selectSingleNode(path);
    public function selectNodes(path:String):XmlNodeList return this.selectNodes(path);
    public function getAttributeValue(name:String):String return this.getAttributeValue(name);
    public function setAttributeValue(name:String, value:String):Void this.setAttributeValue(name, value);

    public function toString():String return this.getOuterXml();

    // PORT-NOTE: 移植代码大量直接沿用 C# 的属性/方法名（XmlNodeList 已经提供 Count/getAt，
    // XmlAttribute 提供 Name/Value，XmlElement 提供 Name/Value），这里补齐 XmlNode 上对应的
    // PascalCase 别名，使两套写法都能编译。行为与 camelCase 版本完全一致。
    public var Name(get, never):String;
    inline function get_Name():String return this.getName();
    public var Value(get, set):String;
    inline function get_Value():String return this.getValue();
    inline function set_Value(v:String):String { this.setValue(v); return v; }
    public var InnerText(get, set):String;
    inline function get_InnerText():String return this.getInnerText();
    inline function set_InnerText(v:String):String { this.setInnerText(v); return v; }
    public var InnerXml(get, set):String;
    inline function get_InnerXml():String return this.getInnerXml();
    inline function set_InnerXml(v:String):String { this.setInnerXml(v); return v; }
    public var OuterXml(get, never):String;
    inline function get_OuterXml():String return this.getOuterXml();
    public var ChildNodes(get, never):XmlNodeList;
    inline function get_ChildNodes():XmlNodeList return this.getChildNodes();
    public var Attributes(get, never):XmlAttributeCollection;
    inline function get_Attributes():XmlAttributeCollection return this.getAttributes();
    public var ParentNode(get, never):XmlNode;
    inline function get_ParentNode():XmlNode return this.getParentNode();
    public var OwnerDocument(get, never):XmlDocument;
    inline function get_OwnerDocument():XmlDocument return new XmlDocument(this.ownerDocument);
    public var NodeType(get, never):XmlNodeType;
    inline function get_NodeType():XmlNodeType return this.getNodeType();
    public var FirstChild(get, never):XmlNode;
    inline function get_FirstChild():XmlNode return this.getFirstChild();
    public var LastChild(get, never):XmlNode;
    inline function get_LastChild():XmlNode return this.getLastChild();
    public inline function GetChildNode(name:String):XmlNode return this.getChildByName(name);
    public function AppendChild(child:XmlNode):XmlNode return this.appendChild(child);
    public function RemoveChild(child:XmlNode):XmlNode return this.removeChild(child);
    public function InsertBefore(newChild:XmlNode, refChild:XmlNode):XmlNode return this.insertBefore(newChild, refChild);
    public function HasChildNodes():Bool return this.hasChildNodes();

    // PORT-NOTE: static factories so that the System.Xml subtype wrappers can be constructed.
    public static function createElement(name:String):XmlNode {
        return new XmlNodeData(Xml.createElement(name));
    }
    public static function createText(text:String):XmlNode {
        return new XmlNodeData(Xml.createPCData(text));
    }
    public static function createCData(text:String):XmlNode {
        return new XmlNodeData(Xml.createCData(text));
    }
    public static function createComment(text:String):XmlNode {
        return new XmlNodeData(Xml.createComment(text));
    }
}

// Backing implementation of XmlNode, delegating to haxe's Xml.
class XmlNodeData {
    public var xml:Xml;
    public var ownerDocument:XmlNodeData;

    public function new(?xml:Xml, ?ownerDocument:XmlNodeData) {
        this.xml = xml != null ? xml : Xml.createElement("");
        this.ownerDocument = ownerDocument != null ? ownerDocument : this;
    }

    // PORT-NOTE: haxe 的 Xml.nodeName 对非 Element 节点会抛
    // `Bad node type, expected Element but found PCData`（工作包 A 的崩溃点就是这里的 PCData），
    // 因此按 .NET XmlNode.Name 的语义返回常量名：
    // Element→标签名、Text→"#text"、CDATA→"#cdata-section"、Comment→"#comment"、
    // Document→"#document"、ProcessingInstruction→目标名、DocumentType→类型名。
    public function getName():String {
        return switch (xml.nodeType) {
            case Document: "#document";
            case Element: xml.nodeName;
            case PCData: "#text";
            case CData: "#cdata-section";
            case Comment: "#comment";
            case DocType: xml.nodeValue;
            case ProcessingInstruction: getProcessingInstructionTarget(xml.nodeValue);
        }
    }
    static function getProcessingInstructionTarget(value:String):String {
        if (value == null) return "";
        var trimmed = StringTools.ltrim(value);
        for (i in 0...trimmed.length) {
            switch (trimmed.charCodeAt(i)) {
                case 0x20, 0x09, 0x0D, 0x0A: return trimmed.substr(0, i);
                default:
            }
        }
        return trimmed;
    }
    public function setName(v:String):Void {
        // PORT-NOTE: haxe 的 Xml.nodeName setter 只接受 Element，其它节点类型会抛异常，
        // 而 .NET 里 XmlNode.Name 对非元素节点同样不可写；元素走 setter，
        // 其余类型沿用「直接写字段」的旧行为（移植代码不依赖改名，仅为保持 shim 不抛）。
        if (xml.nodeType == XmlType.Element) {
            xml.nodeName = v == null ? "" : v;
        } else {
            Reflect.setField(xml, "nodeName", v == null ? "" : v);
        }
    }

    public function getValue():String {
        return switch (xml.nodeType) {
            case Element, Document, DocType: "";
            case _: xml.nodeValue;
        }
    }
    public function setValue(v:String):Void {
        if (v == null) v = "";
        switch (xml.nodeType) {
            case Element:
                setInnerText(v);
            case _:
                Reflect.setField(xml, "nodeValue", v);
        }
    }

    public function getNodeType():XmlNodeType {
        return switch (xml.nodeType) {
            case XmlType.Document: XmlNodeType.Document;
            case XmlType.Element: XmlNodeType.Element;
            case XmlType.PCData: XmlNodeType.Text;
            case XmlType.CData: XmlNodeType.CDATA;
            case XmlType.Comment: XmlNodeType.Comment;
            case XmlType.DocType: XmlNodeType.DocumentType;
            case XmlType.ProcessingInstruction: XmlNodeType.ProcessingInstruction;
        }
    }

    public function getChildByName(name:String):XmlNode {
        for (child in xml.elements()) {
            if (child.nodeName == name) return new XmlNode(new XmlNodeData(child, ownerDocument));
        }
        return null;
    }

    public function getChildNodes():XmlNodeList {
        var result:Array<XmlNode> = [];
        for (child in xml) {
            // PORT-NOTE: .NET 的 DOM 中不存在「纯空白」文本节点（XmlDocument 默认
            // PreserveWhitespace=false，见 normalizeDocument），运行期手工插入的空白文本节点
            // 同样不返回，保证按索引遍历 ChildNodes 的移植代码（AchievementMetaList、
            // XMLHelper.ToPropertyDictionary 等）与 C# 一致。
            if (isWhitespaceTextNode(child)) continue;
            result.push(new XmlNode(new XmlNodeData(child, ownerDocument)));
        }
        return new XmlNodeList(result);
    }
    static function isWhitespaceTextNode(node:Xml):Bool {
        return node.nodeType == XmlType.PCData && isXmlWhitespace(node.nodeValue);
    }
    static function isXmlWhitespace(value:String):Bool {
        if (value == null) return true;
        for (i in 0...value.length) {
            switch (value.charCodeAt(i)) {
                case 0x20, 0x09, 0x0D, 0x0A: // XML 规范里的空白字符
                default: return false;
            }
        }
        return true;
    }

    // PORT-NOTE: .NET 的 XmlDocument 默认 PreserveWhitespace=false，且 XmlReader 在
    // IgnoreComments/IgnoreProcessingInstructions 为 true 时不返回对应节点 —— 也就是说
    // LoadXml/Load 结束后这些节点根本不在 DOM 里。haxe 的 Xml.parse 会把格式化换行/缩进
    // 保留成 PCData、把注释保留成 Comment，所以解析后必须按 .NET 语义规范化整棵树：
    // 这是「空白 PCData 混进 ChildNodes」的根因修复（工作包 A）。
    public static function normalizeDocument(root:Xml, ignoreComments:Bool = false,
            ignoreProcessingInstructions:Bool = false):Void {
        normalizeChildren(root, ignoreComments, ignoreProcessingInstructions, false);
    }
    static function normalizeChildren(node:Xml, ignoreComments:Bool, ignoreProcessingInstructions:Bool,
            preserveSpace:Bool):Void {
        var remove:Array<Xml> = [];
        for (child in node) {
            switch (child.nodeType) {
                case Comment:
                    if (ignoreComments) remove.push(child);
                case ProcessingInstruction:
                    if (ignoreProcessingInstructions) remove.push(child);
                case PCData:
                    // xml:space="preserve" 作用域内的空白是 SignificantWhitespace，.NET 会保留。
                    if (!preserveSpace && isXmlWhitespace(child.nodeValue)) remove.push(child);
                case Element:
                    var childPreserve = preserveSpace;
                    if (child.exists("xml:space")) childPreserve = child.get("xml:space") == "preserve";
                    normalizeChildren(child, ignoreComments, ignoreProcessingInstructions, childPreserve);
                case _:
            }
        }
        for (child in remove) node.removeChild(child);
    }

    public function getAttributes():XmlAttributeCollection {
        return new XmlAttributeCollection(this);
    }
    public function attributeCount():Int {
        if (xml.nodeType != XmlType.Element) return 0;
        var count = 0;
        for (name in xml.attributes()) count++;
        return count;
    }
    public function attributeNames():Array<String> {
        if (xml.nodeType != XmlType.Element) return [];
        return [for (name in xml.attributes()) name];
    }

    public function getAttributeValue(name:String):String {
        if (xml.nodeType != XmlType.Element) return null;
        return xml.get(name);
    }
    public function setAttributeValue(name:String, value:String):Void {
        if (xml.nodeType != XmlType.Element) return;
        xml.set(name, value == null ? "" : value);
    }
    public function removeAttributeValue(name:String):Void {
        if (xml.nodeType != XmlType.Element) return;
        xml.remove(name);
    }

    public function getParentNode():XmlNode {
        var p = xml.parent;
        if (p == null) return null;
        return new XmlNode(new XmlNodeData(p, ownerDocument));
    }

    // PORT-NOTE: FirstChild/LastChild/HasChildNodes 与 ChildNodes 使用同一套过滤规则
    // （跳过纯空白文本节点），三者保持一致。
    public function getFirstChild():XmlNode {
        for (child in xml) {
            if (isWhitespaceTextNode(child)) continue;
            return new XmlNode(new XmlNodeData(child, ownerDocument));
        }
        return null;
    }
    public function getLastChild():XmlNode {
        var last:Xml = null;
        for (child in xml) {
            if (isWhitespaceTextNode(child)) continue;
            last = child;
        }
        return last == null ? null : new XmlNode(new XmlNodeData(last, ownerDocument));
    }
    public function hasChildNodes():Bool return getFirstChild() != null;

    public function getInnerText():String {
        var sb = new StringBuf();
        collectText(xml, sb);
        return sb.toString();
    }
    function collectText(node:Xml, sb:StringBuf):Void {
        for (child in node) {
            switch (child.nodeType) {
                case PCData, CData:
                    sb.add(child.nodeValue);
                case Element:
                    collectText(child, sb);
                case _:
            }
        }
    }
    public function setInnerText(text:String):Void {
        var children:Array<Xml> = [for (c in xml) c];
        for (c in children) xml.removeChild(c);
        if (text != null && text.length > 0) {
            xml.addChild(Xml.createPCData(text));
        }
    }

    public function getInnerXml():String {
        var sb = new StringBuf();
        for (child in xml) {
            sb.add(child.toString());
        }
        return sb.toString();
    }
    public function setInnerXml(markup:String):Void {
        // PORT-NOTE: 与文档级加载不同，这里不调用 normalizeDocument —— 移植代码（含 C# 原版）
        // 从不设置 InnerXml，保持「原样灌入」的简单语义即可。
        var children:Array<Xml> = [for (c in xml) c];
        for (c in children) xml.removeChild(c);
        if (markup == null || markup.length == 0) return;
        var wrapped = Xml.parse('<root>$markup</root>');
        var toAdd:Array<Xml> = [];
        for (child in wrapped.firstElement()) toAdd.push(child);
        for (child in toAdd) {
            child.parent.removeChild(child);
            xml.addChild(child);
        }
    }
    public function getOuterXml():String return xml.toString();

    public function appendChild(child:XmlNode):XmlNode {
        var data:XmlNodeData = cast child;
        if (data != null) {
            if (data.xml.parent != null) data.xml.parent.removeChild(data.xml);
            xml.addChild(data.xml);
            data.ownerDocument = ownerDocument;
        }
        return child;
    }
    public function removeChild(child:XmlNode):XmlNode {
        var data:XmlNodeData = cast child;
        if (data != null && data.xml.parent != null) data.xml.parent.removeChild(data.xml);
        return child;
    }
    public function insertBefore(newChild:XmlNode, refChild:XmlNode):XmlNode {
        var data:XmlNodeData = cast newChild;
        var ref:XmlNodeData = cast refChild;
        if (data == null) return newChild;
        if (data.xml.parent != null) data.xml.parent.removeChild(data.xml);
        if (ref == null) {
            xml.addChild(data.xml);
            return newChild;
        }
        var index = 0;
        var found = false;
        for (child in xml) {
            if (child == ref.xml) { found = true; break; }
            index++;
        }
        xml.insertChild(data.xml, found ? index : 0);
        return newChild;
    }

    // PORT-NOTE: only a small XPath subset is implemented: slash-separated element names,
    // an optional [n] index, and the '//' descendant axis.
    public function selectSingleNode(path:String):XmlNode {
        var list = selectNodes(path);
        return list.length > 0 ? list[0] : null;
    }
    public function selectNodes(path:String):XmlNodeList {
        var result:Array<XmlNode> = [];
        var descendant = false;
        var current:Array<Xml> = [xml];
        for (segment in path.split("/")) {
            if (segment.length == 0) {
                descendant = true;
                continue;
            }
            var namePart = segment;
            var index = -1;
            var bracket = segment.indexOf("[");
            if (bracket >= 0) {
                namePart = segment.substr(0, bracket);
                var inside = segment.substring(bracket + 1, segment.length - 1);
                var parsed = Std.parseInt(inside);
                if (parsed != null) index = parsed;
            }
            var next:Array<Xml> = [];
            for (node in current) {
                var candidates:Array<Xml> = [];
                if (descendant) {
                    collectDescendants(node, namePart, candidates);
                } else {
                    for (child in node.elements()) {
                        if (namePart == "*" || child.nodeName == namePart) candidates.push(child);
                    }
                }
                if (index > 0) {
                    if (index - 1 < candidates.length) next.push(candidates[index - 1]);
                } else {
                    next = next.concat(candidates);
                }
            }
            current = next;
            descendant = false;
        }
        for (node in current) {
            result.push(new XmlNode(new XmlNodeData(node, ownerDocument)));
        }
        return new XmlNodeList(result);
    }
    function collectDescendants(node:Xml, name:String, out:Array<Xml>):Void {
        for (child in node.elements()) {
            if (name == "*" || child.nodeName == name) out.push(child);
            collectDescendants(child, name, out);
        }
    }
}
