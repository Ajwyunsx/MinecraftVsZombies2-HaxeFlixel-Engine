package mvz2.metas;

import mvz2.unlocks.UnlockGroupMeta;
import system.xml.XmlNode;

// Ported from: Assets/Scripts/MVZ2/Unlocks/AchievementMetaList.cs
// PORT-NOTE: the C# file AchievementMetaList.cs declares the type `UnlockMetaList`, so the Haxe
// module is named after the type to keep the package path consistent across work packages.
class UnlockMetaList {
    public var groups:Array<UnlockGroupMeta>;

    public function new(groups:Array<UnlockGroupMeta>) {
        this.groups = groups;
    }

    public static function FromXmlNode(node:XmlNode, defaultNsp:String):UnlockMetaList {
        var metas:Array<UnlockGroupMeta> = [];
        for (i in 0...node.childNodes.Count) {
            var childNode = node.childNodes[i];
            switch (childNode.name) {
                case "group":
                    var meta = UnlockGroupMeta.FromXmlNode(node.childNodes[i], defaultNsp);
                    if (meta != null) {
                        metas.push(meta);
                    }
                default:
            }
        }
        return new UnlockMetaList(metas);
    }
}
