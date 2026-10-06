// Ported from: Assets/Scripts/MVZ2/Metas/Command/CommandMeta.cs
package mvz2.metas;

import mvz2.io.XMLHelper;
import mvz2logic.commands.ICommandParameterMeta;
import mvz2logic.definitions.LogicDefinitionTypes;
import mvz2logic.localization.LogicStrings;
import pvzengine.definitions.EngineDefinitionTypes;
import system.xml.XmlNode;
using mvz2.io.XMLHelper;  // EXTUSING

class CommandMetaParam implements ICommandParameterMeta {
	public function new() { } // CTORFIX
    // PORT-NOTE: ICommandParameterMeta 以属性 (get, never) 声明接口成员，Haxe 中必须用属性实现，
    // 不能再用普通字段；这里保留原字段名，改为只读属性 + 私有后端字段。
    public var Name(get, never):String;
    public var Type(get, never):String;
    public var IDType(get, never):String;
    public var Optional(get, never):Bool;
    public var Description(get, never):String;

    inline function get_Name():String return nameValue;
    inline function get_Type():String return typeValue;
    inline function get_IDType():String return idTypeValue;
    inline function get_Optional():Bool return optionalValue;
    inline function get_Description():String return descriptionValue;

    private var nameValue:String = "";
    private var typeValue:String = "";
    private var idTypeValue:String = "";
    private var optionalValue:Bool = false;
    private var descriptionValue:String = "";

    public static function FromXmlNode(node:XmlNode, defaultNsp:String):CommandMetaParam {
        var name = XMLHelper.GetAttribute(node, "name");
        if (name == null) name = "";
        var type = XMLHelper.GetAttribute(node, "type");
        if (type == null) type = "";
        var idType = XMLHelper.GetAttribute(node, "idType");
        if (idType == null) idType = "";
        var optionalAttr = XMLHelper.GetAttributeBool(node, "optional");
        var optional = optionalAttr != null ? optionalAttr : false;
        var description = node.InnerText;
        var param = new CommandMetaParam();
        param.nameValue = name;
        param.typeValue = type;
        param.idTypeValue = idType;
        param.optionalValue = optional;
        param.descriptionValue = description;
        return param;
    }

    public function GetName():String return Name;
    public function GetDescription():String return Description;
    public function GetTypeName():String {
        switch (Type) {
            case TYPE_COMMAND:
                return LogicStrings.PARAMETER_TYPE_COMMAND;
            case TYPE_ID:
                return LogicStrings.PARAMETER_TYPE_ID;
            case TYPE_BOOL:
                return LogicStrings.PARAMETER_TYPE_BOOLEAN;
            case TYPE_INT:
                return LogicStrings.PARAMETER_TYPE_INT;
            case TYPE_FLOAT:
                return LogicStrings.PARAMETER_TYPE_FLOAT;
            default:
        }
        return LogicStrings.PARAMETER_TYPE_UNKNOWN;
    }
    public static inline var TYPE_BOOL:String = "bool";
    public static inline var TYPE_INT:String = "int";
    public static inline var TYPE_FLOAT:String = "float";
    public static inline var TYPE_COMMAND:String = "command";
    public static inline var TYPE_ID:String = "id";

    public static inline var ID_TYPE_ENTITY:String = EngineDefinitionTypes.ENTITY;
    public static inline var ID_TYPE_SEED:String = EngineDefinitionTypes.SEED;
    public static inline var ID_TYPE_ARMOR:String = EngineDefinitionTypes.ARMOR;
    public static inline var ID_TYPE_STAGE:String = EngineDefinitionTypes.STAGE;
    public static inline var ID_TYPE_AREA:String = EngineDefinitionTypes.AREA;

    public static inline var ID_TYPE_ARMOR_SLOT:String = LogicDefinitionTypes.ARMOR_SLOT;
    public static inline var ID_TYPE_ARTIFACT:String = LogicDefinitionTypes.ARTIFACT;
    public static inline var ID_TYPE_I_ZOMBIE_LAYOUT:String = LogicDefinitionTypes.I_ZOMBIE_LAYOUT;

    public static inline var ID_TYPE_UNLOCK:String = "unlock";
    public static inline var ID_TYPE_CHAPTER_TRANSITION:String = "chapter_transition";
}
