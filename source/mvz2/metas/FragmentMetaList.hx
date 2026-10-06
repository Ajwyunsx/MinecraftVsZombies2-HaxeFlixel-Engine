// Ported from: Assets/Scripts/MVZ2/Metas/FragmentMetaList.cs
package mvz2.metas;

import system.xml.XmlNode;

class FragmentMetaList {
    public var metas:Array<FragmentMeta>;

    public function new(metas:Array<FragmentMeta>) {
        this.metas = metas;
    }

    public static function FromXmlNode(node:XmlNode):FragmentMetaList {
        var resources:Array<FragmentMeta> = [];
        for (i in 0...node.ChildNodes.Count) {
            var meta = FragmentMeta.FromXmlNode(node.ChildNodes.getAt(i));
            if (meta != null)
                resources.push(meta);
        }
        return new FragmentMetaList(resources);
    }
}
