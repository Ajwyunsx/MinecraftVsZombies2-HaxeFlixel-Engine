// Ported from: Assets/Scripts/MVZ2/Metas/Stage/StageMetaTalk.cs
package mvz2.metas;

import mvz2.io.XMLHelper;
import mvz2logic.games.IGlobalSaveData;
import mvz2logic.level.IStageMeta.IStageTalkMeta;
import pvzengine.Log;
import pvzengine.NamespaceID;
import system.xml.XmlNode;

using mvz2.saves.MVZ2SaveExt;
using mvz2.io.XMLHelper;  // EXTUSING
using pvzengine.PropertyKeyHelper;  // EXTUSING

class StageMetaTalk implements IStageTalkMeta {
    // PORT-NOTE: IStageTalkMeta 以只读属性（get, never）声明接口成员，Haxe 中必须用属性实现，
    // 故 C# 的 public 字段改为「只读属性 + 私有后端字段」。
    public var Type(get, never):String;
    public var Value(get, never):NamespaceID;
    public var StartSection(get, never):Int;
    public var StartCondition(get, never):XMLConditionList;
    public var RepeatCondition(get, never):XMLConditionList;

    inline function get_Type():String return typeValue;
    inline function get_Value():NamespaceID return valueValue;
    inline function get_StartSection():Int return startSectionValue;
    inline function get_StartCondition():XMLConditionList return startConditionValue;
    inline function get_RepeatCondition():XMLConditionList return repeatConditionValue;

    private var typeValue:String = "";
    private var valueValue:NamespaceID;
    private var startSectionValue:Int;
    private var startConditionValue:XMLConditionList;
    private var repeatConditionValue:XMLConditionList;

    private function new(value:NamespaceID) {
        valueValue = value;
    }
    public static function FromXmlNode(node:XmlNode, defaultNsp:String):StageMetaTalk {
        var value = XMLHelper.GetAttributeNamespaceID(node, "value", defaultNsp);
        if (!NamespaceID.IsValid(value)) {
            Log.LogError('The value of a StageMetaTalk is invalid.');
            return null;
        }
        var type = XMLHelper.GetAttribute(node, "type");
        if (type == null) type = "";
        var startSectionAttr = XMLHelper.GetAttributeInt(node, "section");
        var startSection = startSectionAttr != null ? startSectionAttr : 0;

        var startCondition:XMLConditionList = null;
        var conditionNode = node["conditions"];
        if (conditionNode != null) {
            startCondition = XMLConditionList.FromXmlNode(conditionNode, defaultNsp);
        }

        var repeatCondition:XMLConditionList = null;
        var repeatConditionNode = node["repeat"];
        if (repeatConditionNode != null) {
            repeatCondition = XMLConditionList.FromXmlNode(repeatConditionNode, defaultNsp);
        }
        var talk = new StageMetaTalk(value);
        talk.typeValue = type;
        talk.startSectionValue = startSection;
        talk.startConditionValue = startCondition;
        talk.repeatConditionValue = repeatCondition;
        return talk;
    }
    public function CanStartTalk(save:IGlobalSaveData):Bool {
        if (StartCondition == null)
            return true;
        return save.MeetsXMLConditions(StartCondition);
    }
    public function ShouldRepeat(save:IGlobalSaveData):Bool {
        if (RepeatCondition == null)
            return false;
        return save.MeetsXMLConditions(RepeatCondition);
    }
    public static inline var TYPE_START:String = "start";
    public static inline var TYPE_END:String = "end";
    public static inline var TYPE_MAP:String = "map";
}
