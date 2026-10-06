// Ported from: Assets/Scripts/MVZ2/Metas/Blueprint/BlueprintMetaList.cs
package mvz2.metas;

import system.xml.XmlNode;

class BlueprintMetaList {
    public function new(options:Array<BlueprintOptionMeta>, entities:Array<BlueprintEntityMeta>, errors:Array<BlueprintErrorMeta>, styles:Array<BlueprintStyleMeta>) {
        Options = options;
        Entities = entities;
        Errors = errors;
        Styles = styles;
    }

    public var Options(default, null):Array<BlueprintOptionMeta>;
    public var Entities(default, null):Array<BlueprintEntityMeta>;
    public var Errors(default, null):Array<BlueprintErrorMeta>;
    public var Styles(default, null):Array<BlueprintStyleMeta>;

    public static function FromXmlNode(nsp:String, node:XmlNode, defaultNsp:String):BlueprintMetaList {
        var options:Array<BlueprintOptionMeta> = [];
        var errors:Array<BlueprintErrorMeta> = [];
        var entities:Array<BlueprintEntityMeta> = [];
        var styles:Array<BlueprintStyleMeta> = [];
        for (i in 0...node.ChildNodes.Count) {
            var child = node.ChildNodes.getAt(i);
            if (child.Name == "options") {
                LoadOptions(nsp, options, child, defaultNsp);
            } else if (child.Name == "errors") {
                LoadErrors(errors, child, defaultNsp);
            } else if (child.Name == "entities") {
                LoadEntities(nsp, entities, child, defaultNsp);
            } else if (child.Name == "styles") {
                LoadStyles(nsp, styles, child, defaultNsp);
            }
        }
        return new BlueprintMetaList(options, entities, errors, styles);
    }
    private static function LoadEntities(nsp:String, entities:Array<BlueprintEntityMeta>, node:XmlNode, defaultNsp:String):Void {
        for (i in 0...node.ChildNodes.Count) {
            var child = node.ChildNodes.getAt(i);
            if (child.Name == "entity") {
                var meta = BlueprintEntityMeta.FromXmlNode(nsp, child, defaultNsp);
                if (meta != null) {
                    entities.push(meta);
                }
            }
        }
    }
    private static function LoadOptions(nsp:String, options:Array<BlueprintOptionMeta>, node:XmlNode, defaultNsp:String):Void {
        for (i in 0...node.ChildNodes.Count) {
            var child = node.ChildNodes.getAt(i);
            if (child.Name == "option") {
                var meta = BlueprintOptionMeta.FromXmlNode(nsp, child, defaultNsp);
                if (meta != null) {
                    options.push(meta);
                }
            }
        }
    }
    private static function LoadErrors(errors:Array<BlueprintErrorMeta>, node:XmlNode, defaultNsp:String):Void {
        for (i in 0...node.ChildNodes.Count) {
            var child = node.ChildNodes.getAt(i);
            if (child.Name == "error") {
                var meta = BlueprintErrorMeta.FromXmlNode(child, defaultNsp);
                if (meta != null) {
                    errors.push(meta);
                }
            }
        }
    }
    private static function LoadStyles(nsp:String, styles:Array<BlueprintStyleMeta>, node:XmlNode, defaultNsp:String):Void {
        for (i in 0...node.ChildNodes.Count) {
            var child = node.ChildNodes.getAt(i);
            if (child.Name == "style") {
                var meta = BlueprintStyleMeta.FromXmlNode(child, defaultNsp);
                if (meta != null) {
                    styles.push(meta);
                }
            }
        }
    }
}
