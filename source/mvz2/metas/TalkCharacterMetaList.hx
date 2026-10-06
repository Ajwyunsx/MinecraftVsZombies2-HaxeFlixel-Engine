// Ported from: Assets/Scripts/MVZ2/Metas/TalkCharacterMeta.cs
package mvz2.metas;

import system.xml.XmlNode;

class TalkCharacterMetaList {
	public function new() { } // CTORFIX
    public var metas:Array<TalkCharacterMeta> = [];

    public static function FromXmlNode(node:XmlNode, defaultNsp:String):TalkCharacterMetaList {
        var list = new TalkCharacterMetaList();
        var metaChildNodes = node.ChildNodes;
        for (i in 0...metaChildNodes.Count) {
            var child = metaChildNodes.getAt(i);
            var meta = TalkCharacterMeta.FromXmlNode(child, defaultNsp);
            if (meta != null)
                list.metas.push(meta);
        }
        return list;
    }
}
