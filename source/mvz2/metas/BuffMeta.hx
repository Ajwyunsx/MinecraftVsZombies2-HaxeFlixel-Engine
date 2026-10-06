// Ported from: Assets/Scripts/MVZ2/Metas/Buff/BuffMeta.cs
package mvz2.metas;

import mvz2.io.XMLHelper;
import pvzengine.Log;
import pvzengine.buffs.BuffPolarity;
import system.xml.XmlNode;
using mvz2.io.XMLHelper;  // EXTUSING

class BuffMeta {
    public var ID(default, null):String;
    public var Polarity(default, null):Int;
    public var Level(default, null):Int;

    public function new(iD:String) {
        ID = iD;
    }
    public static function FromXmlNode(node:XmlNode, defaultNsp:String):BuffMeta {
        var id = XMLHelper.GetAttribute(node, "id");
        if (id == null || id.length == 0) {
            Log.LogError("The ID of a BuffMeta is invalid");
            return null;
        }
        var polarity = GetPolarity(XMLHelper.GetAttribute(node, "polarity"));
        var levelAttr = XMLHelper.GetAttributeInt(node, "level");
        var level = levelAttr != null ? levelAttr : 9;
        var meta = new BuffMeta(id);
        meta.Polarity = polarity;
        meta.Level = level;
        return meta;
    }
    private static function GetPolarity(str:String):Int {
        if (str != null && str.length > 0) {
            if (polarityDict.exists(str)) {
                return polarityDict.get(str);
            }
        }
        return BuffPolarity.UTILITY;
    }
    public function toString():String {
        return ID;
    }
    private static var polarityDict:Map<String, Int> = [
        "positive" => BuffPolarity.POSITIVE,
        "negative" => BuffPolarity.NEGATIVE,
        "mixed" => BuffPolarity.MIXED,
    ];
}
