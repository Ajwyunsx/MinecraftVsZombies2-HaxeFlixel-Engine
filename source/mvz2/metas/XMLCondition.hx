// Ported from: Assets/Scripts/MVZ2/Metas/XMLCondition.cs
package mvz2.metas;

import mvz2.io.XMLHelper;
import mvz2logic.conditions.ICondition;
import mvz2logic.games.IGlobalSaveData;
import pvzengine.NamespaceID;
import system.xml.XmlDocument;
import system.xml.XmlNode;
using mvz2.io.XMLHelper;  // EXTUSING

class XMLCondition implements ICondition {
    public function new() {}

    public function ToXmlNode(name:String, document:XmlDocument):XmlNode {
        var node = document.CreateElement(name);
        if (Required != null && Required.length > 0) {
            XMLHelper.CreateAttribute(node, "required", Required.map(e -> e.toString()).join(" "));
        }
        if (RequiredNot != null && RequiredNot.length > 0) {
            XMLHelper.CreateAttribute(node, "requiredNot", RequiredNot.map(e -> e.toString()).join(" "));
        }
        if (RequiredGroups != null && RequiredGroups.length > 0) {
            XMLHelper.CreateAttribute(node, "requiredGroups", RequiredGroups.map(e -> e.toString()).join(" "));
        }
        if (RequiredNotGroups != null && RequiredNotGroups.length > 0) {
            XMLHelper.CreateAttribute(node, "requiredNotGroups", RequiredNotGroups.map(e -> e.toString()).join(" "));
        }
        return node;
    }
    public static function FromXmlNode(node:XmlNode, defaultNsp:String):XMLCondition {
        var required = XMLHelper.GetAttributeNamespaceIDArray(node, "required", defaultNsp);
        var requiredNot = XMLHelper.GetAttributeNamespaceIDArray(node, "requiredNot", defaultNsp);
        var requiredGroups = XMLHelper.GetAttributeNamespaceIDArray(node, "requiredGroups", defaultNsp);
        var requiredNotGroups = XMLHelper.GetAttributeNamespaceIDArray(node, "requiredNotGroups", defaultNsp);
        var condition = new XMLCondition();
        condition.Required = required;
        condition.RequiredNot = requiredNot;
        condition.RequiredGroups = requiredGroups;
        condition.RequiredNotGroups = requiredNotGroups;
        return condition;
    }
    public static function FromSingle(id:NamespaceID):XMLCondition {
        var condition = new XMLCondition();
        condition.Required = [id];
        return condition;
    }
    public static function FromMultiple(id:Array<NamespaceID>):XMLCondition {
        var condition = new XMLCondition();
        condition.Required = id;
        return condition;
    }
    public function MeetsCondition(save:IGlobalSaveData):Bool {
        if (Required != null && Lambda.exists(Required, c -> !save.IsUnlocked(c)))
            return false;
        if (RequiredGroups != null && Lambda.exists(RequiredGroups, c -> !save.IsGroupUnlocked(c)))
            return false;
        if (RequiredNot != null && Lambda.exists(RequiredNot, c -> save.IsUnlocked(c)))
            return false;
        if (RequiredNotGroups != null && Lambda.exists(RequiredNotGroups, c -> save.IsGroupUnlocked(c)))
            return false;
        return true;
    }
    public var Required:Array<NamespaceID>;
    public var RequiredNot:Array<NamespaceID>;
    public var RequiredGroups:Array<NamespaceID>;
    public var RequiredNotGroups:Array<NamespaceID>;
}
