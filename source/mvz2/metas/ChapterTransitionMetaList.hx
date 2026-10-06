// Ported from: Assets/Scripts/MVZ2/Metas/ChapterTransitions/ChapterTransitionMetaList.cs
package mvz2.metas;

import system.xml.XmlNode;

class ChapterTransitionMetaList {
    public function new(metas:Array<ChapterTransitionMeta>) {
        Metas = metas;
    }

    public var Metas(default, null):Array<ChapterTransitionMeta>;
    public static function FromXmlNode(node:XmlNode, defaultNsp:String):ChapterTransitionMetaList {
        var tags:Array<ChapterTransitionMeta> = [];
        for (i in 0...node.ChildNodes.Count) {
            var child = node.ChildNodes.getAt(i);
            if (child.Name == "transition") {
                var meta = ChapterTransitionMeta.FromXmlNode(child, defaultNsp);
                if (meta != null)
                    tags.push(meta);
            }
        }
        return new ChapterTransitionMetaList(tags);
    }
}
