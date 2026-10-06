// Ported from: Assets/Scripts/MVZ2/Metas/Almanac/AlmanacMetaEntry.cs
package mvz2.metas;

import mvz2.io.XMLHelper;
import system.xml.XmlNode;
using mvz2.io.XMLHelper;  // EXTUSING

class AlmanacMetaFlavor {
	public function new() { } // CTORFIX
    public var conditions:XMLConditionList;
    public var text:String = "";

    public static function FromXmlNode(node:XmlNode, defaultNsp:String):AlmanacMetaFlavor {
        var conditions:XMLConditionList = null;
        var conditionsNode = node["conditions"];
        if (conditionsNode != null) {
            conditions = XMLConditionList.FromXmlNode(conditionsNode, defaultNsp);
        }
        var flavor = XMLHelper.ConcatNodeParagraphs(node);
        var meta = new AlmanacMetaFlavor();
        meta.conditions = conditions;
        meta.text = flavor;
        return meta;
    }
}
