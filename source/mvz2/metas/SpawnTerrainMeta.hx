// Ported from: Assets/Scripts/MVZ2/Metas/Spawns/SpawnMeta.cs
package mvz2.metas;

import mvz2.io.XMLHelper;
import pvzengine.NamespaceID;
import system.xml.XmlNode;
using mvz2.io.XMLHelper;  // EXTUSING

class SpawnTerrainMeta {
    public function new(excludedAreaTags:Array<NamespaceID>) {
        ExcludedAreaTags = excludedAreaTags;
    }

    public var ExcludedAreaTags(default, null):Array<NamespaceID>;
    public var Water(default, null):Bool;
    public var Air(default, null):Bool;

    public static function FromXmlNode(node:XmlNode, defaultNsp:String):SpawnTerrainMeta {
        var excludedAreaTags = XMLHelper.GetAttributeNamespaceIDArray(node, "excludedTags", defaultNsp);
        if (excludedAreaTags == null) excludedAreaTags = [];
        var waterAttr = XMLHelper.GetAttributeBool(node, "water");
        var water = waterAttr != null ? waterAttr : false;
        var airAttr = XMLHelper.GetAttributeBool(node, "air");
        var air = airAttr != null ? airAttr : false;
        var meta = new SpawnTerrainMeta(excludedAreaTags);
        meta.Water = water;
        meta.Air = air;
        return meta;
    }
}
