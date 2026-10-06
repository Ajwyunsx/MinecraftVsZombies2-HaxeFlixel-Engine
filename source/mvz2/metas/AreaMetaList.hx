// Ported from: Assets/Scripts/MVZ2/Metas/AreaMetaList.cs
package mvz2.metas;

import system.xml.XmlNode;

class AreaMetaList {
    public var metas:Array<AreaMeta>;

    public function new(metas:Array<AreaMeta>) {
        this.metas = metas;
    }

    public static function FromXmlNode(node:XmlNode, defaultNsp:String):AreaMetaList {
        // PORT-NOTE: C# 的 AreaMeta[] 允许 null 元素，Haxe 用 resize 预分配同长度数组。
        var resources:Array<AreaMeta> = [];
        resources.resize(node.ChildNodes.Count);
        for (i in 0...resources.length) {
            var meta = AreaMeta.FromXmlNode(node.ChildNodes.getAt(i), defaultNsp);
            if (meta != null) {
                resources[i] = meta;
            }
        }
        return new AreaMetaList(resources);
    }
}
