// Ported from: Assets/Scripts/MVZ2/Metas/Almanac/AlmanacMetaGroup.cs
package mvz2.metas;

import mvz2.io.XMLHelper;
import pvzengine.Log;
import pvzengine.NamespaceID;
import system.xml.XmlNode;
using mvz2.io.XMLHelper;  // EXTUSING
using pvzengine.PropertyKeyHelper;  // EXTUSING

class AlmanacMetaGroup {
    public var id:NamespaceID;
    public var name:String = "";
    public var order:Int;
    public var entries:Array<AlmanacMetaEntry>;

    public function new(id:NamespaceID, entries:Array<AlmanacMetaEntry>) {
        this.id = id;
        this.entries = entries;
    }

    public static function FromXmlNode(node:XmlNode, defaultNsp:String):AlmanacMetaGroup {
        var id = XMLHelper.GetAttributeNamespaceID(node, "id", defaultNsp);
        if (!NamespaceID.IsValid(id)) {
            Log.LogError("The ID of an AlmanacMetaGroup is invalid.");
            return null;
        }
        var orderAttr = XMLHelper.GetAttributeInt(node, "order");
        var order = orderAttr != null ? orderAttr : 0;
        var name = XMLHelper.GetAttribute(node, "name");
        if (name == null) name = "";
        // PORT-NOTE: C# `new AlmanacMetaEntry[node.ChildNodes.Count]` → Array.resize 保持按下标占位。
        var entries:Array<AlmanacMetaEntry> = [];
        entries.resize(node.ChildNodes.Count);
        var entryIndex = 0;
        for (j in 0...entries.length) {
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
                            entries[j] = entry;
                        }
                    }
                default:
            }
        }
        var group = new AlmanacMetaGroup(id, entries);
        group.order = order;
        group.name = name;
        return group;
    }
}
