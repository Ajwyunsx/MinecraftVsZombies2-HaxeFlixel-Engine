// Ported from: Assets/Scripts/MVZ2/Metas/Blueprint/BlueprintStyleMeta.cs
package mvz2.metas;

import mvz2.io.XMLHelper;
import mvz2logic.resources.SpriteReference;
import pvzengine.Log;
import system.xml.XmlNode;
using mvz2.io.XMLHelper;  // EXTUSING

class BlueprintStyleMeta {
    public function new(id:String) {
        ID = id;
    }

    public var ID(default, null):String;
    public var StandaloneBackground(default, null):SpriteReference;
    public var MobileBackground(default, null):SpriteReference;
    public var MobileFrameTop(default, null):SpriteReference;
    public var MobileFrameBottom(default, null):SpriteReference;
    public static function FromXmlNode(node:XmlNode, defaultNsp:String):BlueprintStyleMeta {
        var id = XMLHelper.GetAttribute(node, "id");
        if (id == null || id.length == 0) {
            Log.LogError("The ID of a BlueprintStyleMeta is invalid.");
            return null;
        }
        var standaloneNode = node.GetChildNode("standalone");
        var standaloneBackground = standaloneNode != null ? XMLHelper.GetAttributeSpriteReference(standaloneNode, "background", defaultNsp) : null;

        var mobileNode = node.GetChildNode("mobile");
        var mobileBackground = mobileNode != null ? XMLHelper.GetAttributeSpriteReference(mobileNode, "background", defaultNsp) : null;
        var mobileFrameTop = mobileNode != null ? XMLHelper.GetAttributeSpriteReference(mobileNode, "frameTop", defaultNsp) : null;
        var mobileFrameBottom = mobileNode != null ? XMLHelper.GetAttributeSpriteReference(mobileNode, "frameBottom", defaultNsp) : null;
        var meta = new BlueprintStyleMeta(id);
        meta.StandaloneBackground = standaloneBackground;
        meta.MobileBackground = mobileBackground;
        meta.MobileFrameTop = mobileFrameTop;
        meta.MobileFrameBottom = mobileFrameBottom;
        return meta;
    }
}
