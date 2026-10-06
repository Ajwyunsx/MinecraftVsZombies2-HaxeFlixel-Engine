// Ported from: Assets/Scripts/MVZ2/Metas/Archive/ArchiveTagMeta.cs
package mvz2.metas;

import mvz2.io.XMLHelper;
import pvzengine.Log;
import system.xml.XmlNode;
using mvz2.io.XMLHelper;  // EXTUSING

class ArchiveTagMeta {
    public function new(id:String) {
        ID = id;
    }

    public var ID(default, null):String;
    public var Name(default, null):String = "";
    public var Priority(default, null):Int;
    public static function FromXmlNode(node:XmlNode, defaultNsp:String):ArchiveTagMeta {
        var id = XMLHelper.GetAttribute(node, "id");
        if (id == null || id.length == 0) {
            Log.LogError("The ID of an ArchiveTagMeta is invalid.");
            return null;
        }
        var name = XMLHelper.GetAttribute(node, "name");
        if (name == null) name = "";
        var priorityAttr = XMLHelper.GetAttributeInt(node, "priority");
        var priority = priorityAttr != null ? priorityAttr : 0;
        var meta = new ArchiveTagMeta(id);
        meta.Name = name;
        meta.Priority = priority;
        return meta;
    }
}
