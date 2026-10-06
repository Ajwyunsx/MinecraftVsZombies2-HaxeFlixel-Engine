// Ported from: Assets/Scripts/MVZ2/Metas/Almanac/Tag/AlmanacTagEnumValueMeta.cs
package mvz2.metas;

import mvz2.io.XMLHelper;
import mvz2logic.resources.SpriteReference;
import system.xml.XmlNode;
import unity.Color;
using mvz2.io.XMLHelper;  // EXTUSING

class AlmanacTagEnumValueMeta {
	public function new() { } // CTORFIX
    public var name:String = "";
    public var description:String = "";

    public var iconSprite:SpriteReference;
    public var backgroundColor:Color = new Color(0, 0, 0, 0); // PORT-NOTE: C# Color 为 struct，default 为 (0,0,0,0) 透明黑；显式初始化避免 abstract-over-class 的 null 解引用

    public var value:Dynamic;
    public static function FromXmlNode(node:XmlNode, type:String, defaultNsp:String):AlmanacTagEnumValueMeta {
        var id = XMLHelper.GetAttribute(node, "id");
        var name = XMLHelper.GetAttribute(node, "name");
        if (name == null) name = "";
        var description = XMLHelper.GetAttribute(node, "description");
        if (description == null) description = "";

        var iconSprite = XMLHelper.GetAttributeSpriteReference(node, "sprite", defaultNsp);
        var bgColor = XMLHelper.GetAttributeColor(node, "backgroundColor");
        var backgroundColor = bgColor != null ? bgColor : Color.gray;

        var value:Dynamic = null;
        var structRef:{value:Dynamic} = {value: null};
        if (XMLHelper.TryGetAttributeStruct(node, "value", type, structRef)) {
            value = structRef.value;
        } else if (XMLHelper.TryGetAttributeNullable(node, "value", "null", type, defaultNsp, structRef)) {
            value = structRef.value;
        }

        var meta = new AlmanacTagEnumValueMeta();
        meta.name = name;
        meta.description = description;
        meta.iconSprite = iconSprite;
        meta.backgroundColor = backgroundColor;
        meta.value = value;
        return meta;
    }
}
