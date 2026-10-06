// PORT-NOTE: 验证用（不参与游戏构建）。工作包 A 的 system.xml 语义冒烟测试：
//   ① 用内联 XML 校验 XmlNode/XmlDocument/XmlAttribute/XmlAttributeCollection/XmlNodeList/XmlReader
//      与 .NET 的等价语义；
//   ② 复现 ResourceManager.LoadSingleMetaList("achievements") 的完整链路
//      （TextAsset.bytes → MemoryStream → XMLHelper.ReadXmlDocumentFromStream →
//        MetaXMLParser.LoadMetaList → AchievementMetaList.FromXmlNode）；
//   ③ 把全部 38 个 "Meta" 标签资源走同一条链，确认不再抛异常。
//
// 运行：bash HaxePort/tools_build/check_xml.sh --neko   （① + ②）
//       bash HaxePort/tools_build/check_xml.sh --cpp    （① + ② + ③，与游戏同一目标）
//
// PORT-NOTE: ③ 与 ② 的真实分派（MetaXMLParser.LoadMetaList / TalkMeta）只在 cpp 目标下编译。
// 原因是**与工作包 A 无关的既有阻塞**：只要类型到 mvz2.modding.ModResource（会连带
// MVZ2 的 UI/Manager 层），neko 代码生成就报
// `Error: Field hashing conflict GetLocalizedStringPlural and _id`
// （mvz2/localization/LanguageManager.hx 的字段表冲突；最小复现：
//   haxe -cp source ... -main <trivial> -neko x.n --macro "include('mvz2.localization',true)"）。
// neko 目标下 ② 退化为直接调用 MetaXMLParser 在 "achievements" 分支里调用的同一个叶子方法
// （AchievementMetaList.FromXmlNode），其余环节（资源定位、字节流、XML 解析、成就元数据解析）
// 完全一致。
package xmlsmoke;

import mvz2.io.XMLHelper;
import mvz2.metas.AchievementMeta;
import mvz2.metas.AchievementMetaList;
import pvzengine.NamespaceID;
import system.io.MemoryStream;
import system.xml.XmlDocument;
import system.xml.XmlNode;
import system.xml.XmlNodeType;
import unity.TextAsset;
import unity.addressableassets.Addressables;
import unity.addressableassets.IResourceLocator;
import unity.addressableassets.ResourceLocation;

#if cpp
import mvz2.metas.MetaXMLParser;
import mvz2.modding.ModResource;
import mvz2.talkdata.TalkMeta;
#end

class XmlSmokeTest {
    private static var checks:Int = 0;
    private static var notes:Int = 0;
    private static var failures:Array<String> = [];

    public static function main():Void {
        section('① .NET XmlNode 语义（内联 XML）');
        checkSemantics();

        section('② 目标链：LoadSingleMetaList("achievements")');
        checkAchievementsChain();

        #if cpp
        section('③ 全量：38 个 Meta 资源走同一条链');
        checkAllMetaResources();
        #else
        section('③ 全量：38 个 Meta 资源');
        note('neko 代码生成被 LanguageManager 的字段表冲突阻塞（与工作包 A 无关），本段仅在 --cpp 下运行');
        #end

        section('汇总');
        info('检查项 $checks，失败 ${failures.length}，说明 $notes');
        for (f in failures)
            info('  FAIL ' + f);
        Sys.exit(failures.length == 0 ? 0 : 1);
    }

    // #region ① 语义
    static function checkSemantics():Void {
        // .NET: XmlDocument.LoadXml/Load 默认 PreserveWhitespace=false，格式化用的纯空白文本节点不进 DOM。
        var doc = XMLHelper.ReadXmlDocument("<root>\n    <a>1</a>\n    <b/>\n</root>");
        var root = doc.documentElement;
        check(root != null, 'documentElement != null');
        check(root != null && root.Name == 'root', 'root.Name == "root"（实际 ${nameOf(root)}）');
        check(root.childNodes.Count == 2, '纯空白子节点已剔除：root.ChildNodes.Count=${root.childNodes.Count}（期望 2）');
        checkNames(root, ['a', 'b'], 'root.ChildNodes 只剩元素');
        check(root.InnerText == '1', 'root.InnerText=${q(root.InnerText)}（期望 "1"，不含换行缩进）');
        check(root['a'] != null && root['a'].InnerText == '1', 'node["a"] 按名取第一个子元素');
        check(root['zzz'] == null, 'node["zzz"] 未命中返回 null（对齐 .NET XmlNode.this[string]）');
        check(root.firstChild != null && root.firstChild.Name == 'a', 'FirstChild 跳过空白文本节点');
        check(root.lastChild != null && root.lastChild.Name == 'b', 'LastChild 跳过空白文本节点');
        check(root.nodeType == XmlNodeType.Element, 'nodeType Element（实际 ${root.nodeType}）');
        check(doc.documentElement.nodeType == XmlNodeType.Element, 'documentElement.nodeType == Element');

        // .NET: 有意义的文本节点保留（混合内容）。
        var mixed = XMLHelper.ReadXmlDocument('<a>hello <b>x</b> world</a>').documentElement;
        check(mixed.childNodes.Count == 3, '混合内容保留文本节点：Count=${mixed.childNodes.Count}（期望 3）');
        checkNames(mixed, ['#text', 'b', '#text'], '混合内容子节点名（.NET XmlNode.Name 常量）');
        check(mixed.childNodes[0].nodeType == XmlNodeType.Text, '文本节点 nodeType == Text');
        check(mixed.childNodes[0].value == 'hello ' && mixed.childNodes[2].value == ' world',
            '文本节点 Value 可读（${q(mixed.childNodes[0].value)} / ${q(mixed.childNodes[2].value)}）');
        check(mixed.InnerText == 'hello x world', 'InnerText=${q(mixed.InnerText)}（期望 "hello x world"）');

        // .NET: XMLHelper.ReadXmlDocument 设了 IgnoreComments=true → 注释不进 DOM。
        var noComment = XMLHelper.ReadXmlDocument('<r><!-- c --><i/></r>').documentElement;
        check(noComment.childNodes.Count == 1, 'IgnoreComments=true 时注释被剔除：Count=${noComment.childNodes.Count}（期望 1）');
        // .NET: 默认 IgnoreComments=false → 注释保留，Name == "#comment"。
        var withComment = XmlDocument.parse("<r>\n  <!-- c -->\n  <i/>\n</r>").documentElement;
        check(withComment.childNodes.Count == 2, '默认保留注释：Count=${withComment.childNodes.Count}（期望 2：注释 + 元素）');
        checkNames(withComment, ['#comment', 'i'], '注释节点名 == "#comment"');
        check(withComment.childNodes[0].nodeType == XmlNodeType.Comment, '注释 nodeType == Comment');
        check(withComment.InnerText == '', '注释不参与 InnerText（实际 ${q(withComment.InnerText)}）');
        // 注释混在列表里时不能影响按下标遍历（C# 的 IgnoreComments=true 会把它剔除）
        var commented = XMLHelper.ReadXmlDocument('<r>\n  <!-- Lane 1 -->\n  <i/>\n  <!-- Lane 2 -->\n  <i/>\n</r>').documentElement;
        check(commented.childNodes.Count == 2, '列表里的注释不影响 ChildNodes.Count：${commented.childNodes.Count}（期望 2）');

        // .NET: XML 声明（ProcessingInstruction 节点）不影响 documentElement。
        var declared = XmlDocument.parse('<?xml version="1.0" encoding="utf-8"?>\n<r><i/></r>');
        check(declared.documentElement != null && declared.documentElement.Name == 'r',
            '带 XML 声明时 documentElement 仍是 <r>');
        check(declared.childNodes.Count == 2, '声明的 NodeType 映射正常，文档子节点数=${declared.childNodes.Count}（期望 2）');
        check(declared.childNodes[0].nodeType == XmlNodeType.ProcessingInstruction,
            '声明 nodeType == ProcessingInstruction（实际 ${declared.childNodes[0].nodeType}）');
        check(declared.childNodes[0].Name == 'xml', '声明节点 Name=${q(declared.childNodes[0].Name)}（期望 "xml"）');

        // 属性：.NET XmlAttributeCollection 按名取值，缺失返回 null。
        var el = XMLHelper.ReadXmlDocument('<r k="1" j="2"/>').documentElement;
        check(el.attributes.Count == 2, 'Attributes.Count=${el.attributes.Count}（期望 2）');
        check(XMLHelper.GetAttribute(el, 'k') == '1' && XMLHelper.GetAttribute(el, 'j') == '2', '属性按名读取');
        check(XMLHelper.GetAttribute(el, 'zzz') == null, '缺失属性返回 null');
        check(XMLHelper.HasAttribute(el, 'k') && !XMLHelper.HasAttribute(el, 'zzz'), 'HasAttribute');
        var attr = el.attributes['k'];
        check(attr != null && attr.Name == 'k' && attr.Value == '1', 'XmlAttribute.Name/Value');
        attr.Value = '9';
        check(XMLHelper.GetAttribute(el, 'k') == '9', '.NET XmlAttribute.Value setter 写回文档（实际 ${q(XMLHelper.GetAttribute(el, 'k'))}）');

        // XMLHelper.CreateAttribute：C# 里 `node.Attributes.Append(attr)` 必须真的把属性挂到文档上。
        var doc2 = XmlDocument.parse('<r/>');
        var el2 = doc2.documentElement;
        var created = XMLHelper.CreateAttribute(el2, 'id', 'x1');
        check(XMLHelper.GetAttribute(el2, 'id') == 'x1',
            'CreateAttribute 写进文档（实际 ${q(XMLHelper.GetAttribute(el2, 'id'))}）');
        check(el2.OuterXml.indexOf('id="x1"') >= 0, 'OuterXml 含新属性：${el2.OuterXml}');
        check(created != null && created.OwnerElement != null, 'CreateAttribute 返回的属性已绑定 OwnerElement');
        if (created != null) {
            created.Value = 'x2';
            check(XMLHelper.GetAttribute(el2, 'id') == 'x2',
                '返回的 XmlAttribute 与文档同体（实际 ${q(XMLHelper.GetAttribute(el2, 'id'))}）');
        }
        XMLHelper.CreateAttribute(el2, 'id', 'x3');
        check(el2.attributes.Count == 1, '重复 CreateAttribute 同名属性不重复添加：Count=${el2.attributes.Count}');
        el2.attributes.remove('id');
        check(el2.attributes.Count == 0 && XMLHelper.GetAttribute(el2, 'id') == null, 'Attributes.Remove 摘掉属性');

        // InnerText 读写。
        var t = XmlDocument.parse('<r><a>1</a><a>2</a></r>').documentElement;
        t.InnerText = 'hello';
        check(t.childNodes.Count == 1 && t.InnerText == 'hello', 'InnerText setter 替换全部子节点（Count=${t.childNodes.Count}）');
        check(t.childNodes[0].nodeType == XmlNodeType.Text, 'InnerText setter 生成文本节点');

        // CDATA / 文本节点构造与读取。
        var doc3 = XmlDocument.parse('<r/>');
        var cdataNode = doc3.documentElement;
        XMLHelper.CreateTextOrCDataNode(doc3, cdataNode, 'p', 'x < y');
        XMLHelper.CreateTextOrCDataNode(doc3, cdataNode, 'p', 'plain');
        check(cdataNode.childNodes.Count == 2, 'CreateTextOrCDataNode 追加两个 <p>（Count=${cdataNode.childNodes.Count}）');
        checkNames(cdataNode, ['p', 'p'], '追加的是元素而非文本节点');
        check(cdataNode.childNodes[0].childNodes[0].nodeType == XmlNodeType.CDATA, '含特殊字符时用 CDATA');
        check(cdataNode.childNodes[0].InnerText == 'x < y', 'CDATA 的 InnerText');
        check(cdataNode.childNodes[1].childNodes[0].nodeType == XmlNodeType.Text, '普通文本用 Text 节点');

        // ConcatNodeParagraphs：.NET 版本按 ChildNodes 过滤 <p>，空白文本节点不能干扰。
        var talk = XmlDocument.parse("<t>\n  <p>line1</p>\n  <p>line2</p>\n</t>").documentElement;
        check(XMLHelper.ConcatNodeParagraphs(talk) == "line1\nline2",
            'ConcatNodeParagraphs=${q(XMLHelper.ConcatNodeParagraphs(talk))}');

        // ToPropertyDictionary：.NET 版本按下标遍历 ChildNodes，空白节点会让它错位并刷警告。
        var props = XmlDocument.parse("<props>\n  <int name=\"a\" value=\"1\"/>\n  <float name=\"b\" value=\"2.5\"/>\n</props>").documentElement;
        var dict = XMLHelper.ToPropertyDictionary(props, 'mvz2');
        var propKeys = [for (k in dict.keys()) k].join(",");
        check(dict.exists('a') && dict.exists('b'), 'ToPropertyDictionary 解析出 $propKeys（期望 a,b）');

        // 节点改名（.NET XmlElement.Name 在 XmlElement 上可写、其它类型不可写）
        var renamed = XmlDocument.parse('<r><a/></r>').documentElement;
        renamed.name = 'renamed';
        check(renamed.Name == 'renamed' && renamed.OuterXml.indexOf('<renamed>') == 0,
            'setName 改名生效：${renamed.OuterXml}');

        // 未被忽略的空白文本节点若手工构造，ChildNodes 仍应跳过它（.NET 中格式化空白本就进不了树）。
        var manual = XmlDocument.parse('<r/>').documentElement;
        manual.appendChild(doc3.createTextNode("   \n "));
        manual.appendChild(doc3.createElement('i'));
        check(manual.childNodes.Count == 1, '手工追加的纯空白文本节点不计入 ChildNodes：Count=${manual.childNodes.Count}');
        check(manual.InnerText == '   \n ', '手工空白文本节点仍参与 InnerText（内容未丢）');
        manual.removeChild(manual.childNodes[0]);
        check(manual.childNodes.Count == 0 && !manual.hasChildNodes(), 'removeChild 后为空');
    }
    // #endregion

    // #region ② achievements 链
    static function checkAchievementsChain():Void {
        var locator:IResourceLocator = Addressables.InitializeAsync().Task;
        var locations = locator.Locate('mvz2:achievements', TextAsset);
        check(locations.length == 1, '定位符 mvz2:achievements 命中 ${locations.length} 条（期望 1）');
        if (locations.length == 0)
            return;
        var location:ResourceLocation = cast locations[0];
        var textAsset:Dynamic = Addressables.LoadAssetAsyncByLocation(location).WaitForCompletion();
        check(Std.isOfType(textAsset, TextAsset), 'mvz2:achievements → TextAsset（实际 ${typeNameOf(textAsset)}）');
        if (!Std.isOfType(textAsset, TextAsset))
            return;
        var asset:TextAsset = cast textAsset;
        var expected = countOccurrences(asset.text, '<achievement ');

        // 与 ResourceManager.LoadSingleMetaList 逐行等价（该方法为 private，冒烟测试按同一顺序复刻）。
        var resID = NamespaceID.Parse(location.PrimaryKey, 'mvz2');
        var document = XMLHelper.ReadXmlDocumentFromStream(new MemoryStream(asset.bytes));
        var metaPath = resID.Path.split("\\").join("/");
        check(metaPath == 'achievements', 'metaPath=${q(metaPath)}（期望 "achievements"）');
        var list:AchievementMetaList = loadAchievementMetaList(document, metaPath, 'mvz2');

        check(list != null, 'AchievementMetaList 已填充');
        if (list == null)
            return;
        check(list.metas.length == expected && expected == 12,
            '解析出 ${list.metas.length} 个成就（xml 里 <achievement> 共 $expected 个）');
        check(list.metas.length > 0 && list.metas[0].ID == 'ghost_buster', '第一个成就 ID=${list.metas.length > 0 ? list.metas[0].ID : "n/a"}');
        check(list.metas.length > 11 && list.metas[11].ID == 'let_them_eat_cake',
            '最后一个成就 ID=${list.metas.length > 11 ? list.metas[11].ID : "n/a"}');
        var first:AchievementMeta = list.metas[0];
        check(first.Name == '捉鬼敢死队', '成就本地化名 Name=${q(first.Name)}');
        check(first.Description != null && first.Description.length > 0, '成就 Description 非空');
        check(first.Icon != null, '成就 Icon（SpriteReference）已解析');
        if (first.Icon != null) {
            check(first.Icon.ID.SpaceName == 'mvz2' && first.Icon.ID.Path == 'achievements/ghost_buster',
                'Icon=${first.Icon.ID}');
        }
        check(first.Unlock != null, '成就 Unlock（XMLConditionList）已解析');
        if (first.Unlock != null) {
            check(first.Unlock.Conditions.length == 1, 'Unlock 条件数=${first.Unlock.Conditions.length}（期望 1）');
        }
    }

    static function loadAchievementMetaList(document:XmlDocument, metaPath:String, defaultNsp:String):AchievementMetaList {
        #if cpp
        var modResource = new ModResource('mvz2');
        MetaXMLParser.LoadMetaList(modResource, metaPath, document, defaultNsp);
        return modResource.AchievementMetaList;
        #else
        // PORT-NOTE: 与 MetaXMLParser.LoadMetaList 的 "achievements" 分支同一个叶子调用。
        return AchievementMetaList.FromXmlNode(document["achievements"], defaultNsp);
        #end
    }
    // #endregion

    // #region ③ 全量 Meta
    #if cpp
    static function checkAllMetaResources():Void {
        var locator:IResourceLocator = Addressables.InitializeAsync().Task;
        var locations = locator.Locate('Meta', TextAsset);
        check(locations.length == 38, '"Meta" 标签命中 ${locations.length} 条（期望 38）');

        var parsed = 0;
        var talked = 0;
        var xmlErrors:Array<String> = [];
        var otherErrors:Array<String> = [];
        for (location in locations) {
            var typed:ResourceLocation = cast location;
            var key = typed.PrimaryKey;
            try {
                var asset:Dynamic = Addressables.LoadAssetAsyncByLocation(location).WaitForCompletion();
                if (!Std.isOfType(asset, TextAsset)) {
                    otherErrors.push('$key：不是 TextAsset（${typeNameOf(asset)}）');
                    continue;
                }
                var text:TextAsset = cast asset;
                // 与 ResourceManager.LoadSingleMetaList / LoadMetaLists 同一顺序。
                var resID = NamespaceID.Parse(key, 'mvz2');
                var document = XMLHelper.ReadXmlDocumentFromStream(new MemoryStream(text.bytes));
                var metaPath = resID.Path.split("\\").join("/");
                var modResource = new ModResource('mvz2');
                if (metaPath.indexOf("talks/") == 0) {
                    var meta = TalkMeta.FromXmlDocument(document, 'mvz2');
                    if (meta == null)
                        otherErrors.push('$key：TalkMeta.FromXmlDocument 返回 null');
                    else
                        talked++;
                } else {
                    MetaXMLParser.LoadMetaList(modResource, metaPath, document, 'mvz2');
                    parsed++;
                }
            } catch (e:Dynamic) {
                var message = Std.string(e);
                if (message.indexOf('Bad node type') >= 0 || message.indexOf('Xml') >= 0 || message.indexOf('#pcdata') >= 0)
                    xmlErrors.push('$key：$message');
                else
                    otherErrors.push('$key：$message');
            }
        }
        check(xmlErrors.length == 0, '全部 Meta 资源 XML 解析无异常（异常 ${xmlErrors.length} 个）');
        for (m in xmlErrors)
            info('  XML-ERR ' + m);
        check(parsed + talked == 38, '成功解析 ${parsed + talked} 个 Meta 资源（${parsed} 个元数据 + $talked 个对话）');
        for (m in otherErrors)
            note('非 XML 层异常（不计入本工作包）：' + m);
    }
    #end
    // #endregion

    // #region 工具
    static function checkNames(node:XmlNode, expected:Array<String>, message:String):Void {
        var actual:Array<String> = [];
        for (i in 0...node.childNodes.Count)
            actual.push(node.childNodes[i].Name);
        check(actual.join(",") == expected.join(","), '$message（实际 ${actual.join(",")}）');
    }

    static function nameOf(node:XmlNode):String {
        if (node == null)
            return 'null';
        try {
            return node.Name;
        } catch (e:Dynamic) {
            return '<throw:$e>';
        }
    }

    static function q(s:String):String {
        if (s == null)
            return 'null';
        return '"' + s.split("\n").join("\\n").split("\t").join("\\t").split("\r").join("\\r") + '"';
    }

    static function countOccurrences(text:String, needle:String):Int {
        if (text == null)
            return 0;
        var count = 0;
        var index = 0;
        while (true) {
            var found = text.indexOf(needle, index);
            if (found < 0)
                break;
            count++;
            index = found + needle.length;
        }
        return count;
    }

    static function typeNameOf(value:Dynamic):String {
        if (value == null)
            return 'null';
        try {
            return Type.getClassName(Type.getClass(value));
        } catch (e:Dynamic) {
            return Std.string(value);
        }
    }

    static function section(title:String):Void {
        Sys.println('---- $title ----');
    }

    static function check(condition:Bool, message:String):Void {
        checks++;
        if (condition) {
            Sys.println('[ ok ] ' + message);
        } else {
            Sys.println('[FAIL] ' + message);
            failures.push(message);
        }
    }

    static function info(message:String):Void {
        Sys.println('[info] ' + message);
    }

    static function note(message:String):Void {
        notes++;
        Sys.println('[note] ' + message);
    }
    // #endregion
}
