// Ported from: Assets/Scripts/MVZ2/Metas/MainmenuView/MainmenuViewMetaList.cs
package mvz2.metas;

import system.xml.XmlNode;

class MainmenuViewMetaList {
    public function new(metas:Array<MainmenuViewMeta>) {
        Metas = metas;
    }

    public var Metas(default, null):Array<MainmenuViewMeta>;
    public static function FromXmlNode(node:XmlNode, defaultNsp:String):MainmenuViewMetaList {
        var tags:Array<MainmenuViewMeta> = [];
        for (i in 0...node.ChildNodes.Count) {
            var child = node.ChildNodes.getAt(i);
            if (child.Name == "view") {
                var meta = MainmenuViewMeta.FromXmlNode(child, defaultNsp);
                if (meta != null)
                    tags.push(meta);
            }
        }
        return new MainmenuViewMetaList(tags);
    }
}
