// Ported from: Assets/Scripts/MVZ2/Metas/Model/ModelMeta.cs
package mvz2.metas;

import mvz2.io.XMLHelper;
import pvzengine.NamespaceID;
import system.xml.XmlNode;
using mvz2.io.XMLHelper;  // EXTUSING

class ModelMeta {
    public function new(animatorParameters:Array<AnimatorParameter>, modelProperties:Map<String, Dynamic>) {
        AnimatorParameters = animatorParameters;
        ModelProperties = modelProperties;
    }

    public var Name(default, null):String = "";
    public var Type(default, null):String = "";
    public var Path(default, null):NamespaceID;
    public var Shot(default, null):Bool;
    public var Width(default, null):Int;
    public var Height(default, null):Int;
    public var XOffset(default, null):Float;
    public var YOffset(default, null):Float;
    public var ArmorConfigID(default, null):NamespaceID;
    public var AnimatorParameters(default, null):Array<AnimatorParameter>;
    public var UpdateAnimatorOnShot(default, null):Bool;
    public var ModelProperties(default, null):Map<String, Dynamic>;

    public static function FromXmlNode(node:XmlNode, defaultNsp:String):ModelMeta {
        var name = XMLHelper.GetAttribute(node, "name");
        if (name == null) name = "";
        var type = XMLHelper.GetAttribute(node, "type");
        if (type == null) type = "";
        var path = XMLHelper.GetAttributeNamespaceID(node, "path", defaultNsp);
        var shotAttr = XMLHelper.GetAttributeBool(node, "shot");
        var shot = shotAttr != null ? shotAttr : true;
        var widthAttr = XMLHelper.GetAttributeInt(node, "width");
        var width = widthAttr != null ? widthAttr : 64;
        var heightAttr = XMLHelper.GetAttributeInt(node, "height");
        var height = heightAttr != null ? heightAttr : 64;
        var xOffsetAttr = XMLHelper.GetAttributeFloat(node, "xOffset");
        var xOffset = xOffsetAttr != null ? xOffsetAttr : 0;
        var yOffsetAttr = XMLHelper.GetAttributeFloat(node, "yOffset");
        var yOffset = yOffsetAttr != null ? yOffsetAttr : 0;

        var armorConfigID:NamespaceID = null;
        var armorConfigNode = node["armorconfig"];
        if (armorConfigNode != null) {
            var parsed:{value:NamespaceID} = {value: null};
            if (NamespaceID.TryParse(armorConfigNode.InnerText, defaultNsp, parsed)) {
                armorConfigID = parsed.value;
            }
        }

        var animatorParameters:Array<AnimatorParameter> = [];
        var updateAnimatorOnShot = false;
        var animatorNode = node["animator"];
        if (animatorNode != null) {
            var updateAttr = XMLHelper.GetAttributeBool(animatorNode, "updateOnShot");
            if (updateAttr != null) updateAnimatorOnShot = updateAttr;
            var parametersNode = animatorNode["parameters"];
            if (parametersNode != null) {
                for (i in 0...parametersNode.ChildNodes.Count) {
                    var child = parametersNode.ChildNodes.getAt(i);
                    var param = AnimatorParameter.FromXmlNode(child, defaultNsp);
                    if (param != null) {
                        animatorParameters.push(param);
                    }
                }
            }
        }
        var modelProperties = XMLHelper.ToPropertyDictionary(node["properties"], defaultNsp);
        var meta = new ModelMeta(animatorParameters, modelProperties);
        meta.Name = name;
        meta.Type = type;
        meta.Shot = shot;
        meta.Path = path;
        meta.Width = width;
        meta.Height = height;
        meta.XOffset = xOffset;
        meta.YOffset = yOffset;
        meta.ArmorConfigID = armorConfigID;
        meta.UpdateAnimatorOnShot = updateAnimatorOnShot;
        return meta;
    }
    public function toString():String {
        return Name;
    }
}
