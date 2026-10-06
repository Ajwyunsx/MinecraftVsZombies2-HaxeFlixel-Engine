// Ported from: Assets/Scripts/MVZ2/Metas/Spawns/SpawnMetaList.cs
package mvz2.metas;

import system.xml.XmlNode;

class SpawnMetaList {
    public var Metas:Array<SpawnMeta>;

    public function new(metas:Array<SpawnMeta>) {
        Metas = metas;
    }

    public static function FromXmlNode(node:XmlNode, defaultNsp:String):SpawnMetaList {
        var metas:Array<SpawnMeta> = [];
        for (i in 0...node.ChildNodes.Count) {
            var meta = SpawnMeta.FromXmlNode(node.ChildNodes.getAt(i), defaultNsp);
            if (meta != null)
                metas.push(meta);
        }
        return new SpawnMetaList(metas);
    }
}
