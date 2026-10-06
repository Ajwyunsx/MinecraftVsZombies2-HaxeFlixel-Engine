// Ported from: Assets/Scripts/MVZ2/Metas/Map/MapElementMeta.cs
package mvz2.metas;
import mvz2.metas.EntityMeta.BehaviourItem;  // IMPORTAUTO

import mvz2.io.XMLHelper;
import mvz2logic.LogicPropertyRegions;
import mvz2logic.definitions.LogicDefinitionTypes;
import pvzengine.Log;
import pvzengine.NamespaceID;
import system.xml.XmlNode;
using mvz2.io.XMLHelper;  // EXTUSING

class MapElementMeta {
    public var id:String;
    public var unlockConditions:XMLConditionList;
    public var properties:Map<String, Dynamic>;
    public var behaviours:Array<NamespaceID>;

    private function new(id:String, properties:Map<String, Dynamic>, behaviours:Array<NamespaceID>) {
        this.id = id;
        this.properties = properties;
        this.behaviours = behaviours;
    }

    public static function FromXmlNode(node:XmlNode, defaultNsp:String, templates:Array<MapElementMetaTemplate>):MapElementMeta {
        var id = XMLHelper.GetAttribute(node, "id");
        if (id == null || id.length == 0) {
            Log.LogError('The id of a MapElementMeta is invalid.');
            return null;
        }
        var unlockConditions:XMLConditionList = null;
        var unlockNode = node["unlock"];
        if (unlockNode != null) {
            unlockConditions = XMLConditionList.FromXmlNode(unlockNode, defaultNsp);
        }

        // 加载地图元素行为与属性。
        var templateID = XMLHelper.GetAttribute(node, "template");
        var template:MapElementMetaTemplate = null;
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
            XMLHelper.LoadPropertiesFromNode(propertyNode, defaultNsp, LogicPropertyRegions.mapElement, properties);
        if (template != null) {
            XMLHelper.LoadBehavioursAndPropertiesFromTemplate(defaultNsp, LogicDefinitionTypes.MAP_ELEMENT_BEHAVIOUR, template, behaviours, properties);
        }
        if (behavioursNode != null)
            XMLHelper.LoadBehavioursFromNode(behavioursNode, defaultNsp, LogicDefinitionTypes.MAP_ELEMENT_BEHAVIOUR, behaviours, properties);

        // PORT-NOTE: C# `OrderBy(b => b.priority)`（稳定排序）→ Haxe Array.sort（不保证稳定）。
        // TODO-PORT: 与 EntityMeta 相同，同 priority 的 behaviour 顺序可能与 C# 不一致。
        behaviours.sort((a, b) -> a.priority - b.priority);
        var behavioursArray:Array<NamespaceID> = [];
        for (b in behaviours) {
            behavioursArray.push(b.id);
        }

        var meta = new MapElementMeta(id, properties, behavioursArray);
        meta.unlockConditions = unlockConditions;
        return meta;
    }
}
