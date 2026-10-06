// Ported from: Assets/Scripts/MVZ2/Metas/Almanac/AlmanacCategory.cs
package mvz2.metas;

import system.xml.XmlNode;

class AlmanacCategory {
	public function new() { } // CTORFIX
    public var name:String = "";
    public var groups:Array<AlmanacMetaGroup>;
    public var entries:Array<AlmanacMetaEntry>;

    public static function FromXmlNode(node:XmlNode, defaultNsp:String):AlmanacCategory {
        var name = node.Name;
        var groups:Array<AlmanacMetaGroup> = [];
        var entries:Array<AlmanacMetaEntry> = [];
        var entryIndex = 0;
        for (j in 0...node.ChildNodes.Count) {
            var childNode = node.ChildNodes.getAt(j);
            switch (childNode.Name) {
                case "entry":
                    {
                        var entry = AlmanacMetaEntry.FromXmlNode(childNode, defaultNsp);
                        if (entry != null) {
                            if (!entry.hidden) {
                                entry.index = entryIndex;
                                entryIndex++;
                            }
                            entries.push(entry);
                        }
                    }
                case "group":
                    {
                        var group = AlmanacMetaGroup.FromXmlNode(childNode, defaultNsp);
                        if (group != null) {
                            groups.push(group);
                        }
                    }
                default:
            }
        }
        var category = new AlmanacCategory();
        category.name = name;
        category.groups = groups;
        category.entries = entries;
        return category;
    }
}
