// Ported from: Assets/Scripts/MVZ2/Metas/AchievementMetaList.cs
package mvz2.metas;

import system.xml.XmlNode;

class AchievementMetaList {
    public var metas:Array<AchievementMeta>;

    public function new(metas:Array<AchievementMeta>) {
        this.metas = metas;
    }

    public static function FromXmlNode(node:XmlNode, defaultNsp:String):AchievementMetaList {
        var metas:Array<AchievementMeta> = [];
        for (i in 0...node.ChildNodes.Count) {
            var childNode = node.ChildNodes.getAt(i);
            switch (childNode.Name) {
                case "achievement":
                    var meta = AchievementMeta.FromXmlNode(childNode, defaultNsp);
                    if (meta != null) {
                        metas.push(meta);
                    }
                default:
            }
        }
        return new AchievementMetaList(metas);
    }
}
