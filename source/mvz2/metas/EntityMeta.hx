// Ported from: Assets/Scripts/MVZ2/Metas/Entity/EntityMeta.cs
package mvz2.metas;

import mvz2.io.XMLHelper;
import pvzengine.NamespaceID;
import pvzengine.PropertyRegions;
import pvzengine.definitions.EngineDefinitionTypes;
import pvzengine.entities.EntityTypes;
import system.xml.XmlNode;
import unity.Debug;
using mvz2.io.XMLHelper;  // EXTUSING
using pvzengine.PropertyKeyHelper;  // EXTUSING

class EntityMeta {
    private function new(iD:String, name:String, deathMessage:String, tooltip:String, unlock:XMLConditionList, behaviours:Array<NamespaceID>, properties:Map<String, Dynamic>) {
        ID = iD;
        Name = name;
        DeathMessage = deathMessage;
        Tooltip = tooltip;
        Unlock = unlock;
        Behaviours = behaviours;
        Properties = properties;
    }

    public var Type(default, null):Int;
    public var ID(default, null):String;
    public var Name(default, null):String;
    public var DeathMessage(default, null):String;
    public var Tooltip(default, null):String;
    public var Unlock(default, null):XMLConditionList;
    public var Order(default, null):Int;
    public var Behaviours(default, null):Array<NamespaceID>;
    public var Properties(default, null):Map<String, Dynamic>;

    public static function FromXmlNode(nsp:String, node:XmlNode, defaultNsp:String, templates:Array<EntityMetaTemplate>, order:Int):EntityMeta {
        var id = XMLHelper.GetAttribute(node, "id");
        if (id == null || id.length == 0) {
            Debug.LogError("The ID of an EntityMeta is empty.");
            return null;
        }
        var type = EntityTypes.EFFECT;
        var name = XMLHelper.GetAttribute(node, "name");
        if (name == null) name = "";
        var deathMessageAttr = XMLHelper.GetAttribute(node, "deathMessage");
        var deathMessage = deathMessageAttr != null ? StringTools.replace(deathMessageAttr, "\\n", "\n") : "";
        var tooltipAttr = XMLHelper.GetAttribute(node, "tooltip");
        var tooltip = tooltipAttr != null ? StringTools.replace(tooltipAttr, "\\n", "\n") : "";

        var unlockConditions = XMLHelper.GetUnlockConditionsOrObsolete(node, "unlock", "unlock", defaultNsp);

        // 加载实体行为与属性。
        var templateID = XMLHelper.GetAttribute(node, "template");
        var template:EntityMetaTemplate = null;
        for (t in templates) {
            if (t.id == templateID) {
                template = t;
                break;
            }
        }

        var behaviours:Array<BehaviourItem> = [];
        var properties:Map<String, Dynamic> = new Map();

        var behavioursNode = node["behaviours"];
        var propertyNode = node["properties"];
        if (propertyNode != null)
            XMLHelper.LoadPropertiesFromNode(propertyNode, defaultNsp, PropertyRegions.entity, properties);
        if (template != null) {
            type = template.type;
            XMLHelper.LoadBehavioursAndPropertiesFromTemplate(defaultNsp, EngineDefinitionTypes.ENTITY_BEHAVIOUR, template, behaviours, properties);
        }
        if (behavioursNode != null)
            XMLHelper.LoadBehavioursFromNode(behavioursNode, defaultNsp, EngineDefinitionTypes.ENTITY_BEHAVIOUR, behaviours, properties);

        var includeSelfAttr = behavioursNode != null ? XMLHelper.GetAttributeBool(behavioursNode, "includeSelf") : null;
        var includeSelfBehaviour = includeSelfAttr != null ? includeSelfAttr : true;
        if (includeSelfBehaviour) {
            behaviours.push(new BehaviourItem(new NamespaceID(nsp, id), 0));
        }
        // PORT-NOTE: C# `OrderBy(b => b.priority)`（稳定排序）→ Haxe Array.sort（不保证稳定）。
        // TODO-PORT: 若同一实体存在同 priority 的多个 behaviour，Haxe 的排序结果可能与 C# 的稳定
        // 排序不同，导致 behaviour 执行顺序差异；需要稳定排序时应改为按 (priority, 原始下标) 比较。
        behaviours.sort((a, b) -> a.priority - b.priority);
        var behavioursArray:Array<NamespaceID> = [];
        for (b in behaviours) {
            behavioursArray.push(b.id);
        }

        var meta = new EntityMeta(id, name, deathMessage, tooltip, unlockConditions, behavioursArray, properties);
        meta.Type = type;
        meta.Order = order;
        return meta;
    }
}

class EntityBehaviourItem {
    public var Operator(default, null):BehaviourOperator;
    public var SourceID(default, null):NamespaceID;
    public var ID(default, null):NamespaceID;
    public var Priority(default, null):Int;

    // PORT-NOTE: C# 参数名 `@operator`；`operator` 是 Haxe 关键字，改名为 `op`。
    public function new(op:BehaviourOperator, iD:NamespaceID) {
        Operator = op;
        ID = iD;
    }
    public static function FromXmlNode(node:XmlNode, defaultNsp:String):EntityBehaviourItem {
        var id = XMLHelper.GetAttributeNamespaceID(node, "id", defaultNsp);
        if (!NamespaceID.IsValid(id)) {
            Debug.LogError("The id attribute of an EntityBehaviour node is invalid.");
            return null;
        }
        var opStr = XMLHelper.GetAttribute(node, "operator");
        var op = BehaviourOperator.Add;
        if (opStr != null && opStr.length > 0 && operatorDict.exists(opStr)) {
            op = operatorDict.get(opStr);
        }
        var sourceID = XMLHelper.GetAttributeNamespaceID(node, "source", defaultNsp);
        var priorityAttr = XMLHelper.GetAttributeInt(node, "priority");
        var priority = priorityAttr != null ? priorityAttr : 0;
        var item = new EntityBehaviourItem(op, id);
        item.SourceID = sourceID;
        item.Priority = priority;
        return item;
    }
    private static var operatorDict:Map<String, BehaviourOperator> = [
        "add" => BehaviourOperator.Add,
        "remove" => BehaviourOperator.Remove,
        "replace" => BehaviourOperator.Replace,
    ];
}

// PORT-NOTE: C# struct BehaviourItem → Haxe class（PORTING.md §struct）。
class BehaviourItem {
    public var id:NamespaceID;
    public var priority:Int;

    public function new(id:NamespaceID, priority:Int) {
        this.id = id;
        this.priority = priority;
    }
}

enum abstract BehaviourOperator(Int) {
    var Add = 0;
    var Remove = 1;
    var Replace = 2;
}
