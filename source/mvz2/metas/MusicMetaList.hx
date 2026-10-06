// Ported from: Assets/Scripts/MVZ2/Metas/MusicMetaList.cs
package mvz2.metas;

import system.xml.XmlNode;

class MusicMetaList {
    public var metas:Array<MusicMeta>;

    public function new(metas:Array<MusicMeta>) {
        this.metas = metas;
    }

    public static function FromXmlNode(node:XmlNode, defaultNsp:String):MusicMetaList {
        var resources:Array<MusicMeta> = [];
        for (i in 0...node.ChildNodes.Count) {
            var meta = MusicMeta.FromXmlNode(node.ChildNodes.getAt(i), defaultNsp);
            if (meta != null)
                resources.push(meta);
        }
        return new MusicMetaList(resources);
    }
}
