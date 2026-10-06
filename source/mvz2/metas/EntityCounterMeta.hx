// Ported from: Assets/Scripts/MVZ2/Metas/Entity/EntityCounterMeta.cs
package mvz2.metas;

import mvz2.io.XMLHelper;
import pvzengine.Log;
import system.xml.XmlNode;
using mvz2.io.XMLHelper;  // EXTUSING

class EntityCounterMeta {
    public var ID(default, null):String;
    public var Name(default, null):String;
    public function new(id:String, name:String) {
        ID = id;
        Name = name;
    }

    public static function FromXmlNode(node:XmlNode, defaultNsp:String):EntityCounterMeta {
        var id = XMLHelper.GetAttribute(node, "id");
        if (id == null || id.length == 0) {
            Log.LogError('The id of an EntityCounterMeta is invalid.');
            return null;
        }
        var name = XMLHelper.GetAttribute(node, "name");
        if (name == null) name = "";

        return new EntityCounterMeta(id, name);
    }
}
