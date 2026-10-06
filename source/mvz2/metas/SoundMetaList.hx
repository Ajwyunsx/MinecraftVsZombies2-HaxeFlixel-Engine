// Ported from: Assets/Scripts/MVZ2/Metas/SoundMetaList.cs
package mvz2.metas;

import system.xml.XmlNode;

class SoundMetaList {
    public var metas:Array<SoundMeta>;

    public function new(metas:Array<SoundMeta>) {
        this.metas = metas;
    }

    public static function FromXmlNode(node:XmlNode, defaultNsp:String):SoundMetaList {
        var sounds:Array<SoundMeta> = [];
        for (i in 0...node.ChildNodes.Count) {
            var meta = SoundMeta.FromXmlNode(node.ChildNodes.getAt(i), defaultNsp);
            if (meta != null)
                sounds.push(meta);
        }
        return new SoundMetaList(sounds);
    }
}
