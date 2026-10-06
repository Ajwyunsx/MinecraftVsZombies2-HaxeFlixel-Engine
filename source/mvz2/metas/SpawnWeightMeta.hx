// Ported from: Assets/Scripts/MVZ2/Metas/Spawns/SpawnMeta.cs
package mvz2.metas;

import mvz2.io.XMLHelper;
import system.xml.XmlNode;
using mvz2.io.XMLHelper;  // EXTUSING

class SpawnWeightMeta {
	public function new() { } // CTORFIX
    public var Base(default, null):Int;
    public var DecreaseStart(default, null):Int;
    public var DecreaseEnd(default, null):Int;
    public var DecreasePerFlag(default, null):Int;

    public static function FromXmlNode(node:XmlNode):SpawnWeightMeta {
        var baseAttr = XMLHelper.GetAttributeInt(node, "base");
        var baseValue = baseAttr != null ? baseAttr : 0;
        var startAttr = XMLHelper.GetAttributeInt(node, "decreaseStart");
        var start = startAttr != null ? startAttr : 0;
        var endAttr = XMLHelper.GetAttributeInt(node, "decreaseEnd");
        var end = endAttr != null ? endAttr : 0;
        var perFlagAttr = XMLHelper.GetAttributeInt(node, "decreasePerFlag");
        var perFlag = perFlagAttr != null ? perFlagAttr : 0;
        var meta = new SpawnWeightMeta();
        meta.Base = baseValue;
        meta.DecreaseStart = start;
        meta.DecreaseEnd = end;
        meta.DecreasePerFlag = perFlag;
        return meta;
    }
}
