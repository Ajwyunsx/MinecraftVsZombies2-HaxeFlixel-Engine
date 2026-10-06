package mvz2.almanacs;

import mvz2.managers.MainManager;
import mvz2.metas.AlmanacVariable;
import mvz2.metas.AlmanacVariableContext;
import pvzengine.NamespaceID;
import mvz2.managers.ResourceManager;

// Ported from: Assets/Scripts/MVZ2/Almanac/DescriptionPropReplacer.cs
// PORT-NOTE: System.Text.RegularExpressions → haxe EReg. EReg does not support non-capturing
// groups, so the attribute pattern uses a plain capturing group instead (group indices shift by
// one and are handled accordingly).
class DescriptionPropReplacer {

    public function new(mainManager:MainManager) {
        main = mainManager;
    }

    public function Replace(description:String, context:AlmanacVariableContext):String {
        if (description == null || description.length == 0)
            return description;

        // C#: PropRegex.Replace(description, m => ReplaceMatch(m, context))
        return PropRegex.map(description, m -> ReplaceMatch(m, context));
    }

    private function ReplaceMatch(match:EReg, context:AlmanacVariableContext):String {
        // 获取可选属性，应用默认值
        var variable = GetMatchVariable(match, context);
        if (variable == null) // 变量不存在。
            return match.matched(0);
        return variable.GetValueString(context);
    }
    private function GetMatchVariable(match:EReg, context:AlmanacVariableContext):AlmanacVariable {
        var attrs = match.matched(1);
        var props = ParseAttributes(attrs);

        if (props.exists("local") && props.get("local") != null && props.get("local").length > 0) {
            return context.currentAlmanacEntry.GetLocalVariable(props.get("local"));
        } else if (props.exists("id")) {
            var outValue:{value:NamespaceID} = {value: null};
            if (NamespaceID.TryParse(props.get("id"), main.BuiltinNamespace, outValue)) {
                return context.main.ResourceManager.GetAlmanacGlobalVariable(outValue.value);
            }
        }
        return null;
    }

    /// <summary>
    /// 将属性字符串解析为字典，支持双引号和单引号，键值对之间空白分隔
    /// 示例：name="abc" multiplier='0.5' target=xyz
    /// </summary>
    private function ParseAttributes(attrString:String):Map<String, String> {
        var dict:Map<String, String> = new Map();
        // 正则匹配 key="value" 或 key='value' 或 key=value（无引号值，不含空白）
        var attrRegex = new EReg("(\\w+)\\s*=\\s*(\"([^\"]*)\"|'([^']*)'|([^\\s>]+))", "");
        var rest = attrString;
        while (attrRegex.match(rest)) {
            var m = attrRegex;
            var key = m.matched(1);
            var value = m.matched(3).length > 0 ? m.matched(3) :
                        (m.matched(4).length > 0 ? m.matched(4) : m.matched(5));
            // PORT-NOTE: C# uses StringComparer.OrdinalIgnoreCase; keys are lower-cased here.
            dict.set(key.toLowerCase(), value);
            var end = m.matchedPos();
            rest = rest.substr(end.pos + end.len);
        }
        return dict;
    }
    private var main:MainManager;
    // PORT-NOTE: EReg cannot be static readonly in the same way; a module-level instance is used.
    private static var PropRegex(get, never):EReg;
    static function get_PropRegex():EReg {
        return new EReg("<var\\s+([^>]+?)\\s*/>", "i");
    }
}
