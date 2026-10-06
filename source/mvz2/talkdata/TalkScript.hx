// Ported from: Assets/Scripts/MVZ2/Talks/Data/TalkScript.cs
package mvz2.talkdata;

// PORT-NOTE: C# 字段名 `function` 是 Haxe 关键字，改名为 functionName（语义不变）。
class TalkScript {
    public var functionName:String;
    public var arguments:Array<String>;

    public function new(functionName:String, ...arguments:String) {
        this.functionName = functionName;
        this.arguments = arguments;
    }


    private static function trimScriptChars(str:String):String {
        if (str == null)
            return null;
        var start = 0;
        var end = str.length;
        while (start < end) {
            var c = str.charCodeAt(start);
            if (c != 32 && c != 59)
                break;
            start++;
        }
        while (end > start) {
            var c = str.charCodeAt(end - 1);
            if (c != 32 && c != 59)
                break;
            end--;
        }
        return str.substring(start, end);
    }

    // PORT-NOTE: C# 的 out 参数在 Haxe 中改为返回值（解析失败返回 null）。
    public static function TryParse(str:String):TalkScript {
        // PORT-NOTE: C# 为 str.Trim(' ', ';')；Haxe 的 StringTools.ltrim/rtrim 不支持自定义字符集，这里自行实现。
        str = trimScriptChars(str);
        var strings = str.split(" ");
        if (strings.length <= 0)
            return null;
        var func = strings[0];
        var args:Array<String>;
        if (strings.length > 1) {
            args = strings.slice(1);
        } else {
            args = [];
        }
        return new TalkScript(func, ...args);
    }
    public static function Parse(str:String):TalkScript {
        var parsed = TryParse(str);
        if (parsed != null) {
            return parsed;
        }
        throw 'Invalid TalkScript ${str}.';
    }
    public static function ParseArray(str:String):Array<TalkScript> {
        if (str == null) return null;
        return str.split(";").map(s -> Parse(s));
    }
    public static function FromArrayXmlNode(node:system.xml.XmlNode):Array<TalkScript> {
        var scripts:Array<TalkScript> = [];
        var childNodes = node.ChildNodes;
        for (i in 0...childNodes.Count) {
            var child = childNodes.getAt(i);
            if (child.Name == "script") {
                var script = TryParse(child.InnerText);
                if (script != null) {
                    scripts.push(script);
                }
            }
        }
        return scripts;
    }
    public function toString():String {
        if (arguments == null)
            return functionName;
        else
            return [functionName].concat(arguments).join(" ");
    }
}
