// Ported from: Assets/Scripts/MVZ2/Metas/Grids/GridMeta.cs
package mvz2.metas;

import mvz2.io.XMLHelper;
import pvzengine.Log;
import system.xml.XmlNode;
using mvz2.io.XMLHelper;  // EXTUSING

class GridErrorMeta {
    public function new(iD:String, message:String) {
        ID = iD;
        Message = message;
    }

    public var ID(default, null):String;
    public var Message(default, null):String;

    public static function FromXmlNode(node:XmlNode, defaultNsp:String):GridErrorMeta {
        var id = XMLHelper.GetAttribute(node, "id");
        if (id == null || id.length == 0) {
            Log.LogError('The id of a GridErrorMeta is invalid.');
            return null;
        }
        var message = XMLHelper.GetAttribute(node, "message");
        if (message == null) message = "";
        return new GridErrorMeta(id, message);
    }
}
