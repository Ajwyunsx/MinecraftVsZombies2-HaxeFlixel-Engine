// Ported from: Assets/Scripts/MVZ2/Metas/TalkCharacterMeta.cs
package mvz2.metas;

import mvz2.io.XMLHelper;
import mvz2logic.resources.SpriteReference;
import system.xml.XmlNode;
using mvz2.io.XMLHelper;  // EXTUSING

class TalkCharacterLayer {
	public function new() { } // CTORFIX
    public var sprite:SpriteReference;
    public var positionX:Int;
    public var positionY:Int;

    public static function FromXmlNode(node:XmlNode, defaultNsp:String):TalkCharacterLayer {
        var layer = new TalkCharacterLayer();
        layer.sprite = XMLHelper.GetAttributeSpriteReference(node, "sprite", defaultNsp);
        var positionXAttr = XMLHelper.GetAttributeInt(node, "positionX");
        layer.positionX = positionXAttr != null ? positionXAttr : 0;
        var positionYAttr = XMLHelper.GetAttributeInt(node, "positionY");
        layer.positionY = positionYAttr != null ? positionYAttr : 0;
        return layer;
    }
}
