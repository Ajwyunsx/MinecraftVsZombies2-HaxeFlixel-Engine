// Ported from: Assets/Scripts/MVZ2/Metas/FragmentMeta.cs
package mvz2.metas;

import mvz2.io.XMLHelper;
import pvzengine.Log;
import system.xml.XmlNode;
import unity.Gradient;
using mvz2.io.XMLHelper;  // EXTUSING

class FragmentMeta {
    public function new(iD:String, gradient:Gradient) {
        ID = iD;
        Gradient = gradient;
    }

    public var ID(default, null):String;
    public var Gradient(default, null):Gradient;
    public static function FromXmlNode(node:XmlNode):FragmentMeta {
        var name = XMLHelper.GetAttribute(node, "name");
        if (name == null || name.length == 0) {
            Log.LogError('The name of a FragmentMeta is invalid.');
            return null;
        }
        return new FragmentMeta(name, XMLHelper.ToGradient(node));
    }
}
