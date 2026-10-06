// Ported from: Assets/Scripts/MVZ2/Metas/MainmenuView/MainmenuViewMeta.cs
package mvz2.metas;

import mvz2.io.XMLHelper;
import pvzengine.Log;
import pvzengine.NamespaceID;
import system.xml.XmlNode;
using mvz2.io.XMLHelper;  // EXTUSING

class MainmenuViewMeta {
    private function new(iD:String) {
        ID = iD;
    }

    public var ID(default, null):String;
    public var Priority(default, null):Int;
    public var SpritesheetID(default, null):NamespaceID;
    public var Conditions(default, null):XMLConditionList;
    public static function FromXmlNode(node:XmlNode, defaultNsp:String):MainmenuViewMeta {
        var id = XMLHelper.GetAttribute(node, "id");
        if (id == null || id.length == 0) {
            Log.LogError('The id of a MainmenuViewMeta is invalid.');
            return null;
        }
        var priorityAttr = XMLHelper.GetAttributeInt(node, "priority");
        var priority = priorityAttr != null ? priorityAttr : 0;
        var spritesheet = XMLHelper.GetAttributeNamespaceID(node, "spritesheet", defaultNsp);
        var conditionsNode = node.GetChildNode("conditions");
        var conditions:XMLConditionList = null;
        if (conditionsNode != null) {
            conditions = XMLConditionList.FromXmlNode(conditionsNode, defaultNsp);
        }
        var meta = new MainmenuViewMeta(id);
        meta.Priority = priority;
        meta.SpritesheetID = spritesheet;
        meta.Conditions = conditions;
        return meta;
    }
}
