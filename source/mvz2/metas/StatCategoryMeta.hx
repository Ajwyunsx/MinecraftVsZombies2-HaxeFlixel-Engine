// Ported from: Assets/Scripts/MVZ2/Metas/Stats/StatCategoryMeta.cs
package mvz2.metas;

import mvz2.io.XMLHelper;
import pvzengine.Log;
import system.xml.XmlNode;
using mvz2.io.XMLHelper;  // EXTUSING

class StatCategoryMeta {
    public var ID(default, null):String;
    public var Name(default, null):String = "";
    public var Type(default, null):StatCategoryType;
    public var Operation(default, null):StatOperation;

    public function new(iD:String) {
        ID = iD;
    }
    public static function FromXmlNode(node:XmlNode, defaultNsp:String):StatCategoryMeta {
        var id = XMLHelper.GetAttribute(node, "id");
        if (id == null || id.length == 0) {
            Log.LogError('The id of a StatCategoryMeta is invalid.');
            return null;
        }
        var name = XMLHelper.GetAttribute(node, "name");
        if (name == null) name = "";
        var typeStr = XMLHelper.GetAttribute(node, "type");
        var type:StatCategoryType = StatCategoryType.Entity;
        if (typeStr != null && typeStr.length > 0 && typeDict.exists(typeStr)) {
            type = typeDict.get(typeStr);
        }
        var operationStr = XMLHelper.GetAttribute(node, "operation");
        var operation:StatOperation = StatOperation.Sum;
        if (operationStr != null && operationStr.length > 0 && operationDict.exists(operationStr)) {
            operation = operationDict.get(operationStr);
        }
        var meta = new StatCategoryMeta(id);
        meta.Name = name;
        meta.Type = type;
        meta.Operation = operation;
        return meta;
    }
    private static var typeDict:Map<String, StatCategoryType> = [
        "entity" => StatCategoryType.Entity,
        "stage" => StatCategoryType.Stage,
    ];
    private static var operationDict:Map<String, StatOperation> = [
        "add" => StatOperation.Sum,
        "max" => StatOperation.Max,
    ];
}
