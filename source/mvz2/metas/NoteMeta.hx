// Ported from: Assets/Scripts/MVZ2/Metas/NoteMeta.cs
package mvz2.metas;

import mvz2.io.XMLHelper;
import mvz2logic.resources.SpriteReference;
import pvzengine.Log;
import pvzengine.NamespaceID;
import system.xml.XmlNode;
using mvz2.io.XMLHelper;  // EXTUSING

class NoteMeta {
    public var id:String;
    public var sprite:SpriteReference;
    public var background:SpriteReference;
    public var startTalk:NamespaceID;
    public var canFlip:Bool;
    public var flipSprite:SpriteReference;

    public function new(id:String) {
        this.id = id;
    }

    public static function FromXmlNode(node:XmlNode, defaultNsp:String):NoteMeta {
        var id = XMLHelper.GetAttribute(node, "id");
        if (id == null || id.length == 0) {
            Log.LogError('The id of a NoteMeta is invalid.');
            return null;
        }
        var sprite = XMLHelper.GetAttributeSpriteReference(node, "sprite", defaultNsp);
        var background = XMLHelper.GetAttributeSpriteReference(node, "background", defaultNsp);
        var startTalk = XMLHelper.GetAttributeNamespaceID(node, "startTalk", defaultNsp);
        var canFlipAttr = XMLHelper.GetAttributeBool(node, "canFlip");
        var canFlip = canFlipAttr != null ? canFlipAttr : false;
        var flipSprite = XMLHelper.GetAttributeSpriteReference(node, "flipSprite", defaultNsp);
        var meta = new NoteMeta(id);
        meta.sprite = sprite;
        meta.background = background;
        meta.startTalk = startTalk;
        meta.canFlip = canFlip;
        meta.flipSprite = flipSprite;
        return meta;
    }
}
