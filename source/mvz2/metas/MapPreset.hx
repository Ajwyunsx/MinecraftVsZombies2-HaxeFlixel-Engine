// Ported from: Assets/Scripts/MVZ2/Metas/Map/MapMeta.cs
package mvz2.metas;

import mvz2.io.XMLHelper;
import pvzengine.Log;
import pvzengine.NamespaceID;
import system.xml.XmlNode;
import unity.Color;
using mvz2.io.XMLHelper;  // EXTUSING
using pvzengine.PropertyKeyHelper;  // EXTUSING

class MapPreset {
    public var id:NamespaceID;
    public var model:NamespaceID;
    public var music:NamespaceID;
    public var priority:Int;
    public var conditions:XMLConditionList;
    public var backgroundColor:Color = new Color(0, 0, 0, 0); // PORT-NOTE: C# Color 为 struct，default 为 (0,0,0,0) 透明黑；显式初始化避免 abstract-over-class 的 null 解引用

    private function new(id:NamespaceID) {
        this.id = id;
    }

    public static function FromXmlNode(node:XmlNode, defaultNsp:String):MapPreset {
        var id = XMLHelper.GetAttributeNamespaceID(node, "id", defaultNsp);
        if (!NamespaceID.IsValid(id)) {
            Log.LogError('The id of a MapPreset is invalid.');
            return null;
        }
        var model = XMLHelper.GetAttributeNamespaceID(node, "model", defaultNsp);
        var music = XMLHelper.GetAttributeNamespaceID(node, "music", defaultNsp);
        var backgroundColorAttr = XMLHelper.GetAttributeColor(node, "backgroundColor");
        var backgroundColor = backgroundColorAttr != null ? backgroundColorAttr : Color.black;
        var priorityAttr = XMLHelper.GetAttributeInt(node, "priority");
        var priority = priorityAttr != null ? priorityAttr : 0;
        var conditions:XMLConditionList = null;
        var conditionsNode = node["conditions"];
        if (conditionsNode != null) {
            conditions = XMLConditionList.FromXmlNode(conditionsNode, defaultNsp);
        }
        var preset = new MapPreset(id);
        preset.model = model;
        preset.music = music;
        preset.priority = priority;
        preset.backgroundColor = backgroundColor;
        preset.conditions = conditions;
        return preset;
    }
}
