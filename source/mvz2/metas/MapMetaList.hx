// Ported from: Assets/Scripts/MVZ2/Metas/Map/MapMetaList.cs
package mvz2.metas;

import system.xml.XmlNode;

class MapMetaList {
    public var metas:Array<MapMeta>;
    public var elements:Array<MapElementMeta>;

    private function new(metas:Array<MapMeta>, elements:Array<MapElementMeta>) {
        this.metas = metas;
        this.elements = elements;
    }

    public static function FromXmlNode(node:XmlNode, defaultNsp:String):MapMetaList {
        var maps:Array<MapMeta> = [];
        var elements:Array<MapElementMeta> = [];
        var templates:Array<MapElementMetaTemplate> = [];

        var templatesNode = node.GetChildNode("elementTemplates");
        if (templatesNode != null) {
            for (t in MapElementMetaTemplate.LoadTemplates(templatesNode, defaultNsp)) templates.push(t);
        }

        for (i in 0...node.ChildNodes.Count) {
            var child = node.ChildNodes.getAt(i);
            switch (child.Name) {
                case "map":
                    {
                        var meta = MapMeta.FromXmlNode(child, defaultNsp);
                        if (meta != null)
                            maps.push(meta);
                    }
                case "elements":
                    {
                        LoadElements(child, elements, defaultNsp, templates);
                    }
                default:
            }
        }
        return new MapMetaList(maps, elements);
    }
    public static function LoadElements(node:XmlNode, results:Array<MapElementMeta>, defaultNsp:String, templates:Array<MapElementMetaTemplate>):Void {
        for (i in 0...node.ChildNodes.Count) {
            var child = node.ChildNodes.getAt(i);
            switch (child.Name) {
                case "element":
                    {
                        var meta = MapElementMeta.FromXmlNode(child, defaultNsp, templates);
                        if (meta != null)
                            results.push(meta);
                    }
                default:
            }
        }
    }
}
