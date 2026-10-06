// Ported from: Assets/Scripts/MVZ2/Metas/Credits/CreditMetaList.cs
package mvz2.metas;

import system.xml.XmlNode;

class CreditMetaList {
    public var categories:Array<CreditsCategoryMeta>;

    public function new(categories:Array<CreditsCategoryMeta>) {
        this.categories = categories;
    }

    public static function FromXmlNode(node:XmlNode, defaultNsp:String):CreditMetaList {
        var categories:Array<CreditsCategoryMeta> = [];
        for (i in 0...node.ChildNodes.Count) {
            var child = node.ChildNodes.getAt(i);
            if (child.Name == "category") {
                var meta = CreditsCategoryMeta.FromXmlNode(child, defaultNsp);
                if (meta != null)
                    categories.push(meta);
            }
        }
        return new CreditMetaList(categories);
    }
}
