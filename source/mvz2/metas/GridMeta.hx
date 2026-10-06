// Ported from: Assets/Scripts/MVZ2/Metas/Grids/GridMeta.cs
package mvz2.metas;

import mvz2.io.XMLHelper;
import mvz2logic.resources.SpriteReference;
import pvzengine.Log;
import system.xml.XmlNode;
using mvz2.io.XMLHelper;  // EXTUSING

class GridMeta {
    public function new(iD:String) {
        ID = iD;
    }

    public var ID(default, null):String;
    public var Slope(default, null):Float;
    public var OverlaySprite(default, null):SpriteReference;

    public static function FromXmlNode(node:XmlNode, defaultNsp:String):GridMeta {
        var id = XMLHelper.GetAttribute(node, "id");
        if (id == null || id.length == 0) {
            Log.LogError('The id of a GridMeta is invalid.');
            return null;
        }
        var slopeAttr = XMLHelper.GetAttributeFloat(node, "slope");
        var slope = slopeAttr != null ? slopeAttr : 0.0;
        var overlaySprite = XMLHelper.GetAttributeSpriteReference(node, "overlaySprite", defaultNsp);
        var meta = new GridMeta(id);
        meta.Slope = slope;
        meta.OverlaySprite = overlaySprite;
        return meta;
    }
}
