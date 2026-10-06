// Ported from: Assets/Scripts/MVZ2/Metas/Blueprint/BlueprintMetaIcon.cs
package mvz2.metas;

import mvz2.io.XMLHelper;
import mvz2logic.resources.SpriteReference;
import pvzengine.NamespaceID;
import system.xml.XmlNode;
using mvz2.io.XMLHelper;  // EXTUSING
using pvzengine.PropertyKeyHelper;  // EXTUSING

class BlueprintMetaIcon {
    public var Mobile(default, null):SpriteReference;
    public var Sprite(default, null):SpriteReference;
    public var ModelID(default, null):NamespaceID;
    public function new(node:XmlNode, defaultNsp:String, blueprintID:NamespaceID) {
        var mobile = XMLHelper.GetAttributeSpriteReference(node, "mobile", defaultNsp);
        if (!SpriteReference.IsValid(mobile)) {
            var id = new NamespaceID(blueprintID.SpaceName, 'mobile_blueprint/${blueprintID.Path}');
            mobile = new SpriteReference(id);
        }
        Mobile = mobile;
        Sprite = XMLHelper.GetAttributeSpriteReference(node, "sprite", defaultNsp);
        ModelID = XMLHelper.GetAttributeNamespaceID(node, "model", defaultNsp);
    }
}
