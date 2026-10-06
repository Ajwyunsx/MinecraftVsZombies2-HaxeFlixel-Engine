// Ported from: Assets/Scripts/MVZ2/Metas/Shapes/ShapeMeta.cs
package mvz2.metas;

import mvz2.io.XMLHelper;
import pvzengine.NamespaceID;
import system.xml.XmlNode;
import unity.Vector3;
using mvz2.io.XMLHelper;  // EXTUSING

class ShapeArmorMetaItem {
	public function new() { } // CTORFIX
    public var ArmorID(default, null):NamespaceID;
    public var ArmorType(default, null):NamespaceID;
    public var ArmorSlot(default, null):NamespaceID;
    public var Position(default, null):Vector3;
    public var Scale(default, null):Vector3;

    public static function FromXmlNode(node:XmlNode, defaultNsp:String):ShapeArmorMetaItem {
        var id = XMLHelper.GetAttributeNamespaceID(node, "id", defaultNsp);
        var type = XMLHelper.GetAttributeNamespaceID(node, "type", defaultNsp);
        var slot = XMLHelper.GetAttributeNamespaceID(node, "slot", defaultNsp);
        var positionNode = node["position"];
        var position = positionNode != null ? XMLHelper.GetAttributeVector3(positionNode) : null;
        if (position == null) position = Vector3.zero;
        var scaleNode = node["scale"];
        var scale = scaleNode != null ? XMLHelper.GetAttributeVector3(scaleNode) : null;
        if (scale == null) scale = Vector3.one;

        var item = new ShapeArmorMetaItem();
        item.ArmorID = id;
        item.ArmorType = type;
        item.ArmorSlot = slot;
        item.Position = position;
        item.Scale = scale;
        return item;
    }
}
