// Ported from: Assets/Scripts/MVZ2/Metas/Product/ProductTalkMeta.cs
package mvz2.metas;

import mvz2.io.XMLHelper;
import pvzengine.Log;
import pvzengine.NamespaceID;
import system.xml.XmlNode;
using mvz2.io.XMLHelper;  // EXTUSING
using pvzengine.PropertyKeyHelper;  // EXTUSING

class ProductTalkMeta {
    private function new(character:NamespaceID, text:String) {
        Character = character;
        Text = text;
    }

    public var Character(default, null):NamespaceID;
    public var Text(default, null):String;
    public static function FromXmlNode(node:XmlNode, defaultNsp:String):ProductTalkMeta {
        var character = XMLHelper.GetAttributeNamespaceID(node, "character", defaultNsp);
        if (!NamespaceID.IsValid(character)) {
            Log.LogError('The character of a ProductTalkMeta is invalid.');
            return null;
        }
        var text = node.InnerText;

        return new ProductTalkMeta(character, text);
    }
}
