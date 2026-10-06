// Ported from: Assets/Scripts/MVZ2/Metas/Grids/GridMetaList.cs
package mvz2.metas;

import system.xml.XmlNode;

class GridMetaList {
    public var metas:Array<GridMeta>;
    public var layers:Array<GridLayerMeta>;
    public var errors:Array<GridErrorMeta>;

    public function new(metas:Array<GridMeta>, layers:Array<GridLayerMeta>, errors:Array<GridErrorMeta>) {
        this.metas = metas;
        this.layers = layers;
        this.errors = errors;
    }

    public static function FromXmlNode(node:XmlNode, defaultNsp:String):GridMetaList {
        var layersNode = node.GetChildNode("layers");
        var layers:Array<GridLayerMeta> = [];
        if (layersNode != null) {
            for (i in 0...layersNode.ChildNodes.Count) {
                var child = layersNode.ChildNodes.getAt(i);
                if (child.Name == "layer") {
                    var meta = GridLayerMeta.FromXmlNode(child, defaultNsp);
                    if (meta != null)
                        layers.push(meta);
                }
            }
        }
        var errorsNode = node.GetChildNode("errors");
        var errors:Array<GridErrorMeta> = [];
        if (errorsNode != null) {
            for (i in 0...errorsNode.ChildNodes.Count) {
                var child = errorsNode.ChildNodes.getAt(i);
                if (child.Name == "error") {
                    var meta = GridErrorMeta.FromXmlNode(child, defaultNsp);
                    if (meta != null)
                        errors.push(meta);
                }
            }
        }
        var grids:Array<GridMeta> = [];
        for (i in 0...node.ChildNodes.Count) {
            var child = node.ChildNodes.getAt(i);
            if (child.Name == "grid") {
                var meta = GridMeta.FromXmlNode(child, defaultNsp);
                if (meta != null)
                    grids.push(meta);
            }
        }
        return new GridMetaList(grids, layers, errors);
    }
}
