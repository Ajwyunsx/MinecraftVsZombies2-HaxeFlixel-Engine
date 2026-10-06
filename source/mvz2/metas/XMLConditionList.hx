// Ported from: Assets/Scripts/MVZ2/Metas/XMLConditionList.cs
package mvz2.metas;

import mvz2logic.conditions.IConditionList;
import mvz2logic.games.IGlobalSaveData;
import pvzengine.NamespaceID;
import system.xml.XmlDocument;
import system.xml.XmlNode;

class XMLConditionList implements IConditionList {
    public function new(...conditions:XMLCondition) {
        Conditions = conditions;
    }
    public function ToXmlNode(name:String, document:XmlDocument):XmlNode {
        var node = document.CreateElement(name);
        for (condition in Conditions) {
            var conditionNode = condition.ToXmlNode("condition", document);
            node.AppendChild(conditionNode);
        }
        return node;
    }
    public static function FromXmlNode(node:XmlNode, defaultNsp:String):XMLConditionList {
        var conditions:Array<XMLCondition> = [];
        for (i in 0...node.ChildNodes.Count) {
            var childNode = node.ChildNodes.getAt(i);
            if (childNode.Name == "condition") {
                conditions.push(XMLCondition.FromXmlNode(childNode, defaultNsp));
            }
        }
        return new XMLConditionList(...conditions);
    }

    public static function FromSingle(id:NamespaceID):XMLConditionList {
        return new XMLConditionList(XMLCondition.FromSingle(id));
    }
    public static function FromMultiple(ids:Array<NamespaceID>):XMLConditionList {
        return new XMLConditionList(XMLCondition.FromMultiple(ids));
    }
    public function MeetsConditions(save:IGlobalSaveData):Bool {
        return Lambda.exists(Conditions, c -> c.MeetsCondition(save));
    }
    public var Conditions(default, null):Array<XMLCondition>;
}
