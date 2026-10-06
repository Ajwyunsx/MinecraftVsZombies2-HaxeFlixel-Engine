// Ported from: Assets/Scripts/MVZ2/Metas/Shapes/ShapeMeta.cs
package mvz2.metas;

import mvz2.io.XMLHelper;
import pvzengine.Log;
import system.xml.XmlNode;
using mvz2.io.XMLHelper;  // EXTUSING

class ShapeMeta {
    private function new(iD:String) {
        ID = iD;
    }

    public var ID(default, null):String;
    public var Armors(default, null):ShapeArmorMeta;

    public static function FromXmlNode(node:XmlNode, defaultNsp:String):ShapeMeta {
        var id = XMLHelper.GetAttribute(node, "id");
        if (id == null || id.length == 0) {
            Log.LogError('The id of a ShapeMeta is invalid.');
            return null;
        }
        var armors:ShapeArmorMeta = null;
        for (i in 0...node.ChildNodes.Count) {
            var child = node.ChildNodes.getAt(i);
            if (child.Name == "armors") {
                armors = ShapeArmorMeta.FromXmlNode(child, defaultNsp);
            }
        }
        var meta = new ShapeMeta(id);
        meta.Armors = armors;
        return meta;
    }
}
