// Ported from: Assets/Scripts/MVZ2/Metas/Stats/StatMetaList.cs
package mvz2.metas;

import system.xml.XmlNode;

class StatMetaList {
    public var categories:Array<StatCategoryMeta>;
    public var entries:Array<StatEntryMeta>;

    public function new(categories:Array<StatCategoryMeta>, entries:Array<StatEntryMeta>) {
        this.categories = categories;
        this.entries = entries;
    }

    public static function FromXmlNode(node:XmlNode, defaultNsp:String):StatMetaList {
        var categories:Array<StatCategoryMeta> = [];
        var entries:Array<StatEntryMeta> = [];
        for (i in 0...node.ChildNodes.Count) {
            var childNode = node.ChildNodes.getAt(i);
            switch (childNode.Name) {
                case "category":
                    var meta = StatCategoryMeta.FromXmlNode(childNode, defaultNsp);
                    if (meta != null)
                        categories.push(meta);
                case "entry":
                    var entry = StatEntryMeta.FromXmlNode(childNode, defaultNsp);
                    if (entry != null)
                        entries.push(entry);
                default:
            }
        }
        return new StatMetaList(categories, entries);
    }
}
