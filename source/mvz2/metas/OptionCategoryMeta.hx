// Ported from: Assets/Scripts/MVZ2/Metas/Options/OptionCategoryMeta.cs
package mvz2.metas;

import mvz2.io.XMLHelper;
import pvzengine.Log;
import system.xml.XmlNode;
using mvz2.io.XMLHelper;  // EXTUSING

class OptionCategoryMeta {
    public var ID(default, null):String;
    public var Label(default, null):String = "";

    public function new(iD:String) {
        ID = iD;
    }
    public static function FromXmlNode(node:XmlNode, defaultNsp:String):OptionCategoryMeta {
        var id = XMLHelper.GetAttribute(node, "id");
        if (id == null || id.length == 0) {
            Log.LogError('The id of a OptionCategoryMeta is invalid.');
            return null;
        }
        var label = XMLHelper.GetAttribute(node, "label");
        if (label == null) label = "";
        var meta = new OptionCategoryMeta(id);
        meta.Label = label;
        return meta;
    }
}
