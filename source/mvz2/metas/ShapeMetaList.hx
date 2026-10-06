// Ported from: Assets/Scripts/MVZ2/Metas/Shapes/ShapeMetaList.cs
package mvz2.metas;

import system.xml.XmlNode;

class ShapeMetaList {
    public var metas:Array<ShapeMeta>;

    public function new(metas:Array<ShapeMeta>) {
        this.metas = metas;
    }

    public static function FromXmlNode(node:XmlNode, defaultNsp:String):ShapeMetaList {
        var resources:Array<ShapeMeta> = [];
        for (i in 0...node.ChildNodes.Count) {
            var child = node.ChildNodes.getAt(i);
            var meta = ShapeMeta.FromXmlNode(child, defaultNsp);
            if (meta != null)
                resources.push(meta);
        }
        return new ShapeMetaList(resources);
    }
}
