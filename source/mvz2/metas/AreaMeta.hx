// Ported from: Assets/Scripts/MVZ2/Metas/AreaMeta.cs
package mvz2.metas;

import mvz2.io.XMLHelper;
import mvz2logic.resources.SpriteReference;
import pvzengine.Log;
import pvzengine.NamespaceID;
import system.xml.XmlNode;
import unity.Color;
using mvz2.io.XMLHelper;  // EXTUSING

class AreaMeta {
    public function new(id:String) {
        ID = id;
    }

    public var ID(default, null):String;
    public var ModelID(default, null):NamespaceID;
    public var MusicID(default, null):NamespaceID;
    public var Cart(default, null):NamespaceID;
    public var Tags(default, null):Array<NamespaceID>;
    public var StarshardIcon(default, null):SpriteReference;

    public var EnemySpawnX(default, null):Float;
    public var DoorZ(default, null):Float;

    public var BackgroundLight(default, null):Color;
    public var GlobalLight(default, null):Color;

    public var GridWidth(default, null):Float;
    public var GridHeight(default, null):Float;
    public var GridLeftX(default, null):Float;
    public var GridBottomZ(default, null):Float;
    public var EntityLaneZOffset(default, null):Float;
    public var Lanes(default, null):Int;
    public var Columns(default, null):Int;

    public var Grids(default, null):Array<AreaGrid>;

    public static function FromXmlNode(node:XmlNode, defaultNsp:String):AreaMeta {
        var id = XMLHelper.GetAttribute(node, "id");
        if (id == null || id.length == 0) {
            Log.LogError("The ID of an AreaMeta is invalid.");
            return null;
        }
        var model = XMLHelper.GetAttributeNamespaceID(node, "model", defaultNsp);
        var music = XMLHelper.GetAttributeNamespaceID(node, "music", defaultNsp);
        var cart = XMLHelper.GetAttributeNamespaceID(node, "cart", defaultNsp);
        var starshard = XMLHelper.GetAttributeSpriteReference(node, "starshard", defaultNsp);
        var tags = XMLHelper.GetAttributeNamespaceIDArray(node, "tags", defaultNsp);

        var enemySpawnX = 1080.0;
        var doorZ = 240.0;
        var positionsNode = node["positions"];
        if (positionsNode != null) {
            var spawnXAttr = XMLHelper.GetAttributeFloat(positionsNode, "enemySpawnX");
            if (spawnXAttr != null) enemySpawnX = spawnXAttr;
            var doorZAttr = XMLHelper.GetAttributeFloat(positionsNode, "doorZ");
            if (doorZAttr != null) doorZ = doorZAttr;
        }

        var backgroundLight = Color.white;
        var globalLight = Color.white;
        var lightingNode = node["lighting"];
        if (lightingNode != null) {
            var bgAttr = XMLHelper.GetAttributeColor(lightingNode, "background");
            if (bgAttr != null) backgroundLight = bgAttr;
            var globalAttr = XMLHelper.GetAttributeColor(lightingNode, "global");
            if (globalAttr != null) globalLight = globalAttr;
        }

        var gridWidth = 80.0;
        var gridHeight = 80.0;
        var leftX = 260.0;
        var bottomZ = 80.0;
        var entityLaneZOffset = 16.0;
        var lanes = 5;
        var columns = 9;
        var grids:Array<AreaGrid> = [];
        var gridsNode = node["grids"];
        if (gridsNode != null) {
            var widthAttr = XMLHelper.GetAttributeFloat(gridsNode, "width");
            if (widthAttr != null) gridWidth = widthAttr;
            var heightAttr = XMLHelper.GetAttributeFloat(gridsNode, "height");
            if (heightAttr != null) gridHeight = heightAttr;
            var leftXAttr = XMLHelper.GetAttributeFloat(gridsNode, "leftX");
            if (leftXAttr != null) leftX = leftXAttr;
            var bottomZAttr = XMLHelper.GetAttributeFloat(gridsNode, "bottomZ");
            if (bottomZAttr != null) bottomZ = bottomZAttr;
            var lanesAttr = XMLHelper.GetAttributeInt(gridsNode, "lanes");
            if (lanesAttr != null) lanes = lanesAttr;
            var columnsAttr = XMLHelper.GetAttributeInt(gridsNode, "columns");
            if (columnsAttr != null) columns = columnsAttr;
            var zOffsetAttr = XMLHelper.GetAttributeInt(gridsNode, "entityZOffset");
            // PORT-NOTE: C# 中 entityZOffset 以 int 读取后隐式赋给 float 字段。
            if (zOffsetAttr != null) entityLaneZOffset = 0.0 + zOffsetAttr;

            var childNodes = gridsNode.ChildNodes;
            for (i in 0...childNodes.Count) {
                var childNode = childNodes.getAt(i);
                if (childNode.Name == "grid") {
                    var gridMeta = AreaGrid.FromXmlNode(childNode, defaultNsp);
                    if (gridMeta != null) {
                        grids.push(gridMeta);
                    }
                }
            }
        }
        var meta = new AreaMeta(id);
        meta.ModelID = model;
        meta.MusicID = music;
        meta.StarshardIcon = starshard;
        meta.Cart = cart;
        meta.Tags = tags;

        meta.EnemySpawnX = enemySpawnX;
        meta.DoorZ = doorZ;

        meta.BackgroundLight = backgroundLight;
        meta.GlobalLight = globalLight;

        meta.GridWidth = gridWidth;
        meta.GridHeight = gridHeight;
        meta.GridLeftX = leftX;
        meta.GridBottomZ = bottomZ;
        meta.EntityLaneZOffset = entityLaneZOffset;
        meta.Lanes = lanes;
        meta.Columns = columns;
        meta.Grids = grids;
        return meta;
    }
}
