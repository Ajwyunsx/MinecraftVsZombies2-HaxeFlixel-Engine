// Ported from: Assets/Scripts/MVZ2/Metas/Almanac/AlmanacMetaEntry.cs
package mvz2.metas;

import mvz2.io.XMLHelper;
import mvz2.saves.MVZ2SaveExt;
import mvz2logic.almanac.AlmanacEntryTagInfo;
import mvz2logic.games.IGlobalSaveData;
import mvz2logic.resources.SpriteReference;
import pvzengine.NamespaceID;
import system.xml.XmlNode;

using mvz2.saves.MVZ2SaveExt;
using mvz2.io.XMLHelper;  // EXTUSING
using pvzengine.PropertyKeyHelper;  // EXTUSING

class AlmanacMetaEntry {
    public var id:NamespaceID;
    public var index:Int = -1;
    public var hidden:Bool = false;

    // 杂项
    public var name:String = "";
    public var unlock:XMLConditionList;
    public var encounterUnlock:XMLConditionList;
    public var silhouetteUnlock:XMLConditionList;

    // 缩略图
    public var thumbnail:AlmanacPicture;

    // 图片
    public var picture:AlmanacPicture;
    public var pictureFixedSize:Bool;
    public var pictureZoom:Bool;

    // 图标
    public var tagSourceEntity:NamespaceID;
    public var tags:Array<AlmanacEntryTagInfo>;

    // 变量
    public var localVariables:Array<AlmanacVariable>;

    // 文本
    public var header:String = "";
    public var properties:String = "";
    public var flavors:Array<AlmanacMetaFlavor>;

    public function new(tags:Array<AlmanacEntryTagInfo>, variables:Array<AlmanacVariable>, flavors:Array<AlmanacMetaFlavor>) {
        this.tags = tags;
        this.localVariables = variables;
        this.flavors = flavors;
    }

    public static function FromXmlNode(node:XmlNode, defaultNsp:String):AlmanacMetaEntry {
        var id = XMLHelper.GetAttributeNamespaceID(node, "id", defaultNsp);
        var name = XMLHelper.GetAttribute(node, "name");
        if (name == null) name = "";

        // 遇到条件
        var encounterConditions = XMLHelper.GetUnlockConditionsOrObsolete(node, "encounter", "encounterUnlock", defaultNsp);
        // 解锁条件
        var unlockConditions = XMLHelper.GetUnlockConditionsOrObsolete(node, "unlock", "unlock", defaultNsp);
        // 剪影条件
        var silhouetteNode = node["silhouette"];
        var silouetteConditions:XMLConditionList = null;
        if (silhouetteNode != null) {
            silouetteConditions = XMLConditionList.FromXmlNode(silhouetteNode, defaultNsp);
        }

        var hiddenAttr = XMLHelper.GetAttributeBool(node, "hidden");
        var hidden = hiddenAttr != null ? hiddenAttr : false;

        var thumbnail:AlmanacPicture = null;
        var thumbnailNode = node["thumbnail"];
        if (thumbnailNode != null) {
            thumbnail = AlmanacPicture.FromXmlNode(thumbnailNode, defaultNsp);
        }

        var picture:AlmanacPicture = null;
        var pictureFixedSize = false;
        var pictureZoom = true;
        var pictureNode = node["picture"];
        if (pictureNode != null) {
            picture = AlmanacPicture.FromXmlNode(pictureNode, defaultNsp);
            var fixedSizeAttr = XMLHelper.GetAttributeBool(pictureNode, "fixedSize");
            if (fixedSizeAttr != null) pictureFixedSize = fixedSizeAttr;
            var zoomAttr = XMLHelper.GetAttributeBool(pictureNode, "zoom");
            if (zoomAttr != null) pictureZoom = zoomAttr;
        }

        var tagSourceEntity:NamespaceID = null;
        var tags:Array<AlmanacEntryTagInfo> = [];
        var tagsNode = node["tags"];
        if (tagsNode != null) {
            tagSourceEntity = XMLHelper.GetAttributeNamespaceID(tagsNode, "sourceEntity", defaultNsp);
            for (i in 0...tagsNode.ChildNodes.Count) {
                var child = tagsNode.ChildNodes.getAt(i);
                if (child.Name == "tag") {
                    var tagID = XMLHelper.GetAttributeNamespaceID(child, "id", defaultNsp);
                    if (!NamespaceID.IsValid(tagID))
                        continue;
                    var tagValue = XMLHelper.GetAttribute(child, "value");
                    if (tagValue == null) tagValue = "";
                    tags.push(new AlmanacEntryTagInfo(tagID, tagValue));
                }
            }
        }

        var variables:Array<AlmanacVariable> = [];
        var variablesNode = node["variables"];
        if (variablesNode != null) {
            for (i in 0...variablesNode.ChildNodes.Count) {
                var child = variablesNode.ChildNodes.getAt(i);
                if (child.Name == "variable") {
                    var variable = AlmanacVariable.FromXmlNode(child, defaultNsp);
                    if (variable != null)
                        variables.push(variable);
                }
            }
        }

        var headerNode = node["header"];
        var propertiesNode = node["properties"];
        var header = headerNode != null ? XMLHelper.ConcatNodeParagraphs(headerNode) : "";
        var properties = propertiesNode != null ? XMLHelper.ConcatNodeParagraphs(propertiesNode) : "";

        var flavors:Array<AlmanacMetaFlavor>;
        var flavorsNode = node["flavors"];
        var flavorNode = node["flavor"];
        if (flavorsNode != null) {
            var list:Array<AlmanacMetaFlavor> = [];
            for (i in 0...flavorsNode.ChildNodes.Count) {
                var child = flavorsNode.ChildNodes.getAt(i);
                if (child.Name == "flavor") {
                    list.push(AlmanacMetaFlavor.FromXmlNode(child, defaultNsp));
                }
            }
            flavors = list;
        } else if (flavorNode != null) {
            flavors = [AlmanacMetaFlavor.FromXmlNode(flavorNode, defaultNsp)];
        } else {
            flavors = [];
        }
        var tagsArray = tags;
        var entry = new AlmanacMetaEntry(tagsArray, variables, flavors);
        entry.id = id;
        entry.name = name;
        entry.hidden = hidden;

        entry.encounterUnlock = encounterConditions;
        entry.unlock = unlockConditions;
        entry.silhouetteUnlock = silouetteConditions;

        entry.thumbnail = thumbnail;

        entry.picture = picture;
        entry.pictureFixedSize = pictureFixedSize;
        entry.pictureZoom = pictureZoom;

        entry.tagSourceEntity = tagSourceEntity;
        entry.tags = tagsArray;
        entry.header = header;
        entry.properties = properties;
        entry.flavors = flavors;
        return entry;
    }
    public function IsEmpty():Bool {
        return !NamespaceID.IsValid(id);
    }
    public function GetLocalVariable(variable:String):AlmanacVariable {
        for (localVariable in localVariables) {
            if (localVariable.name == variable)
                return localVariable;
        }
        return null;
    }
    public function GetValidFlavors(save:IGlobalSaveData):Array<String> {
        return Lambda.array(Lambda.map(Lambda.filter(flavors, f -> f.conditions == null || save.MeetsXMLConditions(f.conditions)), f -> f.text));
    }
    public function GetAllFlavors():Array<String> {
        return Lambda.array(Lambda.map(flavors, f -> f.text));
    }
}
