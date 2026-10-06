// Ported from: Assets/Scripts/MVZ2/Metas/Blueprint/BlueprintOptionMeta.cs
package mvz2.metas;

import mvz2.io.XMLHelper;
import mvz2logic.resources.SpriteReference;
import pvzengine.Log;
import pvzengine.NamespaceID;
import system.xml.XmlNode;
using mvz2.io.XMLHelper;  // EXTUSING

class BlueprintOptionMeta {
    public function new(id:String) {
        ID = id;
    }
    public var ID(default, null):String;
    public var Cost(default, null):Int;
    public var Name(default, null):String = "";
    public var Tooltip(default, null):String = "";
    public var Icon(default, null):BlueprintMetaIcon;
    public static function FromXmlNode(nsp:String, node:XmlNode, defaultNsp:String):BlueprintOptionMeta {
        var id = XMLHelper.GetAttribute(node, "id");
        if (id == null || id.length == 0) {
            Log.LogError("The ID of a BlueprintOptionMeta is invalid.");
            return null;
        }
        var blueprintID = new NamespaceID(nsp, id);
        var costAttr = XMLHelper.GetAttributeInt(node, "cost");
        var cost = costAttr != null ? costAttr : 0;
        var name = XMLHelper.GetAttribute(node, "name");
        if (name == null) name = "";
        var tooltip = XMLHelper.GetAttribute(node, "tooltip");
        if (tooltip == null) tooltip = "";
        var icon:BlueprintMetaIcon = null;
        var iconNode = node.GetChildNode("icon");
        if (iconNode != null) {
            icon = new BlueprintMetaIcon(iconNode, defaultNsp, blueprintID);
        }
        var meta = new BlueprintOptionMeta(id);
        meta.Name = name;
        meta.Tooltip = tooltip;
        meta.Cost = cost;
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
}
