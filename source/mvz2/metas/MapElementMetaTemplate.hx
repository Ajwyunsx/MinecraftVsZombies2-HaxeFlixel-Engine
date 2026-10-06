// Ported from: Assets/Scripts/MVZ2/Metas/Map/MapElementMetaTemplate.cs
package mvz2.metas;
import mvz2.metas.EntityMeta.BehaviourItem;  // IMPORTAUTO

import mvz2.io.XMLHelper;
import mvz2logic.LogicPropertyRegions;
import mvz2logic.definitions.LogicDefinitionTypes;
import system.xml.XmlNode;
using mvz2.io.XMLHelper;  // EXTUSING

class MapElementMetaTemplate implements IMetaTemplate {
    public var id:String;
    public var behaviours:Array<BehaviourItem>;
    public var properties:Map<String, Dynamic>;

    public function new(id:String, behaviours:Array<BehaviourItem>, properties:Map<String, Dynamic>) {
        this.id = id;
        this.behaviours = behaviours;
        this.properties = properties;
    }

    public function GetBehaviours():Array<BehaviourItem> return behaviours;
    public function GetProperties():Map<String, Dynamic> return properties;
    public static function LoadTemplates(node:XmlNode, defaultNsp:String):Array<MapElementMetaTemplate> {
        var templates:Array<MapElementMetaTemplate> = [];
        for (i in 0...node.ChildNodes.Count) {
            var templateNode = node.ChildNodes.getAt(i);
            var template = MapElementMetaTemplate.LoadTemplate(templateNode, defaultNsp, node);
            if (template == null)
                continue;
            templates.push(template);
        }
        return templates;
    }
    private static function LoadTemplate(node:XmlNode, defaultNsp:String, rootNode:XmlNode):MapElementMetaTemplate {
        var id = node.Name;
        var behaviours:Array<BehaviourItem> = [];
        var properties:Map<String, Dynamic> = new Map();
        XMLHelper.LoadTemplatePropertiesFromNode(node, defaultNsp, rootNode, LogicDefinitionTypes.MAP_ELEMENT_BEHAVIOUR, LogicPropertyRegions.mapElement, behaviours, properties);

        return new MapElementMetaTemplate(id, behaviours, properties);
    }
}
