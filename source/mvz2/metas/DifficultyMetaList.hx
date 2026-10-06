// Ported from: Assets/Scripts/MVZ2/Metas/Difficulties/DifficultyMetaList.cs
package mvz2.metas;

import system.xml.XmlNode;

class DifficultyMetaList {
    public var metas:Array<DifficultyMeta>;

    public function new(metas:Array<DifficultyMeta>) {
        this.metas = metas;
    }

    public static function FromXmlNode(node:XmlNode, defaultNsp:String):DifficultyMetaList {
        var resources:Array<DifficultyMeta> = [];
        for (i in 0...node.ChildNodes.Count) {
            var meta = DifficultyMeta.FromXmlNode(node.ChildNodes.getAt(i), defaultNsp);
            if (meta != null) {
                resources.push(meta);
            }
        }
        return new DifficultyMetaList(resources);
    }
}
