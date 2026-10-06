// PORT-NOTE: 移植层自检（无 C# 对应源码）。验证 hxcpp 上 `Std.isOfType` 对
// `unity.ui.Image` / `unity.ui.Text` / `unity.SpriteRenderer` 的判定是否正确
// —— 若恒为 false，uGUI 渲染桥就永远进不了取 sprite 的分支（画面 = 白色占位块）。
// 编译到 cpp 后运行，看 stdout。
import unity.SpriteRenderer;
import unity.ui.Graphic;
import unity.ui.Image;
import unity.ui.Text;

class TypeCheckProbe {
    static function main():Void {
        var img = new Image();
        var txt = new Text();
        var sr = new SpriteRenderer();

        trace("--- Std.isOfType（Haxe 标准写法） ---");
        trace('Image isOfType Image        = ${Std.isOfType(img, Image)}   (期望 true)');
        trace('Image isOfType Graphic      = ${Std.isOfType(img, Graphic)}   (期望 true，父类)');
        trace('Text  isOfType Text         = ${Std.isOfType(txt, Text)}   (期望 true)');
        trace('Text  isOfType Image        = ${Std.isOfType(txt, Image)}   (期望 false)');
        trace('SR    isOfType SpriteRenderer = ${Std.isOfType(sr, SpriteRenderer)}   (期望 true)');

        trace("--- Type.getClass 判定（本工作包的 isInstanceOf 实现） ---");
        trace('Image getClass = ${Type.getClassName(Type.getClass(img))}');
        trace('Text  getClass = ${Type.getClassName(Type.getClass(txt))}');
        trace('SR    getClass = ${Type.getClassName(Type.getClass(sr))}');
        trace('Image 沿继承链是 Image   = ${isInstanceOf(img, Image)}');
        trace('Image 沿继承链是 Graphic = ${isInstanceOf(img, Graphic)}');
        trace('SR    沿继承链是 SpriteRenderer = ${isInstanceOf(sr, SpriteRenderer)}');
        trace("--- 结束 ---");
    }

    static function isInstanceOf(obj:Dynamic, cls:Class<Dynamic>):Bool {
        if (obj == null || cls == null) return false;
        var c = Type.getClass(obj);
        var guard = 0;
        while (c != null && guard++ < 32) {
            if (c == cls) return true;
            c = Type.getSuperClass(c);
        }
        return false;
    }
}
