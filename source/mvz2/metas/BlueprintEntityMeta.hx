// Ported from: Assets/Scripts/MVZ2/Metas/Blueprint/BlueprintEntityMeta.cs
package mvz2.metas;

import mvz2.io.XMLHelper;
import mvz2logic.resources.SpriteReference;
import pvzengine.Log;
import pvzengine.NamespaceID;
import system.xml.XmlNode;
using mvz2.io.XMLHelper;  // EXTUSING
using pvzengine.PropertyKeyHelper;  // EXTUSING

class BlueprintEntityMeta {
    public function new(id:String, entityID:NamespaceID) {
        ID = id;
        EntityID = entityID;
    }

    public var ID(default, null):String;

    public var Cost(default, null):Int;
    public var RechargeID(default, null):NamespaceID;
    public var Name(default, null):String = "";
    public var Tooltip(default, null):String = "";
    public var EntityID(default, null):NamespaceID;
    public var Variant(default, null):Int;
    public var Icon(default, null):BlueprintMetaIcon;

    public static function FromXmlNode(nsp:String, node:XmlNode, defaultNsp:String):BlueprintEntityMeta {
        var id = XMLHelper.GetAttribute(node, "id");
        if (id == null || id.length == 0) {
            Log.LogError("The ID of a BlueprintEntityMeta is invalid.");
            return null;
        }
        var entityID = XMLHelper.GetAttributeNamespaceID(node, "entity", defaultNsp);
        if (!NamespaceID.IsValid(entityID)) {
            Log.LogError('The entityID of a BlueprintEntityMeta is invalid.');
            return null;
        }
        var blueprintID = new NamespaceID(nsp, id);
        var costAttr = XMLHelper.GetAttributeInt(node, "cost");
        var cost = costAttr != null ? costAttr : 0;
        var recharge = XMLHelper.GetAttributeNamespaceID(node, "recharge", defaultNsp);
        var name = XMLHelper.GetAttribute(node, "name");
        if (name == null) name = "";
        var tooltip = XMLHelper.GetAttribute(node, "tooltip");
        if (tooltip == null) tooltip = "";
        var variantAttr = XMLHelper.GetAttributeInt(node, "variant");
        var variant = variantAttr != null ? variantAttr : 0;

        var icon:BlueprintMetaIcon = null;
        var iconNode = node["icon"];
        if (iconNode != null) {
            icon = new BlueprintMetaIcon(iconNode, defaultNsp, blueprintID);
        }
        var meta = new BlueprintEntityMeta(id, entityID);
        meta.Cost = cost;
        meta.RechargeID = recharge;
        meta.Name = name;
        meta.Tooltip = tooltip;
        meta.Variant = variant;

        meta.Icon = icon;
        return meta;
    }
    public function GetIcon():SpriteReference {
        return Icon != null ? Icon.Sprite : null;
    }
    public function GetMobileIcon():SpriteReference {
        return Icon != null ? Icon.Mobile : null;
    }
    public function GetModelID():NamespaceID {
        return Icon != null ? Icon.ModelID : null;
    }

    public function IsTriggerActive():Bool return false;
    public function CanInstantTrigger():Bool return false;
    public function CanInstantEvoke():Bool return false;
    public function IsUpgradeBlueprint():Bool return false;
}
