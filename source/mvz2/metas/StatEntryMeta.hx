// Ported from: Assets/Scripts/MVZ2/Metas/Stats/StatEntryMeta.cs
package mvz2.metas;

import mvz2.io.XMLHelper;
import pvzengine.Log;
import system.xml.XmlNode;
using mvz2.io.XMLHelper;  // EXTUSING

class StatEntryMeta {
    public var ID(default, null):String;
    public var Name(default, null):String = "";

    public function new(iD:String) {
        ID = iD;
    }
    public static function FromXmlNode(node:XmlNode, defaultNsp:String):StatEntryMeta {
        var id = XMLHelper.GetAttribute(node, "id");
        if (id == null || id.length == 0) {
            Log.LogError('The id of a StatEntryMeta is invalid.');
            return null;
        }
        var name = XMLHelper.GetAttribute(node, "name");
        if (name == null) name = "";
        var meta = new StatEntryMeta(id);
        meta.Name = name;
        return meta;
    }
}
