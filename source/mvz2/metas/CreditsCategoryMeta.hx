// Ported from: Assets/Scripts/MVZ2/Metas/Credits/CreditsCategoryMeta.cs
package mvz2.metas;

import mvz2.io.XMLHelper;
import pvzengine.Log;
import system.xml.XmlNode;
using mvz2.io.XMLHelper;  // EXTUSING

class CreditsCategoryMeta {
    public function new(name:String, entries:Array<String>) {
        Name = name;
        Entries = entries;
    }

    public var Name(default, null):String;
    public var Entries(default, null):Array<String>;
    public static function FromXmlNode(node:XmlNode, defaultNsp:String):CreditsCategoryMeta {
        var name = XMLHelper.GetAttribute(node, "name");
        if (name == null || name.length == 0) {
            Log.LogError('The name of a CreditsCategoryMeta is invalid.');
            return null;
        }

        var entries:Array<String> = [];
        for (i in 0...node.ChildNodes.Count) {
            var child = node.ChildNodes.getAt(i);
            if (child.Name == "entry") {
                entries.push(child.InnerText);
            }
        }
        return new CreditsCategoryMeta(name, entries);
    }
}
