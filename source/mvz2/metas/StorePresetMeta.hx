// Ported from: Assets/Scripts/MVZ2/Metas/Store/StorePresetMeta.cs
package mvz2.metas;

import mvz2.io.XMLHelper;
import mvz2logic.resources.SpriteReference;
import pvzengine.Log;
import pvzengine.NamespaceID;
import system.xml.XmlNode;
using mvz2.io.XMLHelper;  // EXTUSING

class StorePresetMeta {
    private function new(iD:String) {
        ID = iD;
    }

    public var ID(default, null):String;
    public var Character(default, null):NamespaceID;
    public var Background(default, null):SpriteReference;
    public var Music(default, null):NamespaceID;
    public var Priority(default, null):Int;
    public var Conditions(default, null):XMLConditionList;
    public static function FromXmlNode(node:XmlNode, defaultNsp:String):StorePresetMeta {
        var id = XMLHelper.GetAttribute(node, "id");
        if (id == null || id.length == 0) {
            Log.LogError('The id of a StorePresetMeta is invalid.');
            return null;
        }
        var character = XMLHelper.GetAttributeNamespaceID(node, "character", defaultNsp);
        var background = XMLHelper.GetAttributeSpriteReference(node, "background", defaultNsp);
        var music = XMLHelper.GetAttributeNamespaceID(node, "music", defaultNsp);
        var priorityAttr = XMLHelper.GetAttributeInt(node, "priority");
        var priority = priorityAttr != null ? priorityAttr : 0;

        var conditions:XMLConditionList = null;
        var conditionsNode = node.GetChildNode("conditions");
        if (conditionsNode != null) {
            conditions = XMLConditionList.FromXmlNode(conditionsNode, defaultNsp);
        }
        var meta = new StorePresetMeta(id);
        meta.Character = character;
        meta.Background = background;
        meta.Music = music;
        meta.Priority = priority;
        meta.Conditions = conditions;
        return meta;
    }
}
