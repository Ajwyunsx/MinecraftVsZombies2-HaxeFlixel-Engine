// Ported from: Assets/Scripts/MVZ2/Metas/Armors/ArmorMeta.cs
package mvz2.metas;

import mvz2.io.XMLHelper;
import pvzengine.Log;
import pvzengine.NamespaceID;
import pvzengine.PropertyKeyHelper;
import pvzengine.PropertyRegions;
import pvzengine.collisions.ColliderConstructor;
import system.xml.XmlNode;
using mvz2.io.XMLHelper;  // EXTUSING
using pvzengine.PropertyKeyHelper;  // EXTUSING

class ArmorMeta {
    public function new(id:String, behaviours:Array<NamespaceID>, colliderConstructors:Array<ColliderConstructor>, properties:Map<String, Dynamic>) {
        ID = id;
        Behaviours = behaviours;
        ColliderConstructors = colliderConstructors;
        Properties = properties;
    }

    public var ID(default, null):String;
    public var Ignored(default, null):Bool;
    public var Type(default, null):NamespaceID;
    public var Behaviours(default, null):Array<NamespaceID>;
    public var ColliderConstructors(default, null):Array<ColliderConstructor>;
    public var Properties(default, null):Map<String, Dynamic>;

    public static function FromXmlNode(node:XmlNode, defaultNsp:String):ArmorMeta {
        var id = XMLHelper.GetAttribute(node, "id");

        if (id == null || id.length == 0) {
            Log.LogError("The ID of an ArmorMeta is invalid.");
            return null;
        }

        var ignoredAttr = XMLHelper.GetAttributeBool(node, "ignored");
        var ignored = ignoredAttr != null ? ignoredAttr : false;
        var type = XMLHelper.GetAttributeNamespaceID(node, "type", defaultNsp);

        var behavioursNode = node["behaviours"];
        var behaviours:Array<NamespaceID> = [];
        if (behavioursNode != null) {
            for (i in 0...behavioursNode.ChildNodes.Count) {
                var behaviourNode = behavioursNode.ChildNodes.getAt(i);
                var behaviour = XMLHelper.GetAttributeNamespaceID(behaviourNode, "id", defaultNsp);
                if (behaviour != null) {
                    behaviours.push(behaviour);
                }
            }
        }

        var collidersNode = node["colliders"];
        var colliders:Array<ColliderConstructor> = [];
        if (collidersNode != null) {
            for (i in 0...collidersNode.ChildNodes.Count) {
                var colliderNode = collidersNode.ChildNodes.getAt(i);
                var collider = MetaXMLParser.LoadColliderConstructor(colliderNode);
                colliders.push(collider);
            }
        }

        var propsNode = node["props"];
        var props = XMLHelper.ToPropertyDictionary(propsNode, defaultNsp);
        var properties:Map<String, Dynamic> = new Map();
        for (propKey in props.keys()) {
            var fullName = PropertyKeyHelper.ParsePropertyFullName(propKey, defaultNsp, PropertyRegions.armor);
            properties.set(fullName, props.get(propKey));
        }

        var meta = new ArmorMeta(id, behaviours, colliders, properties);
        meta.Type = type;
        meta.Ignored = ignored;
        return meta;
    }
}
