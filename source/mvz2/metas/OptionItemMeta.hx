// Ported from: Assets/Scripts/MVZ2/Metas/Options/OptionItemMeta.cs
package mvz2.metas;

import mvz2.io.XMLHelper;
import mvz2logic.options.OptionItemType;
import pvzengine.Log;
import system.xml.XmlNode;
using mvz2.io.XMLHelper;  // EXTUSING

class OptionItemMeta {
    public var Type(default, null):OptionItemType;
    public var ID(default, null):String;
    public var DefaultValue(default, null):Dynamic;

    public function new(type:OptionItemType, iD:String) {
        Type = type;
        ID = iD;
    }
    public static function FromXmlNode(node:XmlNode, defaultNsp:String):OptionItemMeta {
        var id = XMLHelper.GetAttribute(node, "id");
        if (id == null || id.length == 0) {
            Log.LogError('The id of a OptionItemMeta is invalid.');
            return null;
        }
        var type:OptionItemType = OptionItemType.Boolean;
        if (typeDict.exists(node.Name)) {
            type = typeDict.get(node.Name);
        }

        var defaultValue:Dynamic = null;
        switch (type) {
            case OptionItemType.Boolean:
                {
                    var attr = XMLHelper.GetAttributeBool(node, "defaultValue");
                    defaultValue = attr != null ? attr : false;
                }
            case OptionItemType.Int:
                {
                    var attr = XMLHelper.GetAttributeInt(node, "defaultValue");
                    defaultValue = attr != null ? attr : 0;
                }
            case OptionItemType.Float:
                {
                    var attr = XMLHelper.GetAttributeFloat(node, "defaultValue");
                    defaultValue = attr != null ? attr : 0;
                }
            case OptionItemType.String:
                {
                    var attr = XMLHelper.GetAttribute(node, "defaultValue");
                    defaultValue = attr != null ? attr : "";
                }
            case OptionItemType.ID:
                {
                    defaultValue = XMLHelper.GetAttributeNamespaceID(node, "defaultValue", defaultNsp);
                }
            default:
        }
        var meta = new OptionItemMeta(type, id);
        meta.DefaultValue = defaultValue;
        return meta;
    }
    private static var typeDict:Map<String, OptionItemType> = [
        "bool" => OptionItemType.Boolean,
        "int" => OptionItemType.Int,
        "float" => OptionItemType.Float,
        "string" => OptionItemType.String,
        "id" => OptionItemType.ID,
    ];
}
