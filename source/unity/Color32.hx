package unity;

// Minimal UnityEngine.Color32 shim.
class Color32 {
    public var r:Int;
    public var g:Int;
    public var b:Int;
    public var a:Int;

    public function new(r:Int = 0, g:Int = 0, b:Int = 0, a:Int = 255) {
        this.r = r;
        this.g = g;
        this.b = b;
        this.a = a;
    }

    @:to public function toColor():Color {
        return new Color(r / 255, g / 255, b / 255, a / 255);
    }
    public function toString():String return 'RGBA($r, $g, $b, $a)';
}
