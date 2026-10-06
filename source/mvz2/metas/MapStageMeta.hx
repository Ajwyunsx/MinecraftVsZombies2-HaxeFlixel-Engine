// Ported from: Assets/Scripts/MVZ2/Metas/Map/MapMeta.cs
package mvz2.metas;

import mvz2.io.XMLHelper;
import pvzengine.Log;
import pvzengine.NamespaceID;
import system.xml.XmlNode;
using mvz2.io.XMLHelper;  // EXTUSING
using pvzengine.PropertyKeyHelper;  // EXTUSING

class MapStageMeta {
    public var stage:NamespaceID;
    public var area:NamespaceID;

    public function new(stage:NamespaceID, area:NamespaceID) {
        this.stage = stage;
        this.area = area;
    }

    public static function FromXmlNode(node:XmlNode, defaultNsp:String):MapStageMeta {
        var stage = XMLHelper.GetAttributeNamespaceID(node, "id", defaultNsp);
        if (!NamespaceID.IsValid(stage)) {
            Log.LogError('The stage of a MapStageMeta is invalid.');
            return null;
        }
        var area = XMLHelper.GetAttributeNamespaceID(node, "area", defaultNsp);
        return new MapStageMeta(stage, area);
    }
}
