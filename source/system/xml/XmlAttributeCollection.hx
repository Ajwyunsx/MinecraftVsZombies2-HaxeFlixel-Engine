package system.xml;

import system.xml.XmlNode.XmlNodeData;

// Minimal System.Xml.XmlAttributeCollection shim.
// PORT-NOTE: .NET 的 XmlAttributeCollection 是宿主元素的**活视图**：
//   * `Attributes.Append(attr)` 直接把属性挂到元素上，并让该 XmlAttribute 与元素同体
//     （之后 `attr.Value = x` 会写回文档）；
//   * `Attributes.Remove(name)` 直接从元素上摘掉属性。
// 原来的实现是 `abstract( Map<String, XmlAttribute> )`，每次 `node.Attributes` 都新建一份快照
// Map，于是 XMLHelper.CreateAttribute（`node.Attributes.Append(attr)`）静默失效——存档/对话写出的
// XML 会丢掉全部属性（XMLCondition / TalkGroup / TalkSentence 等 ToXmlNode 都走这里）。
// 这里改为持有宿主 XmlNodeData 的活视图，读写都直接落到 haxe 的 Xml 上。
// PORT-NOTE: 仍然是 abstract（而非 class），因为移植代码依赖 `node.Attributes[name]` 的
// @:arrayAccess 下标语法（haxe 只允许 abstract 定义 @:arrayAccess）。
// PORT-NOTE: 已知差异——.NET 的 XmlAttributeCollection 按属性插入顺序枚举，haxe 的 Xml 把属性存在
// Map<String,String> 里、解析时顺序就丢了，所以这里 Count/枚举/OuterXml 的属性顺序不保证与源文件一致。
// 移植代码只用「按名取属性」（XMLHelper.GetAttribute* / AudioSample），没有任何调用点依赖顺序。
abstract XmlAttributeCollection(XmlNodeData) from XmlNodeData to XmlNodeData {
    public inline function new(element:XmlNodeData) this = element;

    public var Count(get, never):Int;
    inline function get_Count():Int return this.attributeCount();

    // PORT-NOTE: 每次取值都从底层 xml 重新构造，缺失时返回 null
    // （C# `node.Attributes[name]` 未命中即 null）。
    @:arrayAccess public function getByName(name:String):XmlAttribute {
        var value = this.getAttributeValue(name);
        if (value == null) return null;
        return new XmlAttribute(name, value, new XmlNode(this));
    }

    public inline function exists(name:String):Bool return this.getAttributeValue(name) != null;

    public function append(attr:XmlAttribute):Void {
        if (attr == null) return;
        attr.bindOwner(new XmlNode(this));
        this.setAttributeValue(attr.name, attr.value);
    }

    public function remove(name:String):Void this.removeAttributeValue(name);

    public function names():Iterator<String> return this.attributeNames().iterator();

    public function iterator():Iterator<XmlAttribute> return toArray().iterator();

    public function toArray():Array<XmlAttribute> {
        var result:Array<XmlAttribute> = [];
        for (name in this.attributeNames()) {
            var attr = getByName(name);
            if (attr != null) result.push(attr);
        }
        return result;
    }
}
