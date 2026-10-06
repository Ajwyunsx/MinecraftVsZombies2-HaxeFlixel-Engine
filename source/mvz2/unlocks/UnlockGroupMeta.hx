package mvz2.unlocks;

import mvz2.metas.XMLConditionList;
import mvz2logic.Log;
import system.xml.XmlNode;

// Ported from: Assets/Scripts/MVZ2/Unlocks/UnlockGroupMeta.cs
class UnlockGroupMeta {
    public function new(id:String) {
        ID = id;
    }

    public var ID(default, null):String;
    public var Conditions(default, null):XMLConditionList;
    public static function FromXmlNode(node:XmlNode, defaultNsp:String):UnlockGroupMeta {
        var id = node.getAttributeValue("id");
        if (id == null || id.length == 0) {
            Log.LogError("The ID of an UnlockGroupMeta is invalid.");
            return null;
        }
        var conditionsNode:XmlNode = node["conditions"];
        var unlock:XMLConditionList = null;
        if (conditionsNode != null) {
            unlock = XMLConditionList.FromXmlNode(conditionsNode, defaultNsp);
        }
        var result = new UnlockGroupMeta(id);
        result.Conditions = unlock;
        return result;
    }
}
