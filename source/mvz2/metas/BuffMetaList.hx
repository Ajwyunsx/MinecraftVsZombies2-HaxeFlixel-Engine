// Ported from: Assets/Scripts/MVZ2/Metas/Buff/BuffMetaList.cs
package mvz2.metas;

import system.xml.XmlNode;

class BuffMetaList {
    public var metas:Array<BuffMeta>;

    public function new(metas:Array<BuffMeta>) {
        this.metas = metas;
    }

    public static function FromXmlNode(node:XmlNode, defaultNsp:String):BuffMetaList {
        var metas:Array<BuffMeta> = [];
        metas.resize(node.ChildNodes.Count);
        for (i in 0...metas.length) {
            var meta = BuffMeta.FromXmlNode(node.ChildNodes.getAt(i), defaultNsp);
            if (meta != null) {
                metas[i] = meta;
            }
        }
        return new BuffMetaList(metas);
    }
}
