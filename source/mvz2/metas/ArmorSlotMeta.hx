// Ported from: Assets/Scripts/MVZ2/Metas/Armors/ArmorSlotMeta.cs
package mvz2.metas;

import mvz2.io.XMLHelper;
import mvz2logic.resources.SpriteReference;
import system.xml.XmlNode;
import unity.Color;
using mvz2.io.XMLHelper;  // EXTUSING

class ArmorSlotMeta {
    public function new(name:String, anchor:String) {
        Name = name;
        Anchor = anchor;
    }

    public var Name(default, null):String;
    public var Anchor(default, null):String;
    public var HPBarColor(default, null):Color;
    public var HPBarIcon(default, null):SpriteReference;
    public static function FromXmlNode(node:XmlNode, defaultNsp:String):ArmorSlotMeta {
        var name = XMLHelper.GetAttribute(node, "name");
        if (name == null) name = "";
        var anchor = XMLHelper.GetAttribute(node, "anchor");
        if (anchor == null) anchor = "";
        var hpBarColor = Color.red;
        var hpBarIcon:SpriteReference = null;
        var hpBarNode = node.GetChildNode("hpBar");
        if (hpBarNode != null) {
            var colorAttr = XMLHelper.GetAttributeColor(hpBarNode, "color");
            if (colorAttr != null) hpBarColor = colorAttr;
            hpBarIcon = XMLHelper.GetAttributeSpriteReference(hpBarNode, "icon", defaultNsp);
        }
        var meta = new ArmorSlotMeta(name, anchor);
        meta.HPBarColor = hpBarColor;
        meta.HPBarIcon = hpBarIcon;
        return meta;
    }
}
