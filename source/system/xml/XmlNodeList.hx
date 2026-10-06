package system.xml;

// Minimal System.Xml.XmlNodeList shim (abstract so that `list[i]` and `list.Count` keep working).
// PORT-NOTE: .NET 的 XmlNodeList 是**活视图**（文档变了它跟着变），这里是取用时生成的快照。
// 移植代码全部是「取一次 → 立刻按下标/Count 遍历」的用法，快照语义与之等价；
// 顺带提供 .NET 的 Item(index) 方法名。
abstract XmlNodeList(Array<XmlNode>) from Array<XmlNode> to Array<XmlNode> {
    public inline function new(list:Array<XmlNode>) this = list;

    public var Count(get, never):Int;
    inline function get_Count():Int return this.length;
    public var length(get, never):Int;
    inline function get_length():Int return this.length;

    @:arrayAccess public inline function getAt(index:Int):XmlNode return this[index];
    public inline function Item(index:Int):XmlNode return this[index];

    public inline function iterator():Iterator<XmlNode> return this.iterator();
    public inline function toArray():Array<XmlNode> return this;
    public inline function push(node:XmlNode):Int return this.push(node);
    public inline function remove(node:XmlNode):Bool return this.remove(node);
}
