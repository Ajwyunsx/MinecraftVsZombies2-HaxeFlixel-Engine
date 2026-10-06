package system.xml;

import system.io.Stream;

// Minimal System.Xml.XmlReader / XmlReaderSettings shim.
// PORT-NOTE: haxe 侧没有流式读取器，XmlReader 退化为「握有整段文本 + 一份设置」，
// 真正的取舍在 XmlDocument.load 里按设置做（见 XmlNode.normalizeDocument）：
//   * ignoreComments=true            → 注释节点不进 DOM；
//   * ignoreProcessingInstructions=true → 处理指令节点不进 DOM；
//   * ignoreWhitespace 与 XmlDocument 默认的 PreserveWhitespace=false 效果一致（纯空白文本节点一律不进 DOM）；
//   * checkCharacters 无实现（haxe 的 Xml.parse 已按 XML 规范校验结构，字符集校验差异见报告）。
class XmlReaderSettings {
    public var ignoreComments:Bool = false;
    public var ignoreWhitespace:Bool = false;
    public var ignoreProcessingInstructions:Bool = false;
    public var checkCharacters:Bool = true;

    public function new() {}
}

class XmlReader {
    private var content:String;
    public var settings:XmlReaderSettings;

    public function new(content:String, ?settings:XmlReaderSettings) {
        this.content = content;
        this.settings = settings != null ? settings : new XmlReaderSettings();
    }

    public static function create(stream:Stream, ?settings:XmlReaderSettings):XmlReader {
        return new XmlReader(stream.ReadToEnd(), settings);
    }
    public static function createFromString(content:String, ?settings:XmlReaderSettings):XmlReader {
        return new XmlReader(content, settings);
    }

    public function readToEnd():String return content;
    public function close():Void {}
}
