// Ported from: MukioI18n.TranslateMsgAttribute (minimal shim)
package mukioi18n;

// PORT-NOTE: Haxe 元数据形式为 @:translateMsg("...")；移植代码中仍以注释保留原特性。
class TranslateMsgAttribute {
    public var Context:String;
    public var Text:String;

    public function new(?text:String, ?context:String) {
        Text = text;
        Context = context;
    }
}
