// Ported from: Assets/Scripts/MVZ2/Talks/Data/TalkCharacter.cs
package mvz2.talkdata;

import mvz2.io.XMLHelper;
import pvzengine.Log;
import pvzengine.NamespaceID;
import system.xml.XmlDocument;
import system.xml.XmlNode;
using mvz2.io.XMLHelper;  // EXTUSING
using pvzengine.PropertyKeyHelper;  // EXTUSING

class TalkCharacter {
    public var id:NamespaceID;
    public var variant:NamespaceID;
    public var side:String = "";

    public function new(id:NamespaceID, variant:NamespaceID, side:String) {
        this.id = id;
        this.variant = variant;
        this.side = side;
    }

    public function ToXmlNode(document:XmlDocument):XmlNode {
        var node = document.CreateElement("character");
        if (NamespaceID.IsValid(id))
            XMLHelper.CreateAttribute(node, "id", id.toString());
        if (NamespaceID.IsValid(variant))
            XMLHelper.CreateAttribute(node, "variant", variant.toString());
        XMLHelper.CreateAttribute(node, "side", side);
        return node;
    }
    public static function FromXmlNode(node:XmlNode, defaultNsp:String):TalkCharacter {
        var id = XMLHelper.GetAttributeNamespaceID(node, "id", defaultNsp);
        if (!NamespaceID.IsValid(id)) {
            Log.LogError('The id of a TalkCharacter is invalid.');
            return null;
        }
        var variant = XMLHelper.GetAttributeNamespaceID(node, "variant", defaultNsp);
        var side = XMLHelper.GetAttribute(node, "side");
        if (side == null) side = "";
        return new TalkCharacter(id, variant, side);
    }
}
