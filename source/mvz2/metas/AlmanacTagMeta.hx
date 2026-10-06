// Ported from: Assets/Scripts/MVZ2/Metas/Almanac/Tag/AlmanacTagMeta.cs
package mvz2.metas;

import mvz2.io.XMLHelper;
import mvz2logic.resources.SpriteReference;
import pvzengine.Log;
import pvzengine.NamespaceID;
import system.xml.XmlNode;
import unity.Color;
using mvz2.io.XMLHelper;  // EXTUSING

class AlmanacTagMeta {
    public var id:String;
    public var name:String = "";
    public var description:String = "";
    public var priority:Int;
    public var enumType:NamespaceID;

    public var iconSprite:SpriteReference;

    public var backgroundSprite:SpriteReference;
    public var backgroundColor:Color = new Color(0, 0, 0, 0); // PORT-NOTE: C# Color 为 struct，default 为 (0,0,0,0) 透明黑；显式初始化避免 abstract-over-class 的 null 解引用

    public var markSprite:SpriteReference;

    public function new(id:String) {
        this.id = id;
    }

    public static function FromXmlNode(node:XmlNode, defaultNsp:String):AlmanacTagMeta {
        var id = XMLHelper.GetAttribute(node, "id");
        if (id == null || id.length == 0) {
            Log.LogError("The ID of an AlmanacTagMeta is invalid.");
            return null;
        }
        var name = XMLHelper.GetAttribute(node, "name");
        if (name == null) name = "";
        var description = XMLHelper.GetAttribute(node, "description");
        if (description == null) description = "";
        var priorityAttr = XMLHelper.GetAttributeInt(node, "priority");
        var priority = priorityAttr != null ? priorityAttr : 0;
        var enumType = XMLHelper.GetAttributeNamespaceID(node, "enum", defaultNsp);

        var iconNode = node["icon"];
        var iconSprite:SpriteReference = null;
        if (iconNode != null) {
            iconSprite = XMLHelper.GetAttributeSpriteReference(iconNode, "sprite", defaultNsp);
        }

        var backgroundNode = node["background"];
        var backgroundSprite:SpriteReference = null;
        var backgroundColor = Color.gray;
        if (backgroundNode != null) {
            backgroundSprite = XMLHelper.GetAttributeSpriteReference(backgroundNode, "sprite", defaultNsp);
            var bgColorAttr = XMLHelper.GetAttributeColor(backgroundNode, "color");
            if (bgColorAttr != null) backgroundColor = bgColorAttr;
        }

        var markNode = node["mark"];
        var markSprite:SpriteReference = null;
        if (markNode != null) {
            markSprite = XMLHelper.GetAttributeSpriteReference(markNode, "sprite", defaultNsp);
        }

        var meta = new AlmanacTagMeta(id);
        meta.name = name;
        meta.description = description;
        meta.priority = priority;
        meta.enumType = enumType;

        meta.iconSprite = iconSprite;

        meta.backgroundSprite = backgroundSprite;
        meta.backgroundColor = backgroundColor;

        meta.markSprite = markSprite;
        return meta;
    }
}
