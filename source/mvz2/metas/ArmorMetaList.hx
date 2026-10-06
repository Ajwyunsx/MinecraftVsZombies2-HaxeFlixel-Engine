// Ported from: Assets/Scripts/MVZ2/Metas/Armors/ArmorMetaList.cs
package mvz2.metas;

import system.xml.XmlNode;

class ArmorMetaList {
    public var slots:Array<ArmorSlotMeta>;
    public var metas:Array<ArmorMeta>;

    public function new(slots:Array<ArmorSlotMeta>, metas:Array<ArmorMeta>) {
        this.slots = slots;
        this.metas = metas;
    }

    public static function FromXmlNode(node:XmlNode, defaultNsp:String):ArmorMetaList {
        var slotsNode = node.GetChildNode("slots");
        var slots:Array<ArmorSlotMeta> = [];
        if (slotsNode != null) {
            for (i in 0...slotsNode.ChildNodes.Count) {
                var meta = ArmorSlotMeta.FromXmlNode(slotsNode.ChildNodes.getAt(i), defaultNsp);
                if (meta != null) {
                    slots.push(meta);
                }
            }
        }

        var entriesNode = node.GetChildNode("entries");
        var resources:Array<ArmorMeta> = [];
        if (entriesNode != null) {
            for (i in 0...entriesNode.ChildNodes.Count) {
                var meta = ArmorMeta.FromXmlNode(entriesNode.ChildNodes.getAt(i), defaultNsp);
                if (meta != null) {
                    resources.push(meta);
                }
            }
        }
        return new ArmorMetaList(slots, resources);
    }
}
