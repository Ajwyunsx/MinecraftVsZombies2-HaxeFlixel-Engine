// Ported from: Assets/Scripts/MVZ2/Metas/Model/ModelArmorConfigMeta.cs
package mvz2.metas;

import mvz2.io.XMLHelper;
import mvz2logic.Global;
import mvz2logic.armors.LogicArmorProps;
import pvzengine.Log;
import pvzengine.NamespaceID;
import system.xml.XmlNode;
import unity.Vector3;
using mvz2.io.XMLHelper;  // EXTUSING
using mvz2logic.armors.LogicArmorProps;  // EXTUSING
using pvzengine.ContentProviderHelper;  // EXTUSING
using pvzengine.PropertyKeyHelper;  // EXTUSING

class ModelArmorConfigMeta {
    public function new(id:String, items:Array<ModelArmorConfigMetaItem>) {
        ID = id;
        Items = items;
    }

    public var ID(default, null):String;
    public var Items(default, null):Array<ModelArmorConfigMetaItem>;

    public static function FromXmlNode(node:XmlNode, defaultNsp:String):ModelArmorConfigMeta {
        var id = XMLHelper.GetAttribute(node, "id");
        if (id == null || id.length == 0) {
            Log.LogError('The id of a ModelArmorConfigMeta is invalid.');
            return null;
        }

        var items:Array<ModelArmorConfigMetaItem> = [];
        for (i in 0...node.ChildNodes.Count) {
            var child = node.ChildNodes.getAt(i);
            switch (child.Name) {
                case "armor":
                    items.push(ModelArmorConfigMetaItem.FromXmlNode(child, defaultNsp));
                default:
            }
        }

        return new ModelArmorConfigMeta(id, items);
    }
    public function toString():String {
        return ID;
    }
    public function GetArmorOffset(slotID:NamespaceID, armorID:NamespaceID):Vector3 {
        var item = GetItem(armorID, slotID);
        if (item == null)
            return Vector3.zero;
        return item.Offset;
    }
    public function GetArmorAnchor(slotID:NamespaceID, armorID:NamespaceID):String {
        var item = GetItem(armorID, slotID);
        if (item == null)
            return "";
        return item.Anchor;
    }
    // PORT-NOTE: C# `IEnumerable<string>` + yield → Haxe 返回 Array<String>（PORTING.md §IEnumerable）。
    public function GetAllArmorModelAnchors():Array<String> {
        var results:Array<String> = [];
        if (Items != null) {
            for (item in Items) {
                results.push(item.Anchor);
            }
        }
        return results;
    }
    private function GetItem(armorID:NamespaceID, slot:NamespaceID):ModelArmorConfigMetaItem {
        if (Items == null)
            return null;
        var armorDefinition = Global.Game.GetArmorDefinition(armorID);
        var type = armorDefinition != null ? LogicArmorProps.GetArmorType(armorDefinition) : null;

        var typeAndSlotItem:ModelArmorConfigMetaItem = null;
        var typeItem:ModelArmorConfigMetaItem = null;
        var slotItem:ModelArmorConfigMetaItem = null;
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
    // PORT-NOTE: C# 的 static readonly 字段是首次使用时才初始化；hxcpp 会在 main() 之前执行全部静态初始化
    // （__boot_all()），那时 Global.Game / MainManager.Instance 仍为 null，直接求值会段错误。
    // 此处改为惰性 getter（结果缓存一次，等价于 C# 的 readonly static），还原 C# 语义。
    public static var DEFAULT_ID(get, never):NamespaceID;
    private static var _defaultID:NamespaceID;
    static function get_DEFAULT_ID():NamespaceID
    {
    	if (_defaultID == null) _defaultID = new NamespaceID(Global.BuiltinNamespace, "default");
    	return _defaultID;
    }
}
