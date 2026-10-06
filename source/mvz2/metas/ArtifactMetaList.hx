// Ported from: Assets/Scripts/MVZ2/Metas/ArtifactMetaList.cs
package mvz2.metas;

import system.xml.XmlNode;

class ArtifactMetaList {
    public var metas:Array<ArtifactMeta>;

    public function new(metas:Array<ArtifactMeta>) {
        this.metas = metas;
    }

    public static function FromXmlNode(node:XmlNode, defaultNsp:String):ArtifactMetaList {
        var metas:Array<ArtifactMeta> = [];
        metas.resize(node.ChildNodes.Count);
        for (i in 0...metas.length) {
            var meta = ArtifactMeta.FromXmlNode(node.ChildNodes.getAt(i), defaultNsp, i);
            if (meta != null) {
                metas[i] = meta;
            }
        }
        return new ArtifactMetaList(metas);
    }
}
