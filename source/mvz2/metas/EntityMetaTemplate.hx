// Ported from: Assets/Scripts/MVZ2/Metas/Entity/EntityMetaTemplate.cs
package mvz2.metas;
import mvz2.metas.EntityMeta.BehaviourItem;  // IMPORTAUTO

import mvz2.io.XMLHelper;
import pvzengine.PropertyRegions;
import pvzengine.definitions.EngineDefinitionTypes;
import system.xml.XmlNode;
using mvz2.io.XMLHelper;  // EXTUSING

class EntityMetaTemplate implements IMetaTemplate {
    public var type:Int;
    public var id:String;
    public var behaviours:Array<BehaviourItem>;
    public var properties:Map<String, Dynamic>;

    public function new(type:Int, id:String, behaviours:Array<BehaviourItem>, properties:Map<String, Dynamic>) {
        this.id = id;
        this.type = type;
        this.behaviours = behaviours;
        this.properties = properties;
    }

    public function GetBehaviours():Array<BehaviourItem> return behaviours;
    public function GetProperties():Map<String, Dynamic> return properties;

    public static function LoadChildrenTemplates(node:XmlNode, defaultNsp:String):Array<EntityMetaTemplate> {
        var templates:Array<EntityMetaTemplate> = [];
        // PORT-NOTE: C# 未对 node 判空（<templates> 在实体表中为必需节点）；
        // Haxe 侧为避免资源加载期崩溃，node 为空时直接返回空数组。
        // TODO-PORT: 这是与 C# 的刻意为之处（C# 在缺失 <templates> 时会抛 NullReferenceException），
        // 如需 1:1 复现崩溃行为可移除此判空。
        if (node == null)
            return templates;
        for (i in 0...node.ChildNodes.Count) {
            var templateNode = node.ChildNodes.getAt(i);
            var template = LoadTemplateFromNode(templateNode, defaultNsp, node);
            if (template == null)
                continue;
            templates.push(template);
        }
        return templates;
    }
    private static function LoadTemplateFromNode(node:XmlNode, defaultNsp:String, rootNode:XmlNode):EntityMetaTemplate {
        var id = node.Name;
        var typeAttr = XMLHelper.GetAttributeInt(node, "type");
        var type = typeAttr != null ? typeAttr : -1;
        var behaviours:Array<BehaviourItem> = [];
        var properties:Map<String, Dynamic> = new Map();
        XMLHelper.LoadTemplatePropertiesFromNode(node, defaultNsp, rootNode, EngineDefinitionTypes.ENTITY_BEHAVIOUR, PropertyRegions.entity, behaviours, properties);

        return new EntityMetaTemplate(type, node.Name, behaviours, properties);
    }
}
