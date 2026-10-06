import io

# TalkScript: C# str.Trim(' ', ';') -> custom trim (Haxe StringTools.ltrim/rtrim take no char set)
p = 'source/mvz2/talkdata/TalkScript.hx'
s = io.open(p, encoding='utf-8').read()
old = '''        str = StringTools.ltrim(str, " ;");
        str = StringTools.rtrim(str, " ;");'''
new = '''        // PORT-NOTE: C# \u4e3a str.Trim(' ', ';')\uff1bHaxe \u7684 StringTools.ltrim/rtrim \u4e0d\u652f\u6301\u81ea\u5b9a\u4e49\u5b57\u7b26\u96c6\uff0c\u8fd9\u91cc\u81ea\u884c\u5b9e\u73b0\u3002
        str = trimScriptChars(str);'''
assert old in s, 'trim'
s = s.replace(old, new)
helper = '''
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
'''
marker = '    // PORT-NOTE: C# \u7684 out \u53c2\u6570\u5728 Haxe \u4e2d\u6539\u4e3a\u8fd4\u56de\u503c'
assert marker in s, 'marker'
s = s.replace(marker, helper + '\n' + marker)
io.open(p, 'w', encoding='utf-8', newline='').write(s)
print('TalkScript trim fixed')
