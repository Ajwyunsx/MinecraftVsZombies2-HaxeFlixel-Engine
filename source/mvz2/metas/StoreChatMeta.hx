// Ported from: Assets/Scripts/MVZ2/Metas/Store/StoreChatMeta.cs
package mvz2.metas;

import mvz2.io.XMLHelper;
import pvzengine.NamespaceID;
import system.xml.XmlNode;
using mvz2.io.XMLHelper;  // EXTUSING

class StoreChatMeta {
    public function new(sound:NamespaceID, text:String) {
        Sound = sound;
        Text = text;
    }

    public var Sound(default, null):NamespaceID;
    public var Text(default, null):String;
    public static function FromXmlNode(node:XmlNode, defaultNsp:String):StoreChatMeta {
        var sound = XMLHelper.GetAttributeNamespaceID(node, "sound", defaultNsp);
        var text = node.InnerText;
        return new StoreChatMeta(sound, text);
    }
}
