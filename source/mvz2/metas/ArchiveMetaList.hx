// Ported from: Assets/Scripts/MVZ2/Metas/Archive/ArchiveMetaList.cs
package mvz2.metas;

import system.xml.XmlNode;

class ArchiveMetaList {
    private function new(tags:Array<ArchiveTagMeta>) {
        Tags = tags;
    }

    public var Tags(default, null):Array<ArchiveTagMeta>;
    public static function FromXmlNode(node:XmlNode, defaultNsp:String):ArchiveMetaList {
        var tagsNode = node.GetChildNode("tags");
        var tags:Array<ArchiveTagMeta> = [];
        if (tagsNode != null) {
            for (i in 0...tagsNode.ChildNodes.Count) {
                var child = tagsNode.ChildNodes.getAt(i);
                if (child.Name == "tag") {
                    var meta = ArchiveTagMeta.FromXmlNode(child, defaultNsp);
                    if (meta != null) {
                        tags.push(meta);
                    }
                }
            }
        }
        return new ArchiveMetaList(tags);
    }
}
