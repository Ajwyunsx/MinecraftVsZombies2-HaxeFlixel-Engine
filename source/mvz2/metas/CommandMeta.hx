// Ported from: Assets/Scripts/MVZ2/Metas/Command/CommandMeta.cs
package mvz2.metas;

import mvz2.io.XMLHelper;
import pvzengine.Log;
import system.xml.XmlNode;
using mvz2.io.XMLHelper;  // EXTUSING

class CommandMeta {
    public var ID(default, null):String;
    public var Description(default, null):String = "";
    public var InLevel(default, null):Bool;
    public var Variants(default, null):Array<CommandMetaVariant>;

    private function new(id:String, variants:Array<CommandMetaVariant>) {
        ID = id;
        Variants = variants;
    }
    public static function FromXmlNode(node:XmlNode, defaultNsp:String):CommandMeta {
        var id = XMLHelper.GetAttribute(node, "id");
        if (id == null || id.length == 0) {
            Log.LogError("The ID of a CommandMeta is invalid.");
            return null;
        }
        var inLevelAttr = XMLHelper.GetAttributeBool(node, "inLevel");
        var inLevel = inLevelAttr != null ? inLevelAttr : false;
        var descriptionNode = node["description"];
        var description = descriptionNode != null ? descriptionNode.InnerText : "";
        var variants:Array<CommandMetaVariant> = [];
        for (i in 0...node.ChildNodes.Count) {
            var childNode = node.ChildNodes.getAt(i);
            if (childNode.Name == "variant") {
                variants.push(CommandMetaVariant.FromXmlNode(childNode, defaultNsp));
            }
        }
        var meta = new CommandMeta(id, variants);
        meta.InLevel = inLevel;
        meta.Description = description;
        return meta;
    }
}
