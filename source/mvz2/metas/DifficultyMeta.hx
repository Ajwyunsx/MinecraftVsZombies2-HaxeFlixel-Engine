// Ported from: Assets/Scripts/MVZ2/Metas/Difficulties/DifficultyMeta.cs
package mvz2.metas;

import mvz2.io.XMLHelper;
import mvz2logic.resources.SpriteReference;
import pvzengine.Log;
import pvzengine.NamespaceID;
import system.xml.XmlNode;
using mvz2.io.XMLHelper;  // EXTUSING

class DifficultyMeta {
    public var ID(default, null):String;
    public var Name(default, null):String = "";
    public var Value(default, null):Int;
    public var BuffID(default, null):NamespaceID;
    public var IZombieBuffID(default, null):NamespaceID;

    public var CartConvertMoney(default, null):Int;
    public var ClearMoney(default, null):Int;
    public var RerunClearMoney(default, null):Int;
    public var PuzzleMoney(default, null):Int;

    public var MapButtonBorderBack(default, null):SpriteReference;
    public var MapButtonBorderBottom(default, null):SpriteReference;
    public var MapButtonBorderOverlay(default, null):SpriteReference;
    public var ArcadeIcon(default, null):SpriteReference;

    public function new(id:String) {
        ID = id;
    }
    public static function FromXmlNode(node:XmlNode, defaultNsp:String):DifficultyMeta {
        var id = XMLHelper.GetAttribute(node, "id");
        if (id == null || id.length == 0) {
            Log.LogError('The id of a DifficultyMeta is invalid.');
            return null;
        }
        var name = XMLHelper.GetAttribute(node, "name");
        if (name == null) name = "";
        var valueAttr = XMLHelper.GetAttributeInt(node, "value");
        var value = valueAttr != null ? valueAttr : 0;

        var buffNode = node["buff"];
        var buffID = buffNode != null ? XMLHelper.GetAttributeNamespaceID(buffNode, "id", defaultNsp) : null;
        var IZBuffID = buffNode != null ? XMLHelper.GetAttributeNamespaceID(buffNode, "iZombie", defaultNsp) : null;

        var cartMoney = 50;
        var clearMoney = 0;
        var rerunMoney = 250;
        var puzzleMoney = 1000;
        var clearNode = node["clear"];
        if (clearNode != null) {
            var cartMoneyAttr = XMLHelper.GetAttributeInt(clearNode, "cartMoney");
            cartMoney = cartMoneyAttr != null ? cartMoneyAttr : 50;
            var clearMoneyAttr = XMLHelper.GetAttributeInt(clearNode, "clearMoney");
            clearMoney = clearMoneyAttr != null ? clearMoneyAttr : 0;
            var rerunMoneyAttr = XMLHelper.GetAttributeInt(clearNode, "rerunMoney");
            rerunMoney = rerunMoneyAttr != null ? rerunMoneyAttr : 250;
            var puzzleMoneyAttr = XMLHelper.GetAttributeInt(clearNode, "puzzleMoney");
            puzzleMoney = puzzleMoneyAttr != null ? puzzleMoneyAttr : 1000;
        }

        var backSprite:SpriteReference = null;
        var bottomSprite:SpriteReference = null;
        var overlaySprite:SpriteReference = null;
        var buttonNode = node["button"];
        if (buttonNode != null) {
            backSprite = XMLHelper.GetAttributeSpriteReference(buttonNode, "back", defaultNsp);
            bottomSprite = XMLHelper.GetAttributeSpriteReference(buttonNode, "bottom", defaultNsp);
            overlaySprite = XMLHelper.GetAttributeSpriteReference(buttonNode, "overlay", defaultNsp);
        }

        var arcadeIcon:SpriteReference = null;
        var iconNode = node["icon"];
        if (iconNode != null) {
            arcadeIcon = XMLHelper.GetAttributeSpriteReference(iconNode, "arcade", defaultNsp);
        }

        var meta = new DifficultyMeta(id);
        meta.Name = name;
        meta.Value = value;
        meta.BuffID = buffID;
        meta.IZombieBuffID = IZBuffID;

        meta.CartConvertMoney = cartMoney;
        meta.ClearMoney = clearMoney;
        meta.RerunClearMoney = rerunMoney;
        meta.PuzzleMoney = puzzleMoney;

        meta.MapButtonBorderBack = backSprite;
        meta.MapButtonBorderBottom = bottomSprite;
        meta.MapButtonBorderOverlay = overlaySprite;
        meta.ArcadeIcon = arcadeIcon;
        return meta;
    }
}
