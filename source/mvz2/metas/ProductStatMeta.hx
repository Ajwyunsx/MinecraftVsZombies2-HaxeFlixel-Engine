// Ported from: Assets/Scripts/MVZ2/Metas/Product/ProductStageMeta.cs
package mvz2.metas;

import haxe.Int64;
import mvz2.io.XMLHelper;
import pvzengine.NamespaceID;
import system.xml.XmlNode;
using mvz2.io.XMLHelper;  // EXTUSING
using pvzengine.PropertyKeyHelper;  // EXTUSING

class ProductStatMeta {
	public function new() { } // CTORFIX
    public var Category(default, null):NamespaceID;
    public var Entry(default, null):NamespaceID;
    public var Value(default, null):Int64;

    public static function FromXmlNode(node:XmlNode, defaultNsp:String):ProductStatMeta {
        var category = XMLHelper.GetAttributeNamespaceID(node, "category", defaultNsp);
        var entry = XMLHelper.GetAttributeNamespaceID(node, "entry", defaultNsp);
        if (!NamespaceID.IsValid(entry))
            return null;
        var valueAttr = XMLHelper.GetAttributeLong(node, "value");
        var value = valueAttr != null ? valueAttr : Int64.ofInt(0);
        var meta = new ProductStatMeta();
        meta.Category = category;
        meta.Entry = entry;
        meta.Value = value;
        return meta;
    }
}
