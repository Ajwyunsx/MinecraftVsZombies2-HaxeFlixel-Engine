// Ported from: Assets/Scripts/MVZ2/Metas/Blueprint/BlueprintErrorMeta.cs
package mvz2.metas;

import mvz2.io.XMLHelper;
import pvzengine.Log;
import system.xml.XmlNode;
using mvz2.io.XMLHelper;  // EXTUSING

class BlueprintErrorMeta {
    public function new(id:String, message:String) {
        ID = id;
        Message = message;
    }

    public var ID(default, null):String;
    public var Message(default, null):String;
    public static function FromXmlNode(node:XmlNode, defaultNsp:String):BlueprintErrorMeta {
        var id = XMLHelper.GetAttribute(node, "id");
        if (id == null || id.length == 0) {
            Log.LogError("The ID of a BlueprintErrorMeta is invalid.");
            return null;
        }
        var message = XMLHelper.GetAttribute(node, "message");
        if (message == null) message = "";
        return new BlueprintErrorMeta(id, message);
    }
}
