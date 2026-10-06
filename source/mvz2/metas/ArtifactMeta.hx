// Ported from: Assets/Scripts/MVZ2/Metas/ArtifactMeta.cs
package mvz2.metas;

import mvz2.io.XMLHelper;
import mvz2logic.resources.SpriteReference;
import pvzengine.Log;
import pvzengine.NamespaceID;
import system.xml.XmlNode;
using mvz2.io.XMLHelper;  // EXTUSING

class ArtifactMeta {
    public var ID(default, null):String;
    public var Name(default, null):String = "";
    public var Tooltip(default, null):String = "";
    // [Obsolete]
    public var Unlock(default, null):NamespaceID;
    public var UnlockConditions(default, null):XMLConditionList;
    public var Sprite(default, null):SpriteReference;
    public var Order(default, null):Int;

    public function new(id:String) {
        ID = id;
    }

    public static function FromXmlNode(node:XmlNode, defaultNsp:String, order:Int):ArtifactMeta {
        var id = XMLHelper.GetAttribute(node, "id");
        if (id == null || id.length == 0) {
            Log.LogError("The ID of an ArtifactMeta is invalid.");
            return null;
        }
        var name = XMLHelper.GetAttribute(node, "name");
        if (name == null) name = "";
        var tooltip = XMLHelper.GetAttribute(node, "tooltip");
        if (tooltip == null) tooltip = "";
        var conditions = XMLHelper.GetUnlockConditionsOrObsolete(node, "unlock", "unlock", defaultNsp);
        var sprite = XMLHelper.GetAttributeSpriteReference(node, "sprite", defaultNsp);
        var meta = new ArtifactMeta(id);
        meta.Name = name;
        meta.Tooltip = tooltip;
        meta.UnlockConditions = conditions;
        meta.Order = order;
        meta.Sprite = sprite;
        return meta;
    }
}
