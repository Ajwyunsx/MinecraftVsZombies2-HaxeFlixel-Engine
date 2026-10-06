// Ported from: Assets/Scripts/MVZ2/Metas/TalkCharacterMeta.cs
package mvz2.metas;

import mvz2.io.XMLHelper;
import pvzengine.Log;
import pvzengine.NamespaceID;
import system.xml.XmlNode;
using mvz2.io.XMLHelper;  // EXTUSING

class TalkCharacterMeta {
    public var id:String;
    public var name:String = "";
    public var faceRight:Bool = false;
    // [Obsolete]
    public var unlockCondition:NamespaceID;
    public var variants:Array<TalkCharacterVariant> = [];

    public function new(id:String) {
        this.id = id;
    }

    public function GetFirstVariant():TalkCharacterVariant {
        return variants.length > 0 ? variants[0] : null;
    }
    public function GetVariant(id:NamespaceID):TalkCharacterVariant {
        for (v in variants) {
            if (v.id == id)
                return v;
        }
        return null;
    }
    public static function FromXmlNode(node:XmlNode, defaultNsp:String):TalkCharacterMeta {
        var id = XMLHelper.GetAttribute(node, "id");
        if (id == null || id.length == 0) {
            Log.LogError('The id of a TalkCharacterMeta is invalid.');
            return null;
        }
        var meta = new TalkCharacterMeta(id);
        var name = XMLHelper.GetAttribute(node, "name");
        meta.name = name != null ? name : "";
        var faceRightAttr = XMLHelper.GetAttributeBool(node, "faceRight");
        meta.faceRight = faceRightAttr != null ? faceRightAttr : false;

        var variantTemplates:Array<TalkCharacterVariantTemplate> = [];
        var variantChildNodes = node.ChildNodes;
        for (i in 0...variantChildNodes.Count) {
            var child = variantChildNodes.getAt(i);
            if (child.Name == "variant") {
                var template = TalkCharacterVariantTemplate.FromXmlNode(child, defaultNsp);
                if (template != null)
                    variantTemplates.push(template);
            }
        }
        for (template in variantTemplates) {
            meta.variants.push(template.ToVariant(variantTemplates));
        }
        return meta;
    }
}
