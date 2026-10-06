// Ported from: Assets/Scripts/MVZ2/Metas/LoreTalkMeta.cs
package mvz2.metas;

import mvz2.io.XMLHelper;
import pvzengine.Log;
import pvzengine.NamespaceID;
import system.xml.XmlNode;
using mvz2.io.XMLHelper;  // EXTUSING
using pvzengine.PropertyKeyHelper;  // EXTUSING

class LoreTalkMeta {
    private function new(iD:NamespaceID) {
        ID = iD;
    }

    public var ID:NamespaceID;
    public var Conditions:XMLConditionList;

    public static function FromXmlNode(node:XmlNode, defaultNsp:String):LoreTalkMeta {
        var id = XMLHelper.GetAttributeNamespaceID(node, "id", defaultNsp);
        if (!NamespaceID.IsValid(id)) {
            Log.LogError('The id of a LoreTalkMeta is invalid.');
            return null;
        }
        var conditions = XMLConditionList.FromXmlNode(node["conditions"], defaultNsp);
        var meta = new LoreTalkMeta(id);
        meta.Conditions = conditions;
        return meta;
    }
}
