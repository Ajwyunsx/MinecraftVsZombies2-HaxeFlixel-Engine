// Ported from: Assets/Scripts/MVZ2/Metas/Options/OptionMetaList.cs
package mvz2.metas;

import system.xml.XmlNode;

class OptionMetaList {
    public var categories:Array<OptionCategoryMeta>;
    public var items:Array<OptionItemMeta>;
    public var widgets:Array<OptionWidgetMeta>;

    public function new(categories:Array<OptionCategoryMeta>, items:Array<OptionItemMeta>, widgets:Array<OptionWidgetMeta>) {
        this.categories = categories;
        this.items = items;
        this.widgets = widgets;
    }

    public static function FromXmlNode(node:XmlNode, defaultNsp:String):OptionMetaList {
        var categories:Array<OptionCategoryMeta> = [];
        var categoriesNode = node["categories"];
        if (categoriesNode != null) {
            for (i in 0...categoriesNode.ChildNodes.Count) {
                var childNode = categoriesNode.ChildNodes.getAt(i);
                switch (childNode.Name) {
                    case "category":
                        {
                            var meta = OptionCategoryMeta.FromXmlNode(childNode, defaultNsp);
                            if (meta != null)
                                categories.push(meta);
                        }
                    default:
                }
            }
        }
        var items:Array<OptionItemMeta> = [];
        var itemsNode = node["items"];
        if (itemsNode != null) {
            for (i in 0...itemsNode.ChildNodes.Count) {
                var childNode = itemsNode.ChildNodes.getAt(i);
                var item = OptionItemMeta.FromXmlNode(childNode, defaultNsp);
                if (item != null)
                    items.push(item);
            }
        }
        var widgets:Array<OptionWidgetMeta> = [];
        var widgetsNode = node["widgets"];
        if (widgetsNode != null) {
            for (i in 0...widgetsNode.ChildNodes.Count) {
                var childNode = widgetsNode.ChildNodes.getAt(i);
                var widget = OptionWidgetMeta.FromXmlNode(childNode, defaultNsp, i);
                if (widget != null)
                    widgets.push(widget);
            }
        }
        return new OptionMetaList(categories, items, widgets);
    }
}
