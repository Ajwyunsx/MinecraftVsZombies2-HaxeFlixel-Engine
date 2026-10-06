// Ported from: Assets/Scripts/MVZ2/Metas/Arcade/ArcadeMetaList.cs
package mvz2.metas;

import system.xml.XmlNode;

class ArcadeMetaList {
    public var metas:Array<ArcadeMeta>;

    public function new(metas:Array<ArcadeMeta>) {
        this.metas = metas;
    }

    public static function FromXmlNode(node:XmlNode, defaultNsp:String):ArcadeMetaList {
        var resources:Array<ArcadeMeta> = [];
        resources.resize(node.ChildNodes.Count);
        // PORT-NOTE: C# 使用 ConcurrentDictionary<string,int> 统计同名节点的出现序数。
        var indexes:Map<String, Int> = new Map();
        for (i in 0...resources.length) {
            var childNode = node.ChildNodes.getAt(i);
            var key = childNode.Name;
            var index = indexes.exists(key) ? indexes.get(key) : 0;
            indexes.set(key, index + 1);
            var meta = ArcadeMeta.FromXmlNode(childNode, defaultNsp, index);
            if (meta != null) {
                resources[i] = meta;
            }
        }
        return new ArcadeMetaList(resources);
    }
}
