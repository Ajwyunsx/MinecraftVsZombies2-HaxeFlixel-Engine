// Ported from: Assets/Scripts/MVZ2/Metas/ChapterTransitions/ChapterTransitionMeta.cs
package mvz2.metas;

import mvz2.io.XMLHelper;
import mvz2logic.resources.SpriteReference;
import system.xml.XmlNode;
import unity.Debug;
using mvz2.io.XMLHelper;  // EXTUSING

class ChapterTransitionMeta {
    public var ID(default, null):String;
    public var Angle(default, null):Float;
    public var Mode(default, null):Int;
    public var TextSprite(default, null):SpriteReference;
    private function new(id:String) {
        ID = id;
    }
    public static function FromXmlNode(node:XmlNode, defaultNsp:String):ChapterTransitionMeta {
        var id = XMLHelper.GetAttribute(node, "id");
        if (id == null || id.length == 0) {
            Debug.LogError("The ID of a ChapterTransitionMeta is invalid.");
            return null;
        }
        var angleAttr = XMLHelper.GetAttributeFloat(node, "angle");
        var angle = angleAttr != null ? angleAttr : 0;
        var modeAttr = XMLHelper.GetAttributeInt(node, "mode");
        var mode = modeAttr != null ? modeAttr : 0;
        var textSprite = XMLHelper.GetAttributeSpriteReference(node, "textSprite", defaultNsp);
        var meta = new ChapterTransitionMeta(id);
        meta.Angle = angle;
        meta.Mode = mode;
        meta.TextSprite = textSprite;
        return meta;
    }
    public static inline var MODE_ROTATE:Int = 0;
    public static inline var MODE_NO_ROTATE:Int = 1;
    public static inline var MODE_END:Int = 2;

}
