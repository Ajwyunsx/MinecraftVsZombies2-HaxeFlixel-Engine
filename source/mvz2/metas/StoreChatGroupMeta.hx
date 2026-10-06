// Ported from: Assets/Scripts/MVZ2/Metas/Store/StoreChatGroupMeta.cs
package mvz2.metas;

import mvz2.io.XMLHelper;
import pvzengine.Log;
import pvzengine.NamespaceID;
import system.xml.XmlNode;
using mvz2.io.XMLHelper;  // EXTUSING
using pvzengine.PropertyKeyHelper;  // EXTUSING

class StoreChatGroupMeta {
    public function new(character:NamespaceID, chats:Array<StoreChatMeta>) {
        Character = character;
        Chats = chats;
    }

    public var Character(default, null):NamespaceID;
    public var Chats(default, null):Array<StoreChatMeta>;
    public static function FromXmlNode(node:XmlNode, defaultNsp:String):StoreChatGroupMeta {
        var character = XMLHelper.GetAttributeNamespaceID(node, "character", defaultNsp);
        if (!NamespaceID.IsValid(character)) {
            Log.LogError('The character of a StoreChatGroupMeta is invalid.');
            return null;
        }

        var chats:Array<StoreChatMeta> = [];
        for (i in 0...node.ChildNodes.Count) {
            var childNode = node.ChildNodes.getAt(i);
            if (childNode.Name == "chat") {
                chats.push(StoreChatMeta.FromXmlNode(childNode, defaultNsp));
            }
        }
        return new StoreChatGroupMeta(character, chats);
    }
}
