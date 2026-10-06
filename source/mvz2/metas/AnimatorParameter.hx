// Ported from: Assets/Scripts/MVZ2/Metas/Model/ModelMeta.cs
package mvz2.metas;

import mvz2.io.XMLHelper;
import mvz2.models.Model;
import pvzengine.Log;
import system.xml.XmlNode;
import unity.AnimatorControllerParameterType;
using mvz2.io.XMLHelper;  // EXTUSING

class AnimatorParameter {
    public function new(name:String) {
        Name = name;
    }

    public var Name:String;
    public var Type:AnimatorControllerParameterType;
    public var BoolValue:Bool;
    public var IntValue:Int;
    public var FloatValue:Float;

    public static function FromXmlNode(node:XmlNode, defaultNsp:String):AnimatorParameter {
        var typeName = node.Name;
        var name = XMLHelper.GetAttribute(node, "name");
        if (name == null || name.length == 0) {
            Log.LogError("The Name of an AnimatorParameter is invalid.");
            return null;
        }
        switch (typeName) {
            case "trigger":
                {
                    var param = new AnimatorParameter(name);
                    param.Type = AnimatorControllerParameterType.Trigger;
                    return param;
                }
            case "bool":
                {
                    var param = new AnimatorParameter(name);
                    param.Type = AnimatorControllerParameterType.Bool;
                    var boolValueAttr = XMLHelper.GetAttributeBool(node, "value");
                    param.BoolValue = boolValueAttr != null ? boolValueAttr : false;
                    return param;
                }
            case "int":
                {
                    var param = new AnimatorParameter(name);
                    param.Type = AnimatorControllerParameterType.Int;
                    var intValueAttr = XMLHelper.GetAttributeInt(node, "value");
                    param.IntValue = intValueAttr != null ? intValueAttr : 0;
                    return param;
                }
            case "float":
                {
                    var param = new AnimatorParameter(name);
                    param.Type = AnimatorControllerParameterType.Float;
                    var floatValueAttr = XMLHelper.GetAttributeFloat(node, "value");
                    param.FloatValue = floatValueAttr != null ? floatValueAttr : 0;
                    return param;
                }
            default:
        }
        throw 'Could not create an AnimatorParameter with type ${typeName}.';
    }
    public function Apply(model:Model):Void {
        switch (Type) {
            case AnimatorControllerParameterType.Trigger:
                model.TriggerAnimator(Name);
            case AnimatorControllerParameterType.Bool:
                model.SetAnimatorBool(Name, BoolValue);
            case AnimatorControllerParameterType.Int:
                model.SetAnimatorInt(Name, IntValue);
            case AnimatorControllerParameterType.Float:
                model.SetAnimatorFloat(Name, FloatValue);
            default:
        }
    }
}
