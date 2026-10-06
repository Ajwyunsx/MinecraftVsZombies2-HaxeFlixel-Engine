// PORT-NOTE: 验证用（不参与游戏构建）。工作包 F：十六进制颜色解析 + ParseHelper 严格解析的冒烟测试。
//
// ① ColorUtility.TryParseHtmlString：`#RRGGBB` / `#RRGGBBAA`（本 bug 的靶心）/ `#RGB` / `#RGBA` /
//    大小写 / 无 '#' / 非法输入 / 具名颜色 / 首尾空白。
// ② ColorUtility.ToHtmlStringRGB(A)：Unity 的四舍五入 + 大写两位十六进制（原实现是截断 + 小写）。
// ③ ParseHelper.TryParseInt/TryParseLong/TryParseFloat：.NET NumberStyles 的严格失败语义
//    （拒绝十六进制、尾随垃圾、溢出）。
// ④ 真实数据链路：读 GameContent 里真实的 Meta XML，把每个 <color> 节点走
//    XMLHelper.TryToProperty（= color 属性的真实解析路径），断言全部成功且取值正确。
//
// 运行：bash HaxePort/tools_build/check_color.sh --neko   （① ② ③）
//       bash HaxePort/tools_build/check_color.sh --cpp    （① ② ③ ④，与游戏同一目标）
package colorsmoke;

import mvz2logic.ParseHelper;
import mvz2logic.ParseHelper.OutFloat;
import mvz2logic.ParseHelper.OutInt;
import mvz2logic.ParseHelper.OutLong;
import unity.Color;
import unity.ColorUtility;

#if (cpp && !color_smoke_unit_only)
import mvz2.io.XMLHelper;
import system.xml.XmlNode;
#end

class ColorParseSmoke {
    private static var checks:Int = 0;
    private static var notes:Int = 0;
    private static var failures:Array<String> = [];

    public static function main():Void {
        section('① ColorUtility.TryParseHtmlString');
        checkHexColors();
        checkNamedColors();
        checkInvalid();
        section('② ColorUtility.ToHtmlStringRGB(A)');
        checkFormatting();
        section('③ ParseHelper 严格解析（.NET NumberStyles）');
        checkStrictParsers();
        #if cpp
            #if color_smoke_unit_only
            section('④ 真实 Meta XML 的 <color> 属性链路');
            note('已用 -D color_smoke_unit_only 跳过（该段要编译整个 mvz2.io/XMLHelper 依赖图，较慢）');
            #else
            section('④ 真实 Meta XML 的 <color> 属性链路');
            checkRealColorXml();
            #end
        #else
        section('④ 真实 Meta XML 的 <color> 属性链路');
        note('neko 下跳过（与工作包 A 相同的 mvz2.modding 代码生成限制），仅在 --cpp 下运行');
        #end

        section('汇总');
        info('检查项 $checks，失败 ${failures.length}，说明 $notes');
        for (f in failures)
            info('  FAIL ' + f);
        Sys.exit(failures.length == 0 ? 0 : 1);
    }

    // #region ① 十六进制
    static function expectHex(html:String, r:Float, g:Float, b:Float, a:Float, label:String):Void {
        var out:{value:Color} = {value: null};
        var ok = ColorUtility.TryParseHtmlString(html, out);
        checks++;
        if (!ok) {
            failures.push('$label：TryParseHtmlString(${q(html)}) 返回 false（期望 true）');
            return;
        }
        if (out.value == null) {
            failures.push('$label：TryParseHtmlString(${q(html)}) 返回 true 但颜色为 null');
            return;
        }
        var c = out.value;
        if (!near(c.r, r) || !near(c.g, g) || !near(c.b, b) || !near(c.a, a)) {
            failures.push('$label：${q(html)} → ${fmt(c)}（期望 ${fmt(new Color(r, g, b, a))}）');
        }
    }

    static function checkHexColors():Void {
        // 真实数据里出现过的写法（#RRGGBB / #RRGGBBAA / #RGB / 大小写混用）
        expectHex('#FF0000', 1, 0, 0, 1, '#RRGGBB 不透明红');
        expectHex('#FF0000FF', 1, 0, 0, 1, '#RRGGBBAA 不透明红');
        expectHex('#7F0000FF', 127 / 255, 0, 0, 1, 'mvz2:bloodColor（僵尸血）');
        expectHex('#00007FFF', 0, 0, 127 / 255, 1, 'mvz2:bloodColorCensored');
        expectHex('#FFAA00', 1, 170 / 255, 0, 1, 'mvz2:lightColor');
        expectHex('#7F0000', 127 / 255, 0, 0, 1, '缺省 alpha = FF');
        expectHex('#007fe3', 0, 127 / 255, 227 / 255, 1, '小写十六进制');
        expectHex('#ffAa00', 1, 170 / 255, 0, 1, '大小写混用');
        expectHex('#FFF', 1, 1, 1, 1, '#RGB 展开为 #FFFFFF');
        expectHex('#F00', 1, 0, 0, 1, '#RGB 展开为 #FF0000');
        expectHex('#FFF0', 1, 1, 1, 0, '#RGBA 展开为 #FFFFFF00');
        expectHex('#000F', 0, 0, 0, 1, '#RGBA 展开为 #000000FF');
        expectHex('  #FF0000  ', 1, 0, 0, 1, '首尾空白（Unity 先 Trim）');
        expectHex('#00000000', 0, 0, 0, 0, '全透明');
    }

    static function checkNamedColors():Void {
        expectHex('white', 1, 1, 1, 1, 'white');
        expectHex('WHITE', 1, 1, 1, 1, '具名颜色大小写不敏感');
        expectHex('black', 0, 0, 0, 1, 'black');
        expectHex('red', 1, 0, 0, 1, 'red');
        // 注意 HTML 的 green 是 #008000（与 Color.green 的 (0,1,0) 不同，Unity 表里就是这个值）
        expectHex('green', 0, 128 / 255, 0, 1, 'green = #008000');
        expectHex('grey', 128 / 255, 128 / 255, 128 / 255, 1, 'grey');
        expectHex('magenta', 1, 0, 1, 1, 'magenta');
        expectHex('transparent', 0, 0, 0, 0, 'transparent');
    }

    static function checkInvalid():Void {
        expectFail(null, 'null 字符串');
        expectFail('', '空串');
        expectFail('   ', '纯空白');
        expectFail('#', '只有 #');
        expectFail('#12', '长度 2');
        expectFail('#12345', '长度 5（非法长度）');
        expectFail('#1234567', '长度 7（非法长度）');
        expectFail('#123456789', '长度 9 + # 前缀（超过 9 字符上限）');
        expectFail('#GG0000', '非十六进制字符');
        expectFail('#FF00GG', '非十六进制字符（后段）');
        expectFail('#ZZZZ', '非十六进制字符（4 位）');
        expectFail('FF0000', '无 # 前缀 → 不按十六进制解析（Unity 语义）');
        expectFail('7F0000FF', '无 # 前缀的 8 位');
        expectFail('whiteish', '表外具名颜色');
        expectFail('#FF 0000', '含空格');
    }

    static function expectFail(html:String, label:String):Void {
        var out:{value:Color} = {value: new Color(9, 9, 9, 9)};
        var ok = ColorUtility.TryParseHtmlString(html, out);
        checks++;
        if (ok)
            failures.push('$label：TryParseHtmlString(${q(html)}) 返回 true（期望 false），得到 ${fmt(out.value)}');
    }
    // #endregion

    // #region ② 格式化
    static function expectFormat(color:Color, rgba:String, label:String):Void {
        checks++;
        var gotRgba = ColorUtility.ToHtmlStringRGBA(color);
        if (gotRgba != rgba)
            failures.push('$label：ToHtmlStringRGBA → $gotRgba（期望 $rgba）');
        checks++;
        var gotRgb = ColorUtility.ToHtmlStringRGB(color);
        var wantRgb = rgba.substr(0, 6);
        if (gotRgb != wantRgb)
            failures.push('$label：ToHtmlStringRGB → $gotRgb（期望 $wantRgb）');
    }

    static function checkFormatting():Void {
        expectFormat(new Color(1, 1, 1, 1), 'FFFFFFFF', '白色');
        expectFormat(new Color(0, 0, 0, 0), '00000000', '透明黑');
        expectFormat(new Color(127 / 255, 0, 0, 1), '7F0000FF', 'bloodColor 往返');
        expectFormat(new Color(0.5, 0.5, 0.5, 1), '808080FF', '0.5 → 128（四舍五入）');
        expectFormat(new Color(1, 235 / 255, 4 / 255, 1), 'FFEB04FF', 'Color.yellow');
        // Unity 的 bug 770904：1.0 附近截断会得到 FE，必须四舍五入成 FF
        expectFormat(new Color(0.9999999, 0, 0, 1), 'FF0000FF', '截断会退化成 FE');
        expectFormat(new Color(1.5, -0.5, 0, 2), 'FF0000FF', '超范围分量被 Clamp 到 0..255');
    }
    // #endregion

    // #region ③ ParseHelper
    static function expectInt(text:String, expectOk:Bool, expect:Int, label:String):Void {
        var out:OutInt = {value: -12345};
        var ok = ParseHelper.TryParseInt(text, out);
        checks++;
        if (ok != expectOk || (expectOk && out.value != expect)) {
            failures.push('$label：TryParseInt(${q(text)}) → $ok / ${out.value}（期望 $expectOk / $expect）');
        }
    }

    static function expectLong(text:String, expectOk:Bool, expect:String, label:String):Void {
        var out:OutLong = {value: haxe.Int64.ofInt(-12345)};
        var ok = ParseHelper.TryParseLong(text, out);
        checks++;
        if (ok != expectOk || (expectOk && out.value != haxe.Int64.parseString(expect))) {
            failures.push('$label：TryParseLong(${q(text)}) → $ok / ${out.value}（期望 $expectOk / $expect）');
        }
    }

    static function expectFloat(text:String, expectOk:Bool, expect:Float, label:String):Void {
        var out:OutFloat = {value: -12345};
        var ok = ParseHelper.TryParseFloat(text, out);
        checks++;
        if (ok != expectOk || (expectOk && !near(out.value, expect, 1e-9))) {
            failures.push('$label：TryParseFloat(${q(text)}) → $ok / ${out.value}（期望 $expectOk / $expect）');
        }
    }

    static function checkStrictParsers():Void {
        // .NET NumberStyles.Integer：首尾空白 / 前导符号 / 十进制，溢出即 false
        expectInt('5', true, 5, '十进制整数');
        expectInt('-5', true, -5, '负号');
        expectInt('+5', true, 5, '正号');
        expectInt(' 5 ', true, 5, '首尾空白');
        expectInt('007', true, 7, '前导零');
        expectInt('2147483647', true, 2147483647, 'Int32.MaxValue');
        expectInt('-2147483648', true, -2147483648, 'Int32.MinValue');
        expectInt('2147483648', false, 0, 'Int32 上溢 → false');
        expectInt('-2147483649', false, 0, 'Int32 下溢 → false');
        expectInt('0x10', false, 0, '拒绝十六进制（C# NumberStyles.Integer 不认）');
        expectInt('12abc', false, 0, '拒绝尾随垃圾');
        expectInt('1.0', false, 0, '拒绝小数');
        expectInt('', false, 0, '空串');
        expectInt('  ', false, 0, '纯空白');
        expectInt('abc', false, 0, '非数字');
        expectInt('+', false, 0, '只有符号');

        expectLong('1234567890123', true, '1234567890123', 'Int64 一般值');
        expectLong('9223372036854775807', true, '9223372036854775807', 'Int64.MaxValue');
        expectLong('-9223372036854775808', true, '-9223372036854775808', 'Int64.MinValue');
        expectLong('9223372036854775808', false, '0', 'Int64 上溢 → false');
        expectLong('-9223372036854775809', false, '0', 'Int64 下溢 → false');
        expectLong('0x10', false, '0', '拒绝十六进制');
        expectLong('12abc', false, '0', '拒绝尾随垃圾');
        expectLong('', false, '0', '空串');

        // .NET NumberStyles.Float：小数 / 指数 / 首尾空白，拒绝十六进制与尾随垃圾
        expectFloat('1.5', true, 1.5, '小数');
        expectFloat('-1.5', true, -1.5, '负小数');
        expectFloat('.5', true, 0.5, '省略整数部分');
        expectFloat('1.', true, 1.0, '省略小数部分');
        expectFloat('1e3', true, 1000, '指数');
        expectFloat('-1.5e-2', true, -0.015, '负指数');
        expectFloat(' 2 ', true, 2, '首尾空白');
        expectFloat('1.5x', false, 0, '拒绝尾随垃圾');
        expectFloat('0x10', false, 0, '拒绝十六进制');
        expectFloat('1,5', false, 0, '拒绝逗号小数点');
        expectFloat('', false, 0, '空串');
        expectFloat('1e400', false, 0, 'Single 上溢 → false（同 .NET/Mono）');
        expectFloat('NaN', false, 0, '拒绝 NaN 字面量');
        expectFloat('Infinity', false, 0, '拒绝 Infinity 字面量');
    }
    // #endregion

    // #region ④ 真实数据
    #if (cpp && !color_smoke_unit_only)
    static function checkRealColorXml():Void {
        var path = assetPath('GameContent/Assets/mvz2/metas/entities.xml');
        if (path == null) {
            failures.push('找不到 entities.xml');
            return;
        }
        var text = sys.io.File.getContent(path);
        var doc = XMLHelper.ReadXmlDocument(text);
        var nodes = doc.documentElement.selectNodes('//color');
        var expectedTotal = countOccurrences(text, '<color ');
        checks++;
        if (nodes.Count != expectedTotal)
            failures.push('XML 里 <color> 节点数 ${nodes.Count} 与原文出现次数 $expectedTotal 不一致');
        info('entities.xml：<color> 节点 ${nodes.Count} 个');

        var failed = 0;
        var byName = new Map<String, Color>();
        var firstHex = new Map<String, String>();
        for (i in 0...nodes.Count) {
            var node:XmlNode = nodes[i];
            var out:{value:Dynamic} = {value: null};
            if (!XMLHelper.TryToProperty(node, 'mvz2', out) || out.value == null) {
                failed++;
                failures.push('<color name="${XMLHelper.GetAttribute(node, 'name')}" value="${XMLHelper.GetAttribute(node, 'value')}"/> '
                    + '解析失败（TryToProperty 返回 false）');
            } else if (node.attributes['name'] != null) {
                var name = node.attributes['name'].value;
                // 同名属性在 entities.xml 里出现多次（每个实体一份），这里以**第一次**出现为准断言。
                if (!byName.exists(name)) {
                    byName.set(name, cast out.value);
                    firstHex.set(name, XMLHelper.GetAttribute(node, 'value'));
                }
            }
        }
        checks++;
        if (failed > 0)
            failures.push('$failed 个 <color> 节点解析失败');
        info('entities.xml：<color> 节点 ${nodes.Count} 个，失败 $failed 个，属性名 ${Lambda.count(byName)} 种');

        expectRealColor(byName, firstHex, 'mvz2:bloodColor', 127 / 255, 0, 0, 1);
        expectRealColor(byName, firstHex, 'mvz2:bloodColorCensored', 0, 0, 127 / 255, 1);
        expectRealColor(byName, firstHex, 'mvz2:tint', 1, 1, 1, 1);
        expectRealColor(byName, firstHex, 'mvz2:lightColor', 1, 170 / 255, 0, 1);

        // gradient：<colorKeys><key hex="#RRGGBB" time="0.35"/></colorKeys>，走 XMLHelper.ToGradient
        // → ToGradientColorKey → ColorUtility（hex 属性的真实解析路径）。
        var gradPath = assetPath('GameContent/Assets/mvz2/metas/fragments.xml');
        if (gradPath == null) {
            failures.push('找不到 fragments.xml');
            return;
        }
        var gradDoc = XMLHelper.ReadXmlDocument(sys.io.File.getContent(gradPath));
        var keyNodes = gradDoc.documentElement.selectNodes('//key');
        var hexCount = 0;
        var gradFailed = 0;
        for (i in 0...keyNodes.Count) {
            var node:XmlNode = keyNodes[i];
            var hex = XMLHelper.GetAttribute(node, 'hex');
            if (hex != null) {
                hexCount++;
                var out:{value:Color} = {value: null};
                if (!ColorUtility.TryParseHtmlString(hex, out))
                    gradFailed++;
            }
        }
        checks++;
        if (gradFailed > 0)
            failures.push('fragments.xml 的 <key hex=…> 里有 $gradFailed 个解析失败（共 $hexCount 个）');
        info('fragments.xml：<key> ${keyNodes.Count} 个（其中 hex= $hexCount 个，失败 $gradFailed）');

        var fragment = gradDoc.documentElement.selectSingleNode('fragment');
        checks++;
        if (fragment == null) {
            failures.push('找不到 fragments.xml 的 <fragment> 节点');
        } else {
            var gradient = XMLHelper.ToGradient(fragment);
            if (gradient == null) {
                failures.push('ToGradient(fragment) 返回 null');
            } else {
                checks++;
                if (gradient.colorKeys.length != 3)
                    failures.push('ToGradient(dispenser).colorKeys.length=${gradient.colorKeys.length}（期望 3）');
                else
                    expectGradientKey(gradient, 0, 0x4F / 255, 0.35, 'dispenser.colorKeys[0]');
                checks++;
                if (gradient.alphaKeys.length != 1)
                    failures.push('ToGradient(dispenser).alphaKeys.length=${gradient.alphaKeys.length}（期望默认 1）');
                info('ToGradient(dispenser)：colorKeys=${gradient.colorKeys.length}，首键 ${fmt(gradient.colorKeys[0].color)} @${gradient.colorKeys[0].time}');
            }
        }
    }

    static function expectGradientKey(gradient:unity.Gradient, index:Int, r:Float, time:Float, label:String):Void {
        checks++;
        var key = gradient.colorKeys[index];
        if (!near(key.time, time))
            failures.push('$label 时间 ${key.time}（期望 $time）');
        if (!near(key.color.r, r) || !near(key.color.g, r) || !near(key.color.b, r))
            failures.push('$label 颜色 ${fmt(key.color)}（期望灰阶 $r）');
    }

    static function expectRealColor(map:Map<String, Color>, hexes:Map<String, String>, key:String, r:Float, g:Float, b:Float, a:Float):Void {
        checks++;
        var c = map.get(key);
        if (c == null) {
            failures.push('真实数据缺少颜色属性 $key（XML 里有但解析后没进属性表）');
            return;
        }
        if (!near(c.r, r) || !near(c.g, g) || !near(c.b, b) || !near(c.a, a))
            failures.push('$key（${hexes.get(key)}）取值 ${fmt(c)}（期望 ${fmt(new Color(r, g, b, a))}）');
    }

    static function assetPath(relative:String):Null<String> {
        var prefixes = ['', 'assets/', 'HaxePort/assets/', '../assets/', '../../assets/', '../../../assets/'];
        for (p in prefixes) {
            var candidate = p + relative;
            if (sys.FileSystem.exists(candidate))
                return candidate;
        }
        // 从可执行文件位置向上找 assets 目录
        var dir = new haxe.io.Path(Sys.programPath()).dir;
        var cur = dir;
        for (_ in 0...4) {
            var candidate = cur + '/assets/' + relative;
            if (sys.FileSystem.exists(candidate))
                return candidate;
            cur += '/..';
        }
        return null;
    }
    #end

    static function countOccurrences(text:String, needle:String):Int {
        var count = 0;
        var index = 0;
        while (true) {
            index = text.indexOf(needle, index);
            if (index < 0)
                break;
            count++;
            index += needle.length;
        }
        return count;
    }
    // #endregion

    // #region 工具
    static function near(a:Float, b:Float, ?eps:Float = 1e-6):Bool {
        return Math.abs(a - b) <= eps;
    }
    static function fmt(c:Color):String {
        return 'RGBA(${c.r}, ${c.g}, ${c.b}, ${c.a})';
    }
    static function q(s:String):String {
        return s == null ? 'null' : '"$s"';
    }
    static function section(name:String):Void {
        Sys.println('---- $name ----');
    }
    static function info(msg:String):Void {
        Sys.println('[info] $msg');
    }
    static function note(msg:String):Void {
        notes++;
        Sys.println('[note] $msg');
    }
    // #endregion
}
