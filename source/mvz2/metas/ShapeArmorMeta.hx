// Ported from: Assets/Scripts/MVZ2/Metas/Shapes/ShapeMeta.cs
package mvz2.metas;

import mvz2.io.XMLHelper;
import mvz2logic.Global;
import mvz2logic.armors.LogicArmorProps;
import mvz2logic.blueprints.IShapeDefinitionArmor;
import pvzengine.NamespaceID;
import system.xml.XmlNode;
import unity.Vector3;
using mvz2logic.armors.LogicArmorProps;  // EXTUSING
using pvzengine.ContentProviderHelper;  // EXTUSING
using pvzengine.PropertyKeyHelper;  // EXTUSING

class ShapeArmorMeta implements IShapeDefinitionArmor {
    public function new(slots:Array<ShapeArmorMetaItem>) {
        Items = slots;
    }

    public var Items(default, null):Array<ShapeArmorMetaItem>;

    public function GetArmorPosition(slotID:NamespaceID, armorID:NamespaceID):Vector3 {
        var item = GetItem(armorID, slotID);
        if (item == null)
            return Vector3.zero;
        return item.Position;
    }
    public function GetArmorScale(slotID:NamespaceID, armorID:NamespaceID):Vector3 {
        var item = GetItem(armorID, slotID);
        if (item == null)
            return Vector3.one;
        return item.Scale;
    }
    private function GetItem(armorID:NamespaceID, slot:NamespaceID):ShapeArmorMetaItem {
        if (Items == null)
            return null;
        var armorDefinition = Global.Game.GetArmorDefinition(armorID);
        var type = armorDefinition != null ? LogicArmorProps.GetArmorType(armorDefinition) : null;

        var typeAndSlotItem:ShapeArmorMetaItem = null;
        var typeItem:ShapeArmorMetaItem = null;
        var slotItem:ShapeArmorMetaItem = null;
        for (item in Items) {
            if (item.ArmorID == armorID) {
                return item;
            }
            if (NamespaceID.IsValid(item.ArmorSlot)) {
                if (NamespaceID.IsValid(item.ArmorType)) {
                    if (item.ArmorSlot == slot && item.ArmorType == type) {
                        typeAndSlotItem = item;
                    }
                } else {
                    if (item.ArmorSlot == slot) {
                        slotItem = item;
                    }
                }
            } else {
                if (NamespaceID.IsValid(item.ArmorType)) {
                    if (item.ArmorType == type) {
                        typeItem = item;
                    }
                }
            }
        }
        // PORT-NOTE: C# `a ?? b ?? c` → 显式判空。
        if (typeAndSlotItem != null) return typeAndSlotItem;
        if (slotItem != null) return slotItem;
        return typeItem;
    }
    public static function FromXmlNode(node:XmlNode, defaultNsp:String):ShapeArmorMeta {
        var items:Array<ShapeArmorMetaItem> = [];
        for (i in 0...node.ChildNodes.Count) {
            var child = node.ChildNodes.getAt(i);
            if (child.Name == "armor") {
                var item = ShapeArmorMetaItem.FromXmlNode(child, defaultNsp);
                if (item != null)
                    items.push(item);
            }
        }
        return new ShapeArmorMeta(items);
    }
}
