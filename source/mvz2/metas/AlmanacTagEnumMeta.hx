// Ported from: Assets/Scripts/MVZ2/Metas/Almanac/Tag/AlmanacTagEnumMeta.cs
package mvz2.metas;

import mvz2.io.XMLHelper;
import mvz2logic.ParseHelper.OutInt;  // SUBIMPORT
import mvz2logic.ParseHelper;
import pvzengine.NamespaceID;
import system.xml.XmlNode;
import unity.Debug;
using mvz2.io.XMLHelper;  // EXTUSING
using mvz2logic.ParseHelper;  // EXTUSING

class AlmanacTagEnumMeta {
    public function new(id:String) {
        this.id = id;
    }

    public var id:String;
    public var type:String = "int";
    public var values:Array<AlmanacTagEnumValueMeta>;

    public function FindValueByString(valueString:String, defaultNsp:String):AlmanacTagEnumValueMeta {
        if (values == null)
            return null;
        switch (type) {
            case "int":
                var outInt:OutInt = {value: 0};
                if (ParseHelper.TryParseInt(valueString, outInt)) {
                    var intValue = outInt.value;
                    for (e in values) {
                        if (intValue == e.value)
                            return e;
                    }
                }
            case "id":
                var outID:{value:NamespaceID} = {value: null};
                if (NamespaceID.TryParse(valueString, defaultNsp, outID)) {
                    var idValue = outID.value;
                    for (e in values) {
                        if (idValue == e.value)
                            return e;
                    }
                }
            default:
        }
        return null;
    }
    public static function FromXmlNode(node:XmlNode, defaultNsp:String):AlmanacTagEnumMeta {
        var id = XMLHelper.GetAttribute(node, "id");
        if (id == null || id.length == 0) {
            Debug.LogError("The ID of an AlmanacTagEnumMeta is invalid.");
            return null;
        }
        var type = XMLHelper.GetAttribute(node, "type");
        if (type == null) type = "int";

        var values:Array<AlmanacTagEnumValueMeta> = [];
        for (i in 0...node.ChildNodes.Count) {
            var childNode = node.ChildNodes.getAt(i);
            var value = AlmanacTagEnumValueMeta.FromXmlNode(childNode, type, defaultNsp);
            values.push(value);
        }

        var meta = new AlmanacTagEnumMeta(id);
        meta.type = type;
        meta.values = values;
        return meta;
    }
}
