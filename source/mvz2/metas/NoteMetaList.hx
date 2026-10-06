// Ported from: Assets/Scripts/MVZ2/Metas/NoteMetaList.cs
package mvz2.metas;

import system.xml.XmlNode;

class NoteMetaList {
    public var metas:Array<NoteMeta>;

    public function new(metas:Array<NoteMeta>) {
        this.metas = metas;
    }

    public static function FromXmlNode(node:XmlNode, defaultNsp:String):NoteMetaList {
        var resources:Array<NoteMeta> = [];
        for (i in 0...node.ChildNodes.Count) {
            var meta = NoteMeta.FromXmlNode(node.ChildNodes.getAt(i), defaultNsp);
            if (meta != null) {
                resources.push(meta);
            }
        }
        return new NoteMetaList(resources);
    }
}
