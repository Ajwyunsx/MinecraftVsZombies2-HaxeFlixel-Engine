package mvz2.io;

import haxe.Int64;
import mvz2.metas.EntityMeta;
import mvz2.metas.IMetaTemplate;
import mvz2.metas.XMLConditionList;
import mvz2logic.Log;
import mvz2logic.ParseHelper;
import mvz2logic.resources.SpriteReference;
import pvzengine.NamespaceID;
import pvzengine.PropertyKeyHelper;
import system.io.MemoryStream;
import system.io.Stream;
import tools.Ref;
import system.io.StreamReader;
import system.io.StreamWriter;
import system.io.SeekOrigin;
import system.xml.XmlAttribute;
import system.xml.XmlDocument;
import system.xml.XmlNode;
import system.xml.XmlNodeList;
import system.xml.XmlReader;
import unity.Color;
import unity.ColorUtility;
import unity.Debug;
import unity.Gradient;
import unity.Vector2;
import unity.Vector2Int;
import unity.Vector3;
import unity.Vector3Int;
import system.io.Path;
import mvz2.metas.EntityMeta.BehaviourItem;
import mvz2.metas.EntityMeta.BehaviourOperator;
import mvz2.metas.EntityMeta.EntityBehaviourItem;
import mvz2logic.ParseHelper.OutFloat;
import mvz2logic.ParseHelper.OutInt;
import mvz2logic.ParseHelper.OutLong;
import mvz2logic.ParseHelper.OutVector2;
import mvz2logic.ParseHelper.OutVector2Int;
import mvz2logic.ParseHelper.OutVector3;
import mvz2logic.ParseHelper.OutVector3Int;
import system.xml.XmlReader.XmlReaderSettings;
import unity.Gradient.GradientAlphaKey;
import unity.Gradient.GradientColorKey;
import unity.Gradient.GradientMode;

// Ported from: Assets/Scripts/MVZ2/Files/XMLHelper.cs
// PORT-NOTE: C# extension methods on XmlNode → static methods taking the node as first parameter
// (PORTING.md §扩展方法). `out` parameters use the `{value:T}` reference wrapper convention.
class XMLHelper {
    private function new() {}

    public static function CreateAttribute(node:XmlNode, name:String, value:String):XmlAttribute {
        var attr = node.ownerDocument.createAttribute(name);
        attr.value = value;
        node.attributes.append(attr);
        return attr;
    }
    public static function ReadXmlDocument(str:String):XmlDocument {
        var memory = new MemoryStream();
        var textWriter = new StreamWriter(memory);
        textWriter.Write(str);
        memory.Seek(0, SeekOrigin.Begin);
        return ReadXmlDocumentFromStream(memory);
    }
    // PORT-NOTE: C# overload `ReadXmlDocument(this Stream)`; Haxe has no overloads.
    public static function ReadXmlDocumentFromStream(stream:Stream):XmlDocument {
        var settings = new XmlReaderSettings();
        settings.ignoreComments = true;
        var xmlReader = XmlReader.create(stream, settings);
        var document = XmlDocument.create();
        document.load(xmlReader);
        return document;
    }
    public static function CreateTextOrCDataNode(document:XmlDocument, node:XmlNode, name:String, text:String):Void {
        var textNode:XmlNode;
        if (indexOfAny(text, xmlSpecialChars) != -1) {
            textNode = document.createElement(name);
            var section = document.createCDataSection(text);
            textNode.appendChild(section);
        } else {
            textNode = document.createElement(name);
            textNode.innerText = text;
        }
        node.appendChild(textNode);
    }
    public static function AddComment(document:XmlDocument, node:XmlNode, comment:String):Void {
        if (comment != null && comment.length > 0) {
            var commentNode = document.createComment(comment);
            node.appendChild(commentNode);
        }
    }
    public static function HasAttribute(node:XmlNode, name:String):Bool {
        return node.attributes[name] != null;
    }
    public static function GetAttribute(node:XmlNode, name:String):String {
        var attr = node.attributes[name];
        if (attr == null)
            return null;
        return attr.value;
    }
    // PORT-NOTE: C# 为 `bool? GetAttributeBool(...)`（属性不存在或 `bool.TryParse` 失败 → null）。
    // 返回值必须是 Null<Bool>：若声明为 Bool，cpp 目标会在本函数 `return null` 以及所有
    // 调用点的 `attr != null ? attr : default` 处报 "null can't be used as basic type Bool"。
    public static function GetAttributeBool(node:XmlNode, name:String):Null<Bool> {
        var attr = node.attributes[name];
        if (attr == null)
            return null;
        // PORT-NOTE: 对应 C# `bool.TryParse(attr.Value, out var value)`：忽略首尾空白与大小写。
        var text = attr.value;
        var value:Null<Bool> = text == null ? null : switch (StringTools.trim(text).toLowerCase()) {
            case "true": true;
            case "false": false;
            default: null;
        };
        return value;
    }
    public static function GetAttributeInt(node:XmlNode, name:String):Null<Int> {
        var attr = node.attributes[name];
        if (attr == null)
            return null;
        var outValue:OutInt = {value: 0};
        if (!ParseHelper.TryParseInt(attr.value, outValue))
            return null;
        return outValue.value;
    }
    public static function GetAttributeLong(node:XmlNode, name:String):Null<Int64> {
        var attr = node.attributes[name];
        if (attr == null)
            return null;
        var outValue:OutLong = {value: Int64.ofInt(0)};
        if (!ParseHelper.TryParseLong(attr.value, outValue))
            return null;
        return outValue.value;
    }
    public static function GetAttributeFloat(node:XmlNode, name:String):Null<Float> {
        var attr = node.attributes[name];
        if (attr == null)
            return null;
        var outValue:OutFloat = {value: 0};
        if (!ParseHelper.TryParseFloat(attr.value, outValue))
            return null;
        return outValue.value;
    }
    public static function GetAttributeDouble(node:XmlNode, name:String):Null<Float> {
        var attr = node.attributes[name];
        if (attr == null)
            return null;
        var outValue:OutFloat = {value: 0};
        if (!ParseHelper.TryParseDouble(attr.value, outValue))
            return null;
        return outValue.value;
    }
    public static function GetAttributeColor(node:XmlNode, name:String):Color {
        var attr = node.attributes[name];
        if (attr == null)
            return null;
        var outValue:{value:Color} = {value: null};
        if (!ColorUtility.TryParseHtmlString(attr.value, outValue))
            return null;
        return outValue.value;
    }
    public static function GetAttributeNamespaceID(node:XmlNode, name:String, defaultNsp:String):NamespaceID {
        var attr = node.attributes[name];
        if (attr == null)
            return null;
        var outValue:{value:NamespaceID} = {value: null};
        if (!NamespaceID.TryParse(attr.value, defaultNsp, outValue))
            return null;
        return outValue.value;
    }
    public static function GetAttributeNamespaceIDArray(node:XmlNode, name:String, defaultNsp:String):Array<NamespaceID> {
        var attr = node.attributes[name];
        if (attr == null)
            return null;
        var list:Array<NamespaceID> = [];
        for (str in splitAny(attr.value, [' ', ';'])) {
            var outValue:{value:NamespaceID} = {value: null};
            if (NamespaceID.TryParse(str, defaultNsp, outValue)) {
                list.push(outValue.value);
            }
        }
        return list;
    }
    public static function GetAttributeSpriteReference(node:XmlNode, name:String, defaultNsp:String):SpriteReference {
        var attr = node.attributes[name];
        if (attr == null)
            return null;
        // PORT-NOTE: C# `out SpriteReference value` → tools.Ref<SpriteReference> 引用容器
		var outValue = new tools.Ref<SpriteReference>(null);
        if (!SpriteReference.TryParse(attr.value, defaultNsp, outValue))
            return null;
        return outValue.value;
    }
    public static function ToGradient(node:XmlNode):Gradient {
        if (node == null)
            return null;
        var blend = GetAttributeBool(node, "blend") == true;

        var colorKeys:Array<GradientColorKey>;
        var colorKeysNode:XmlNode = node["colorKeys"];
        if (colorKeysNode == null || colorKeysNode.childNodes == null || colorKeysNode.childNodes.Count <= 0) {
            colorKeys = [
                new GradientColorKey(Color.magenta, 0),
                new GradientColorKey(Color.black, 0.5),
            ];
        } else {
            colorKeys = [];
            colorKeys.resize(colorKeysNode.childNodes.Count);
            for (i in 0...colorKeys.length) {
                colorKeys[i] = ToGradientColorKey(colorKeysNode.childNodes[i]);
            }
        }

        var alphaKeys:Array<GradientAlphaKey>;
        var alphaKeysNode:XmlNode = node["alphaKeys"];
        if (alphaKeysNode == null || alphaKeysNode.childNodes == null || alphaKeysNode.childNodes.Count <= 0) {
            alphaKeys = [
                new GradientAlphaKey(1, 0)
            ];
        } else {
            alphaKeys = [];
            alphaKeys.resize(alphaKeysNode.childNodes.Count);
            for (i in 0...alphaKeys.length) {
                alphaKeys[i] = ToGradientAlphaKey(alphaKeysNode.childNodes[i]);
            }
        }

        var gradient = new Gradient();
        gradient.mode = blend ? GradientMode.Blend : GradientMode.Fixed;
        gradient.colorKeys = colorKeys;
        gradient.alphaKeys = alphaKeys;
        return gradient;
    }
    public static function ToGradientColorKey(node:XmlNode):GradientColorKey {
        var outColor:{value:Color} = {value: null};
        var col = ColorUtility.TryParseHtmlString(GetAttribute(node, "hex"), outColor) ? outColor.value : Color.magenta;
        var time = GetAttributeFloat(node, "time");
        return new GradientColorKey(col, time != null ? time : 0);
    }
    public static function ToGradientAlphaKey(node:XmlNode):GradientAlphaKey {
        var alpha = GetAttributeFloat(node, "alpha");
        var time = GetAttributeFloat(node, "time");
        return new GradientAlphaKey(alpha != null ? alpha : 1, time != null ? time : 0);
    }

    // #region 行为 & 属性
    public static function LoadPropertiesFromNode(propsNode:XmlNode, defaultNsp:String, propertyRegion:String, properties:Map<String, Dynamic>):Void {
        var props = ToPropertyDictionary(propsNode, defaultNsp);
        for (key in props.keys()) {
            var fullName = PropertyKeyHelper.ParsePropertyFullName(key, defaultNsp, propertyRegion);
            properties.set(fullName, props.get(key));
        }
    }
    public static function LoadBehaviourProperties(node:XmlNode, properties:Map<String, Dynamic>, propertyRegion:String, defaultNsp:String):Void {
        var propertyTargetBehaviourID = GetAttributeNamespaceID(node, "behaviour", defaultNsp);
        if (!NamespaceID.IsValid(propertyTargetBehaviourID))
            return;
        var propDict = ToPropertyDictionary(node, defaultNsp);
        for (key in propDict.keys()) {
            var fullName = PropertyKeyHelper.CombineFullName(propertyTargetBehaviourID.SpaceName, propertyRegion, propertyTargetBehaviourID.Path, key);
            properties.set(fullName, propDict.get(key));
        }
    }
    public static function LoadTemplatePropertiesFromNode(node:XmlNode, defaultNsp:String, rootNode:XmlNode, behaviourPropertyRegion:String, propertyRegion:String, behaviours:Array<BehaviourItem>, properties:Map<String, Dynamic>):Void {
        var parent = GetAttribute(node, "parent");
        if (parent != null && parent.length > 0) {
            var parentNode:XmlNode = rootNode[parent];
            if (parentNode != null) {
                LoadTemplatePropertiesFromNode(parentNode, defaultNsp, rootNode, behaviourPropertyRegion, propertyRegion, behaviours, properties);
            }
        }
        var behavioursNode:XmlNode = node["behaviours"];
        LoadBehavioursFromNode(behavioursNode, defaultNsp, behaviourPropertyRegion, behaviours, properties);

        var propsNode:XmlNode = node["properties"];
        LoadPropertiesFromNode(propsNode, defaultNsp, propertyRegion, properties);
    }
    public static function LoadBehavioursAndPropertiesFromTemplate(defaultNsp:String, behaviourPropertyRegion:String, template:IMetaTemplate, behaviours:Array<BehaviourItem>, properties:Map<String, Dynamic>):Void {
        for (b in template.GetBehaviours()) behaviours.push(b);

        for (key in template.GetProperties().keys()) {
            if (properties.exists(key))
                continue;
            properties.set(key, template.GetProperties().get(key));
        }
    }
    public static function LoadBehavioursFromNode(node:XmlNode, defaultNsp:String, propertyRegion:String, behaviours:Array<BehaviourItem>, properties:Map<String, Dynamic>):Void {
        if (node == null)
            return;
        for (i in 0...node.childNodes.Count) {
            var childNode = node.childNodes[i];
            if (childNode.name == "behaviour") {
                OperateBehaviourList(childNode, behaviours, defaultNsp);
            } else if (childNode.name == "properties") {
                LoadBehaviourProperties(childNode, properties, propertyRegion, defaultNsp);
            }
        }
    }
    public static function OperateBehaviourList(node:XmlNode, behaviours:Array<BehaviourItem>, defaultNsp:String):Void {
        var item = EntityBehaviourItem.FromXmlNode(node, defaultNsp);
        if (item == null)
            return;
        switch (item.Operator) {
            case BehaviourOperator.Add:
                if (Lambda.exists(behaviours, b -> b.id == item.ID)) {
                    Log.LogWarning('Trying to add behaviour ${item.ID} to the list which already has this.');
                } else {
                    behaviours.push(new BehaviourItem(item.ID, item.Priority));
                }
            case BehaviourOperator.Remove:
                {
                    var index = indexOfBehaviour(behaviours, item.ID);
                    if (index < 0) {
                        Log.LogWarning('Cannot find behaviour ${item.ID} to remove.');
                    } else {
                        behaviours.splice(index, 1);
                    }
                }
            case BehaviourOperator.Replace:
                if (NamespaceID.IsValid(item.SourceID)) {
                    var index = indexOfBehaviour(behaviours, item.SourceID);
                    if (index >= 0) {
                        behaviours[index] = new BehaviourItem(item.ID, item.Priority);
                    } else {
                        Log.LogWarning('Failed to replace behaviour ${item.SourceID} to ${item.ID}, cannot find the behaviour to replace.');
                    }
                } else {
                    Log.LogWarning('Failed to replace behaviour to ${item.ID}, the behaviour id to replace is invalid.');
                }
        }
    }
    // PORT-NOTE: C# `List<T>.FindIndex` → explicit loop.
    private static function indexOfBehaviour(behaviours:Array<BehaviourItem>, id:NamespaceID):Int {
        for (i in 0...behaviours.length) {
            if (behaviours[i].id == id) return i;
        }
        return -1;
    }
    // #endregion

    public static function ToPropertyDictionary(node:XmlNode, defaultNsp:String):Map<String, Dynamic> {
        var properties:Map<String, Dynamic> = new Map();
        if (node == null)
            return properties;
        for (i in 0...node.childNodes.Count) {
            var propNode = node.childNodes[i];
            var propKey = GetAttribute(propNode, "name");
            var outProp:{value:Dynamic} = {value: null};
            if (propKey != null && propKey.length > 0 && TryToProperty(propNode, defaultNsp, outProp)) {
                properties.set(propKey, outProp.value);
            } else {
                Debug.LogWarning('Cannot create property "${propKey}" of type "${propNode.name}" from xml node.');
            }
        }
        return properties;
    }
    public static function GetUnlockConditionsOrObsolete(node:XmlNode, childNodeName:String, fallbackAttributeName:String, defaultNsp:String):XMLConditionList {
        var conditions:XMLConditionList = null;
        var unlockNode:XmlNode = node[childNodeName];
        if (unlockNode != null) {
            conditions = XMLConditionList.FromXmlNode(unlockNode, defaultNsp);
        } else {
            var unlock = GetAttributeNamespaceID(node, fallbackAttributeName, defaultNsp);
            if (NamespaceID.IsValid(unlock)) {
                conditions = XMLConditionList.FromSingle(unlock);
            }
        }
        return conditions;
    }
    public static function GetUnlockConditionsOrObsoleteArray(node:XmlNode, childNodeName:String, fallbackAttributeName:String, defaultNsp:String):XMLConditionList {
        var conditions:XMLConditionList = null;
        var unlockNode:XmlNode = node[childNodeName];
        if (unlockNode != null) {
            conditions = XMLConditionList.FromXmlNode(unlockNode, defaultNsp);
        } else {
            var unlock = GetAttributeNamespaceIDArray(node, fallbackAttributeName, defaultNsp);
            if (unlock != null) {
                conditions = XMLConditionList.FromMultiple(unlock);
            }
        }
        return conditions;
    }

    public static function TryGetAttributeStruct(node:XmlNode, name:String, type:String, propValue:{value:Dynamic}):Bool {
        propValue.value = null;
        switch (type) {
            case "bool":
                {
                    var value = GetAttributeBool(node, name);
                    if (value != null) {
                        propValue.value = value;
                        return true;
                    }
                }
            case "int", "integer":
                {
                    var value = GetAttributeInt(node, name);
                    if (value != null) {
                        propValue.value = value;
                        return true;
                    }
                }
            case "float":
                {
                    var value = GetAttributeFloat(node, name);
                    if (value != null) {
                        propValue.value = value;
                        return true;
                    }
                }
            case "string":
                {
                    if (!HasAttribute(node, name)) {
                        propValue.value = null;
                        return false;
                    }
                    propValue.value = GetAttribute(node, name);
                    return true;
                }
            case "color":
                {
                    var value = GetAttributeColor(node, name);
                    if (value != null) {
                        propValue.value = value;
                        return true;
                    }
                }
            default:
        }
        return false;
    }
    public static function TryGetAttributeVector(node:XmlNode, type:String, propValue:{value:Dynamic}):Bool {
        propValue.value = null;
        switch (type) {
            case "vector2":
                {
                    var outVec:OutVector2 = {value: null};
                    if (TryGetAttributeVector2(node, outVec)) {
                        propValue.value = outVec.value;
                        return true;
                    }
                }
            case "vector3":
                {
                    var outVec:OutVector3 = {value: null};
                    if (TryGetAttributeVector3(node, outVec)) {
                        propValue.value = outVec.value;
                        return true;
                    }
                }
            case "vector2Int":
                {
                    var outVec:OutVector2Int = {value: null};
                    if (TryGetAttributeVector2Int(node, outVec)) {
                        propValue.value = outVec.value;
                        return true;
                    }
                }
            case "vector3Int":
                {
                    var outVec:OutVector3Int = {value: null};
                    if (TryGetAttributeVector3Int(node, outVec)) {
                        propValue.value = outVec.value;
                        return true;
                    }
                }
            default:
        }
        return false;
    }
    public static function TryGetAttributeVector2(node:XmlNode, propValue:OutVector2):Bool {
        propValue.value = new Vector2();
        var x = GetAttributeFloat(node, "x");
        var y = GetAttributeFloat(node, "y");
        if (x != null && y != null) {
            propValue.value = new Vector2(x, y);
            return true;
        }
        return false;
    }
    public static function TryGetAttributeVector3(node:XmlNode, propValue:OutVector3):Bool {
        propValue.value = new Vector3();
        var x = GetAttributeFloat(node, "x");
        var y = GetAttributeFloat(node, "y");
        var z = GetAttributeFloat(node, "z");
        if (x != null && y != null && z != null) {
            propValue.value = new Vector3(x, y, z);
            return true;
        }
        return false;
    }
    public static function TryGetAttributeVector2Int(node:XmlNode, propValue:OutVector2Int):Bool {
        propValue.value = new Vector2Int();
        var x = GetAttributeInt(node, "x");
        var y = GetAttributeInt(node, "y");
        if (x != null && y != null) {
            propValue.value = new Vector2Int(x, y);
            return true;
        }
        return false;
    }
    public static function TryGetAttributeVector3Int(node:XmlNode, propValue:OutVector3Int):Bool {
        propValue.value = new Vector3Int();
        var x = GetAttributeInt(node, "x");
        var y = GetAttributeInt(node, "y");
        var z = GetAttributeInt(node, "z");
        if (x != null && y != null && z != null) {
            propValue.value = new Vector3Int(x, y, z);
            return true;
        }
        return false;
    }
    public static function GetAttributeVector2(node:XmlNode):Vector2 {
        var outVec:OutVector2 = {value: null};
        return TryGetAttributeVector2(node, outVec) ? outVec.value : null;
    }
    public static function GetAttributeVector3(node:XmlNode):Vector3 {
        var outVec:OutVector3 = {value: null};
        return TryGetAttributeVector3(node, outVec) ? outVec.value : null;
    }
    public static function TryGetAttributeNullable(node:XmlNode, name:String, nullAttributeName:String, type:String, defaultNsp:String, propValue:{value:Dynamic}):Bool {
        if (GetAttributeBool(node, nullAttributeName) == true) {
            propValue.value = null;
            return true;
        }
        propValue.value = null;
        switch (type) {
            case "id":
                {
                    var value = GetAttributeNamespaceID(node, name, defaultNsp);
                    var valid = value != null;
                    if (valid)
                        propValue.value = value;
                    return valid;
                }
            case "idArray":
                {
                    var valueStr = GetAttribute(node, name);
                    if (valueStr == null || valueStr.length == 0) {
                        propValue.value = [];
                    } else {
                        propValue.value = Lambda.array(Lambda.map(Lambda.filter(Lambda.map(valueStr.split(" "), v -> {
                            var outValue:{value:NamespaceID} = {value: null};
                            return NamespaceID.TryParse(v, defaultNsp, outValue) ? outValue.value : null;
                        }), v -> v != null), v -> v));
                    }
                    return true;
                }
            case "sprite":
                {
                    var value = GetAttributeSpriteReference(node, name, defaultNsp);
                    if (value != null) {
                        propValue.value = value;
                        return true;
                    }
                }
            case "vector2Array":
                {
                    var valueStr = GetAttribute(node, name);
                    if (valueStr == null || valueStr.length == 0) {
                        propValue.value = [];
                    } else {
                        var vectors:Array<Vector2> = [];
                        for (s in valueStr.split(" ")) {
                            var outVec:OutVector2 = {value: null};
                            if (ParseHelper.TryParseVector2(s, outVec)) {
                                vectors.push(outVec.value);
                            }
                        }
                        propValue.value = vectors;
                    }
                    return true;
                }
            case "vector3Array":
                {
                    var valueStr = GetAttribute(node, name);
                    if (valueStr == null || valueStr.length == 0) {
                        propValue.value = [];
                    } else {
                        var vectors:Array<Vector3> = [];
                        for (s in valueStr.split(" ")) {
                            var outVec:OutVector3 = {value: null};
                            if (ParseHelper.TryParseVector3(s, outVec)) {
                                vectors.push(outVec.value);
                            }
                        }
                        propValue.value = vectors;
                    }
                    return true;
                }
            case "vector2IntArray":
                {
                    var valueStr = GetAttribute(node, name);
                    if (valueStr == null || valueStr.length == 0) {
                        propValue.value = [];
                    } else {
                        var vectors:Array<Vector2Int> = [];
                        for (s in valueStr.split(" ")) {
                            var outVec:OutVector2Int = {value: null};
                            if (ParseHelper.TryParseVector2Int(s, outVec)) {
                                vectors.push(outVec.value);
                            }
                        }
                        propValue.value = vectors;
                    }
                    return true;
                }
            case "vector3IntArray":
                {
                    var valueStr = GetAttribute(node, name);
                    if (valueStr == null || valueStr.length == 0) {
                        propValue.value = [];
                    } else {
                        var vectors:Array<Vector3Int> = [];
                        for (s in valueStr.split(" ")) {
                            var outVec:OutVector3Int = {value: null};
                            if (ParseHelper.TryParseVector3Int(s, outVec)) {
                                vectors.push(outVec.value);
                            }
                        }
                        propValue.value = vectors;
                    }
                    return true;
                }
            default:
        }
        return false;
    }
    public static function TryToProperty(node:XmlNode, defaultNsp:String, propValue:{value:Dynamic}):Bool {
        var type = node.name;
        if (TryGetAttributeStruct(node, "value", type, propValue)) {
            return true;
        }
        if (TryGetAttributeVector(node, type, propValue)) {
            return true;
        }
        if (TryGetAttributeNullable(node, "value", "null", type, defaultNsp, propValue)) {
            return true;
        }
        propValue.value = null;
        return false;
    }

    public static function ConcatNodeParagraphs(node:XmlNode):String {
        var lineNodes = node.childNodes;
        var sb = new StringBuf();
        var first = true;
        for (i in 0...lineNodes.Count) {
            var lineNode = lineNodes[i];
            if (lineNode.name == "p") {
                if (!first) {
                    sb.add("\n");
                }
                first = false;
                sb.add(lineNodes[i].innerText);
            }
        }
        return sb.toString();
    }

    // PORT-NOTE: C# `string.IndexOfAny(char[])` helper.
    private static function indexOfAny(text:String, chars:Array<String>):Int {
        if (text == null) return -1;
        for (i in 0...text.length) {
            if (chars.indexOf(text.charAt(i)) >= 0) return i;
        }
        return -1;
    }
    // PORT-NOTE: C# `string.Split(char[])` helper.
    private static function splitAny(text:String, separators:Array<String>):Array<String> {
        if (text == null) return [];
        var result:Array<String> = [];
        var current = new StringBuf();
        for (i in 0...text.length) {
            var c = text.charAt(i);
            if (separators.indexOf(c) >= 0) {
                result.push(current.toString());
                current = new StringBuf();
            } else {
                current.add(c);
            }
        }
        result.push(current.toString());
        return result;
    }

    public static var xmlSpecialChars:Array<String> = ['<', '>', '&', "'", '"'];
}
