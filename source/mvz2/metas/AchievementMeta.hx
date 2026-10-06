// Ported from: Assets/Scripts/MVZ2/Metas/AchievementMeta.cs
package mvz2.metas;

import mvz2.io.XMLHelper;
import mvz2logic.resources.SpriteReference;
import pvzengine.Log;
import system.xml.XmlNode;
using mvz2.io.XMLHelper;  // EXTUSING

class AchievementMeta {
    public function new(id:String) {
        ID = id;
    }

    public var ID(default, null):String;
    public var Name(default, null):String = "";
    public var Description(default, null):String = "";
    public var Icon(default, null):SpriteReference;
    public var Unlock(default, null):XMLConditionList;
    public static function FromXmlNode(node:XmlNode, defaultNsp:String):AchievementMeta {
        var id = XMLHelper.GetAttribute(node, "id");
        if (id == null || id.length == 0) {
            Log.LogError("The ID of an AchievementMeta is invalid.");
            return null;
        }
        var name = XMLHelper.GetAttribute(node, "name");
        if (name == null) name = "";
        var description = XMLHelper.GetAttribute(node, "description");
        if (description == null) description = "";
        var icon = XMLHelper.GetAttributeSpriteReference(node, "icon", defaultNsp);
        var unlock = XMLHelper.GetUnlockConditionsOrObsolete(node, "unlock", "unlock", defaultNsp);
        var meta = new AchievementMeta(id);
        meta.Name = name;
        meta.Description = description;
        meta.Icon = icon;
        meta.Unlock = unlock;
        return meta;
    }
}
