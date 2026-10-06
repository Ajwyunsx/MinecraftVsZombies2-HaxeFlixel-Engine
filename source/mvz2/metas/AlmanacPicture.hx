// Ported from: Assets/Scripts/MVZ2/Metas/Almanac/AlmanacMetaEntry.cs
package mvz2.metas;

import mvz2.io.XMLHelper;
import mvz2logic.resources.SpriteReference;
import pvzengine.NamespaceID;
import system.xml.XmlNode;
using mvz2.io.XMLHelper;  // EXTUSING

class AlmanacPicture {
	public function new() { } // CTORFIX
    public var sprite:SpriteReference;
    public var character:NamespaceID;
    public var model:NamespaceID;

    public static function FromXmlNode(node:XmlNode, defaultNsp:String):AlmanacPicture {
        var sprite = XMLHelper.GetAttributeSpriteReference(node, "sprite", defaultNsp);
        var character = XMLHelper.GetAttributeNamespaceID(node, "character", defaultNsp);
        var model = XMLHelper.GetAttributeNamespaceID(node, "model", defaultNsp);

        var picture = new AlmanacPicture();
        picture.sprite = sprite;
        picture.character = character;
        picture.model = model;
        return picture;
    }
}
