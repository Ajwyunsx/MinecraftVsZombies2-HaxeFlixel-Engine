// Ported from: Assets/Scripts/MVZ2/Metas/Grids/GridMeta.cs
package mvz2.metas;

import mvz2.io.XMLHelper;
import mvz2logic.resources.SpriteReference;
import pvzengine.Log;
import pvzengine.NamespaceID;
import system.xml.XmlNode;
import unity.Color;
using mvz2.io.XMLHelper;  // EXTUSING

class GridLayerMeta {
    public function new(iD:String, almanacTag:NamespaceID) {
        ID = iD;
        AlmanacTag = almanacTag;
    }

    public var ID(default, null):String;
    public var AlmanacTag(default, null):NamespaceID;
    public var HPBarColor(default, null):Color;
    public var HPBarIcon(default, null):SpriteReference;

    public static function FromXmlNode(node:XmlNode, defaultNsp:String):GridLayerMeta {
        var id = XMLHelper.GetAttribute(node, "id");
        if (id == null || id.length == 0) {
            Log.LogError('The id of a GridLayerMeta is invalid.');
            return null;
        }
        var almanacTag:NamespaceID = null;
        var almanacNode = node["almanac"];
        if (almanacNode != null) {
            almanacTag = XMLHelper.GetAttributeNamespaceID(almanacNode, "tag", defaultNsp);
        }

        var hpBarColor = Color.white;
        var hpBarIcon:SpriteReference = null;
        var hpBarNode = node["hpbar"];
        if (hpBarNode != null) {
            var hpBarColorAttr = XMLHelper.GetAttributeColor(hpBarNode, "color");
            if (hpBarColorAttr != null) hpBarColor = hpBarColorAttr;
            hpBarIcon = XMLHelper.GetAttributeSpriteReference(hpBarNode, "icon", defaultNsp);
        }
        var meta = new GridLayerMeta(id, almanacTag);
        meta.HPBarColor = hpBarColor;
        meta.HPBarIcon = hpBarIcon;
        return meta;
    }
}
