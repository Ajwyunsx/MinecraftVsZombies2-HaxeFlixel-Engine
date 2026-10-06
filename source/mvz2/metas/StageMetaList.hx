// Ported from: Assets/Scripts/MVZ2/Metas/Stage/StageMetaList.cs
package mvz2.metas;

import system.xml.XmlNode;

class StageMetaList {
    public var metas:Array<StageMeta>;

    public function new(metas:Array<StageMeta>) {
        this.metas = metas;
    }

    public static function FromXmlNode(node:XmlNode, defaultNsp:String):StageMetaList {
        var resources:Array<StageMeta> = [];
        for (i in 0...node.ChildNodes.Count) {
            var meta = StageMeta.FromXmlNode(node.ChildNodes.getAt(i), defaultNsp);
            if (meta != null)
                resources.push(meta);
        }
        return new StageMetaList(resources);
    }
}
