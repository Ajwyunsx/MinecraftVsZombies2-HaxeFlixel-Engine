// Ported from: Assets/Scripts/MVZ2/Metas/Almanac/AlmanacMetaList.cs
package mvz2.metas;

import system.xml.XmlNode;

class AlmanacMetaList {
    public var tags:Array<AlmanacTagMeta>;
    public var globalVariables:Array<AlmanacVariable>;
    public var enums:Array<AlmanacTagEnumMeta>;
    public var categories:Array<AlmanacCategory>;

    public function new(tags:Array<AlmanacTagMeta>, globalVariables:Array<AlmanacVariable>, enums:Array<AlmanacTagEnumMeta>, categories:Array<AlmanacCategory>) {
        this.tags = tags;
        this.globalVariables = globalVariables;
        this.enums = enums;
        this.categories = categories;
    }

    public function GetCategory(name:String):AlmanacCategory {
        for (c in categories) {
            if (c.name == name)
                return c;
        }
        return null;
    }
    public function TryGetCategory(name:String, category:{value:AlmanacCategory}):Bool {
        category.value = GetCategory(name);
        return category.value != null;
    }
    public static function FromXmlNode(node:XmlNode, defaultNsp:String):AlmanacMetaList {
        var tags:Array<AlmanacTagMeta> = [];
        var globalVariables:Array<AlmanacVariable> = [];
        var enums:Array<AlmanacTagEnumMeta> = [];
        var categories:Array<AlmanacCategory> = [];
        for (i in 0...node.ChildNodes.Count) {
            var childNode = node.ChildNodes.getAt(i);
            if (childNode.Name == "tags") {
                LoadTags(childNode, defaultNsp, tags, enums);
            } else if (childNode.Name == "globalVariables") {
                LoadVariables(childNode, defaultNsp, globalVariables);
            } else {
                var category = AlmanacCategory.FromXmlNode(childNode, defaultNsp);
                categories.push(category);
            }
        }
        return new AlmanacMetaList(tags, globalVariables, enums, categories);
    }
    private static function LoadTags(node:XmlNode, defaultNsp:String, tags:Array<AlmanacTagMeta>, enums:Array<AlmanacTagEnumMeta>):Void {
        for (i in 0...node.ChildNodes.Count) {
            var childNode = node.ChildNodes.getAt(i);
            if (childNode.Name == "tag") {
                var tag = AlmanacTagMeta.FromXmlNode(childNode, defaultNsp);
                if (tag != null) {
                    tags.push(tag);
                }
            } else if (childNode.Name == "enum") {
                var enumType = AlmanacTagEnumMeta.FromXmlNode(childNode, defaultNsp);
                if (enumType != null) {
                    enums.push(enumType);
                }
            }
        }
    }
    private static function LoadVariables(node:XmlNode, defaultNsp:String, variables:Array<AlmanacVariable>):Void {
        for (i in 0...node.ChildNodes.Count) {
            var childNode = node.ChildNodes.getAt(i);
            if (childNode.Name == "variable") {
                var variable = AlmanacVariable.FromXmlNode(childNode, defaultNsp);
                if (variable != null) {
                    variables.push(variable);
                }
            }
        }
    }
}
