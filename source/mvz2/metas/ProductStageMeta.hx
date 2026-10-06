// Ported from: Assets/Scripts/MVZ2/Metas/Product/ProductStageMeta.cs
package mvz2.metas;

import mvz2.io.XMLHelper;
import pvzengine.NamespaceID;
import system.xml.XmlNode;
using mvz2.io.XMLHelper;  // EXTUSING

class ProductStageMeta {
	public function new() { } // CTORFIX
    public var Text(default, null):String = "";
    public var Price(default, null):Int;
    public var Unlocks(default, null):NamespaceID;
    public var Conditions(default, null):XMLConditionList;
    public var Stats(default, null):Array<ProductStatMeta>;

    public static function FromXmlNode(node:XmlNode, defaultNsp:String):ProductStageMeta {
        var text = XMLHelper.GetAttribute(node, "text");
        if (text == null) text = "";
        var priceAttr = XMLHelper.GetAttributeInt(node, "price");
        var price = priceAttr != null ? priceAttr : 0;
        var unlocks = XMLHelper.GetAttributeNamespaceID(node, "unlocks", defaultNsp);

        var conditions:XMLConditionList = null;
        var conditionsNode = node["conditions"];
        if (conditionsNode != null) {
            conditions = XMLConditionList.FromXmlNode(conditionsNode, defaultNsp);
        }

        // Stats.
        var stats:Array<ProductStatMeta> = [];
        for (i in 0...node.ChildNodes.Count) {
            var childNode = node.ChildNodes.getAt(i);
            if (childNode.Name == "stat") {
                var stat = ProductStatMeta.FromXmlNode(childNode, defaultNsp);
                if (stat != null) {
                    stats.push(stat);
                }
            }
        }

        var meta = new ProductStageMeta();
        meta.Text = text;
        meta.Price = price;
        meta.Unlocks = unlocks;
        meta.Conditions = conditions;
        meta.Stats = stats;
        return meta;
    }
}
