// Ported from: Assets/Scripts/MVZ2/Metas/TalkCharacterMeta.cs
package mvz2.metas;

import mvz2.io.XMLHelper;
import pvzengine.Log;
import pvzengine.NamespaceID;
import system.xml.XmlNode;
import unity.Vector2;
using mvz2.io.XMLHelper;  // EXTUSING
using pvzengine.PropertyKeyHelper;  // EXTUSING

class TalkCharacterVariantTemplate {
    public var id:NamespaceID;
    public var parent:NamespaceID;
    public var unlock:XMLConditionList;
    public var width:Null<Int>;
    public var height:Null<Int>;
    public var pivotX:Null<Float>;
    public var pivotY:Null<Float>;
    public var extendLeft:Null<Float>;
    public var extendRight:Null<Float>;
    public var layers:Array<TalkCharacterLayer> = [];

    public function new(id:NamespaceID) {
        this.id = id;
    }

    public static function FromXmlNode(node:XmlNode, defaultNsp:String):TalkCharacterVariantTemplate {
        var id = XMLHelper.GetAttributeNamespaceID(node, "id", defaultNsp);
        if (!NamespaceID.IsValid(id)) {
            Log.LogError('The id of a TalkCharacterVariantTemplate is invalid.');
            return null;
        }
        var variant = new TalkCharacterVariantTemplate(id);
        variant.parent = XMLHelper.GetAttributeNamespaceID(node, "parent", defaultNsp);

        variant.width = XMLHelper.GetAttributeInt(node, "width");
        variant.height = XMLHelper.GetAttributeInt(node, "height");
        variant.extendLeft = XMLHelper.GetAttributeFloat(node, "extendLeft");
        variant.extendRight = XMLHelper.GetAttributeFloat(node, "extendRight");
        variant.pivotX = XMLHelper.GetAttributeFloat(node, "pivotX");
        variant.pivotY = XMLHelper.GetAttributeFloat(node, "pivotY");

        variant.unlock = XMLHelper.GetUnlockConditionsOrObsolete(node, "unlock", "unlock", defaultNsp);

        var variantChildNodes = node.ChildNodes;
        for (i in 0...variantChildNodes.Count) {
            var child = variantChildNodes.getAt(i);
            if (child.Name == "layer") {
                variant.layers.push(TalkCharacterLayer.FromXmlNode(child, defaultNsp));
            }
        }
        return variant;
    }
    public function ToVariant(templates:Array<TalkCharacterVariantTemplate>):TalkCharacterVariant {
        var result = new TalkCharacterVariant(id);
        var visited:Array<TalkCharacterVariantTemplate> = [];
        GetCharacterVariantProperties(templates, result, visited);
        result.unlock = unlock;
        return result;
    }
    // PORT-NOTE: C# `Stack<T>` 作为递归访问栈 → Haxe Array（push/pop/indexOf），语义等价。
    private function GetCharacterVariantProperties(templatePool:Array<TalkCharacterVariantTemplate>, result:TalkCharacterVariant, visited:Array<TalkCharacterVariantTemplate>):Void {
        if (visited.indexOf(this) >= 0)
            throw 'A recursion exception has been occured while loading talk character ${id} from talkcharacter.xml, maybe a cycle parent reference is present.';
        visited.push(this);
        var parentID = parent;
        if (NamespaceID.IsValid(parentID)) {
            var parent:TalkCharacterVariantTemplate = null;
            for (t in templatePool) {
                if (t.id == parentID) {
                    parent = t;
                    break;
                }
            }
            if (parent != null) {
                parent.GetCharacterVariantProperties(templatePool, result, visited);
            }
        }
        visited.pop();
        if (pivotX != null) result.pivotX = pivotX;
        if (pivotY != null) result.pivotY = pivotY;
        if (width != null) result.width = width;
        if (height != null) result.height = height;
        result.widthExtend = new Vector2(extendLeft != null ? extendLeft : result.widthExtend.x,
            extendRight != null ? extendRight : result.widthExtend.y);
        for (layer in layers) result.layers.push(layer);
    }
}
