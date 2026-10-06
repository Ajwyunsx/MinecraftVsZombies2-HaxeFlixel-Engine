// Ported from: Assets/Scripts/MVZ2/Metas/Arcade/ArcadeMeta.cs
package mvz2.metas;

import mvz2.io.XMLHelper;
import mvz2logic.resources.SpriteReference;
import pvzengine.NamespaceID;
import system.xml.XmlNode;
using mvz2.io.XMLHelper;  // EXTUSING

class ArcadeMeta {
	public function new() { } // CTORFIX
    public var ID(default, null):String;
    public var Type(default, null):String = "";
    public var Index(default, null):Int;
    public var AreaID(default, null):NamespaceID;
    public var StageID(default, null):NamespaceID;
    public var Icon(default, null):SpriteReference;
    public var HiddenUntil(default, null):XMLConditionList;

    public static function FromXmlNode(node:XmlNode, defaultNsp:String, index:Int):ArcadeMeta {
        var id = XMLHelper.GetAttribute(node, "id");
        if (id == null) id = "";
        var type = node.Name;
        var area = XMLHelper.GetAttributeNamespaceID(node, "area", defaultNsp);
        var stage = XMLHelper.GetAttributeNamespaceID(node, "stage", defaultNsp);
        var icon = XMLHelper.GetAttributeSpriteReference(node, "icon", defaultNsp);
        var hiddenUntil:XMLConditionList = null;
        var hiddenUntilNode = node["hiddenUntil"];
        if (hiddenUntilNode != null) {
            hiddenUntil = XMLConditionList.FromXmlNode(hiddenUntilNode, defaultNsp);
        } else {
            var hiddenUntilArray = XMLHelper.GetAttributeNamespaceIDArray(node, "hiddenUntil", defaultNsp);
            if (hiddenUntilArray != null) {
                hiddenUntil = XMLConditionList.FromMultiple(hiddenUntilArray);
            }
        }

        var meta = new ArcadeMeta();
        meta.ID = id;
        meta.Type = type;
        meta.AreaID = area;
        meta.StageID = stage;
        meta.Icon = icon;
        meta.HiddenUntil = hiddenUntil;
        meta.Index = index;
        return meta;
    }
}
