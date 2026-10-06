// Ported from: Assets/Scripts/MVZ2/Metas/Spawns/SpawnMeta.cs
package mvz2.metas;

import mvz2.io.XMLHelper;
import pvzengine.NamespaceID;
import system.xml.XmlNode;
import unity.Debug;
using mvz2.io.XMLHelper;  // EXTUSING

class SpawnMeta {
    private function new(iD:String, type:String) {
        ID = iD;
        Type = type;
    }

    public var ID(default, null):String;
    public var Type(default, null):String;
    public var Entity(default, null):NamespaceID;
    public var EntityVariant(default, null):Int;
    public var PreviewEntity(default, null):NamespaceID;
    public var PreviewVariant(default, null):Int;
    public var SpawnLevel(default, null):Int;
    public var MinSpawnWave(default, null):Int;
    public var PreviewCount(default, null):Int;
    public var NoEndless(default, null):Bool;
    public var Terrain(default, null):SpawnTerrainMeta;
    public var Weight(default, null):SpawnWeightMeta;

    public static function FromXmlNode(node:XmlNode, defaultNsp:String):SpawnMeta {
        var id = XMLHelper.GetAttribute(node, "id");
        if (id == null || id.length == 0) {
            Debug.LogError("The ID of a SpawnMeta is empty.");
            return null;
        }
        var type = XMLHelper.GetAttribute(node, "type");
        if (type == null) type = "entity";
        var noEndlessAttr = XMLHelper.GetAttributeBool(node, "noEndless");
        var noEndless = noEndlessAttr != null ? noEndlessAttr : false;

        var variant = 0;
        var entityNode = node["entity"];
        // PORT-NOTE: C# `entityNode?.GetAttributeNamespaceID(...) ?? node.GetAttributeNamespaceID(...)` → 显式判空。
        var entity = entityNode != null ? XMLHelper.GetAttributeNamespaceID(entityNode, "id", defaultNsp) : null;
        if (entity == null) {
            entity = XMLHelper.GetAttributeNamespaceID(node, "entity", defaultNsp);
        }
        if (entityNode != null) {
            var variantAttr = XMLHelper.GetAttributeInt(entityNode, "variant");
            if (variantAttr != null) variant = variantAttr;
        }

        var level = 1;
        var minWave = 0;
        var spawnNode = node["spawn"];
        if (spawnNode != null) {
            var levelAttr = XMLHelper.GetAttributeInt(spawnNode, "level");
            level = levelAttr != null ? levelAttr : 1;
            var minWaveAttr = XMLHelper.GetAttributeInt(spawnNode, "minWave");
            minWave = minWaveAttr != null ? minWaveAttr : 0;
        }

        var previewCount = 1;
        var previewEntity = entity;
        var previewVariant = variant;
        var previewNode = node["preview"];
        if (previewNode != null) {
            var previewEntityAttr = XMLHelper.GetAttributeNamespaceID(previewNode, "entity", defaultNsp);
            if (previewEntityAttr != null) previewEntity = previewEntityAttr;
            var previewVariantAttr = XMLHelper.GetAttributeInt(previewNode, "variant");
            if (previewVariantAttr != null) previewVariant = previewVariantAttr;
            var previewCountAttr = XMLHelper.GetAttributeInt(previewNode, "count");
            previewCount = previewCountAttr != null ? previewCountAttr : 1;
        }

        var terrain:SpawnTerrainMeta = null;
        var terrainNode = node["terrain"];
        if (terrainNode != null) {
            terrain = SpawnTerrainMeta.FromXmlNode(terrainNode, defaultNsp);
        }

        var weight:SpawnWeightMeta = null;
        var weightNode = node["weight"];
        if (weightNode != null) {
            weight = SpawnWeightMeta.FromXmlNode(weightNode);
        }
        var meta = new SpawnMeta(id, type);
        meta.Entity = entity;
        meta.EntityVariant = variant;
        meta.PreviewEntity = previewEntity;
        meta.PreviewVariant = previewVariant;
        meta.SpawnLevel = level;
        meta.NoEndless = noEndless;
        meta.MinSpawnWave = minWave;
        meta.PreviewCount = previewCount;
        meta.Terrain = terrain;
        meta.Weight = weight;
        return meta;
    }
}
