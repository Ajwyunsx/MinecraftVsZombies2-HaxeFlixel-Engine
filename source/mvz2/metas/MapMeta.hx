// Ported from: Assets/Scripts/MVZ2/Metas/Map/MapMeta.cs
package mvz2.metas;

import mvz2.io.XMLHelper;
import pvzengine.Log;
import pvzengine.NamespaceID;
import system.xml.XmlNode;
import unity.Vector2;
using mvz2.io.XMLHelper;  // EXTUSING

class MapMeta {
    public var id:String;
    public var size:Vector2 = new Vector2(0, 0); // PORT-NOTE: C# Vector2 为 struct，默认 (0,0)；显式初始化避免 abstract-over-class 的 null 解引用
    public var area:NamespaceID;
    public var loreTalks:LoreTalkMetaList;
    public var presets:Array<MapPreset>;
    public var stages:Array<MapStageMeta>;
    public var endlessStage:NamespaceID;

    private function new(id:String, presets:Array<MapPreset>, stages:Array<MapStageMeta>) {
        this.id = id;
        this.presets = presets;
        this.stages = stages;
    }

    public static function FromXmlNode(node:XmlNode, defaultNsp:String):MapMeta {
        var id = XMLHelper.GetAttribute(node, "id");
        if (id == null || id.length == 0) {
            Log.LogError('The id of a MapMeta is invalid.');
            return null;
        }
        var area = XMLHelper.GetAttributeNamespaceID(node, "area", defaultNsp);
        var widthAttr = XMLHelper.GetAttributeFloat(node, "width");
        var width = widthAttr != null ? widthAttr : 4080.0;
        var heightAttr = XMLHelper.GetAttributeFloat(node, "height");
        var height = heightAttr != null ? heightAttr : 2400.0;
        var size = new Vector2(width, height);

        var presetsNode = node["presets"];
        var presets:Array<MapPreset> = [];
        if (presetsNode != null) {
            for (i in 0...presetsNode.ChildNodes.Count) {
                var meta = MapPreset.FromXmlNode(presetsNode.ChildNodes.getAt(i), defaultNsp);
                if (meta != null)
                    presets.push(meta);
            }
        }

        var loreTalks = LoreTalkMetaList.FromXmlNode(node["talks"], defaultNsp);

        var stagesNode = node["stages"];
        var stages:Array<MapStageMeta> = [];
        var endlessStage:NamespaceID = null;
        if (stagesNode != null) {
            endlessStage = XMLHelper.GetAttributeNamespaceID(stagesNode, "endless", defaultNsp);
            for (i in 0...stagesNode.ChildNodes.Count) {
                var meta = MapStageMeta.FromXmlNode(stagesNode.ChildNodes.getAt(i), defaultNsp);
                if (meta != null)
                    stages.push(meta);
            }
        }
        var mapMeta = new MapMeta(id, presets, stages);
        mapMeta.size = size;
        mapMeta.area = area;
        mapMeta.loreTalks = loreTalks;
        mapMeta.endlessStage = endlessStage;
        return mapMeta;
    }
}
