// Ported from: Assets/Scripts/MVZ2/Metas/Stage/StageMeta.cs
package mvz2.metas;

import mvz2.io.XMLHelper;
import pvzengine.NamespaceID;
import pvzengine.level.IConveyorPoolEntry;
import system.xml.XmlNode;
import unity.Debug;
using mvz2.io.XMLHelper;  // EXTUSING
using pvzengine.PropertyKeyHelper;  // EXTUSING

class ConveyorPoolEntry implements IConveyorPoolEntry {
    public var ID(default, null):NamespaceID;
    public var Count(default, null):Int;
    public var MinCount(default, null):Int;

    public function new(id:NamespaceID, count:Int = 1, minCount:Int = 1) {
        ID = id;
        Count = count;
        MinCount = minCount;
    }
    public static function FromXmlNode(node:XmlNode, defaultNsp:String):ConveyorPoolEntry {
        var id = XMLHelper.GetAttributeNamespaceID(node, "id", defaultNsp);
        if (!NamespaceID.IsValid(id)) {
            Debug.LogError("The ID of a ConveyorPoolEntry is invalid.");
            return null;
        }
        var countAttr = XMLHelper.GetAttributeInt(node, "count");
        var count = countAttr != null ? countAttr : 1;
        var minCountAttr = XMLHelper.GetAttributeInt(node, "minCount");
        var minCount = minCountAttr != null ? minCountAttr : 1;
        return new ConveyorPoolEntry(id, count, minCount);
    }
}
