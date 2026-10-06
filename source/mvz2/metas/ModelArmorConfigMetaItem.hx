// Ported from: Assets/Scripts/MVZ2/Metas/Model/ModelArmorConfigMeta.cs
package mvz2.metas;

import mvz2.io.XMLHelper;
import pvzengine.NamespaceID;
import system.xml.XmlNode;
import unity.Vector3;
using mvz2.io.XMLHelper;  // EXTUSING

class ModelArmorConfigMetaItem {
	public function new() { } // CTORFIX
    public var ArmorID(default, null):NamespaceID;
    public var ArmorType(default, null):NamespaceID;
    public var ArmorSlot(default, null):NamespaceID;
    public var Offset(default, null):Vector3;
    public var Anchor(default, null):String = "";

    public static function FromXmlNode(node:XmlNode, defaultNsp:String):ModelArmorConfigMetaItem {
        var id = XMLHelper.GetAttributeNamespaceID(node, "id", defaultNsp);
        var type = XMLHelper.GetAttributeNamespaceID(node, "type", defaultNsp);
        var slot = XMLHelper.GetAttributeNamespaceID(node, "slot", defaultNsp);
        var offsetNode = node["offset"];
        var offset = offsetNode != null ? XMLHelper.GetAttributeVector3(offsetNode) : null;
        if (offset == null) offset = Vector3.zero;
        var anchorNode = node["anchor"];
        var anchor = anchorNode != null ? anchorNode.InnerText : "";
        if (anchor == null) anchor = "";

        var item = new ModelArmorConfigMetaItem();
        item.ArmorID = id;
        item.ArmorType = type;
        item.ArmorSlot = slot;
        item.Offset = offset;
        item.Anchor = anchor;
        return item;
    }
}
