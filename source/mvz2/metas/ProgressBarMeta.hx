// Ported from: Assets/Scripts/MVZ2/Metas/ProgressBar/ProgressBarMeta.cs
package mvz2.metas;

import mvz2.io.XMLHelper;
import mvz2.ui.level.ProgressBar.ProgressBarMode;
import mvz2logic.resources.SpriteReference;
import pvzengine.Log;
import system.xml.XmlNode;
import unity.Vector2;
import unity.Vector4;
using mvz2.io.XMLHelper;  // EXTUSING

class ProgressBarMeta {
    private function new(iD:String) {
        ID = iD;
    }

    public var ID(default, null):String;
    public var Type(default, null):String = "";
    public var Size(default, null):Vector2;

    public var BackgroundSprite(default, null):SpriteReference;
    public var BarSprite(default, null):SpriteReference;
    public var ForegroundSprite(default, null):SpriteReference;
    public var FromLeft(default, null):Bool;
    public var BarMode(default, null):ProgressBarMode;

    public var Padding(default, null):Vector4;

    public var IconSprite(default, null):SpriteReference;

    public var TextOffset(default, null):Vector2;

    public static function FromXmlNode(node:XmlNode, defaultNsp:String):ProgressBarMeta {
        var id = XMLHelper.GetAttribute(node, "id");
        if (id == null || id.length == 0) {
            Log.LogError('The id of a ProgressBarMeta is invalid.');
            return null;
        }
        var type = XMLHelper.GetAttribute(node, "type");
        if (type == null) type = "";
        var widthAttr = XMLHelper.GetAttributeInt(node, "width");
        var width = widthAttr != null ? widthAttr : 0;
        var heightAttr = XMLHelper.GetAttributeInt(node, "height");
        var height = heightAttr != null ? heightAttr : 0;

        var backgroundNode = node["background"];
        var background:SpriteReference = null;
        if (backgroundNode != null) {
            background = XMLHelper.GetAttributeSpriteReference(backgroundNode, "sprite", defaultNsp);
        }

        var foregroundNode = node["foreground"];
        var foreground:SpriteReference = null;
        if (foregroundNode != null) {
            foreground = XMLHelper.GetAttributeSpriteReference(foregroundNode, "sprite", defaultNsp);
        }

        var barNode = node["bar"];
        var barSprite:SpriteReference = null;
        var fromLeft = false;
        var barMode = ProgressBarMode.Sliced;
        if (barNode != null) {
            barSprite = XMLHelper.GetAttributeSpriteReference(barNode, "sprite", defaultNsp);
            var fromLeftAttr = XMLHelper.GetAttributeBool(barNode, "fromLeft");
            if (fromLeftAttr != null) fromLeft = fromLeftAttr;
            barMode = ParseBarMode(XMLHelper.GetAttribute(barNode, "mode"));
        }

        var paddingNode = node["padding"];
        var padding = Vector4.zero;
        if (paddingNode != null) {
            var left = XMLHelper.GetAttributeFloat(paddingNode, "left");
            padding.x = left != null ? left : 0;
            var bottom = XMLHelper.GetAttributeFloat(paddingNode, "bottom");
            padding.y = bottom != null ? bottom : 0;
            var right = XMLHelper.GetAttributeFloat(paddingNode, "right");
            padding.z = right != null ? right : 0;
            var top = XMLHelper.GetAttributeFloat(paddingNode, "top");
            padding.w = top != null ? top : 0;
        }

        var iconNode = node["icon"];
        var iconSprite:SpriteReference = null;
        if (iconNode != null) {
            iconSprite = XMLHelper.GetAttributeSpriteReference(iconNode, "sprite", defaultNsp);
        }

        var textNode = node["text"];
        var textOffset = Vector2.zero;
        if (textNode != null) {
            var xOffset = XMLHelper.GetAttributeFloat(textNode, "xOffset");
            if (xOffset != null) textOffset.x = xOffset;
            var yOffset = XMLHelper.GetAttributeFloat(textNode, "yOffset");
            if (yOffset != null) textOffset.y = yOffset;
        }
        var meta = new ProgressBarMeta(id);
        meta.Type = type;
        meta.Size = new Vector2(width, height);

        meta.BackgroundSprite = background;
        meta.ForegroundSprite = foreground;

        meta.BarSprite = barSprite;
        meta.FromLeft = fromLeft;
        meta.BarMode = barMode;

        meta.Padding = padding;

        meta.IconSprite = iconSprite;

        meta.TextOffset = textOffset;
        return meta;
    }
    public static function ParseBarMode(str:String):ProgressBarMode {
        if (str == "filled")
            return ProgressBarMode.Filled;
        return ProgressBarMode.Sliced;
    }
}
