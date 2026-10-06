package unity;

// Minimal UnityEngine.Gradient shim.
class Gradient {
    public var colorKeys:Array<GradientColorKey> = [];
    public var alphaKeys:Array<GradientAlphaKey> = [];
    public var mode:GradientMode = GradientMode.Blend;

    public function new() {}

    public function Evaluate(time:Float):Color {
        // PORT-NOTE: 简化实现，取最近的颜色键。
        if (colorKeys.length == 0) return new Color(1, 1, 1, 1);
        var result = colorKeys[0].color;
        result.a = alphaKeys.length > 0 ? alphaKeys[0].alpha : 1;
        return result;
    }
    public function SetKeys(colorKeys:Array<GradientColorKey>, alphaKeys:Array<GradientAlphaKey>):Void {
        this.colorKeys = colorKeys;
        this.alphaKeys = alphaKeys;
    }
}

// Minimal UnityEngine.GradientColorKey shim.
class GradientColorKey {
    public var color:Color = new Color(0, 0, 0, 0); // PORT-NOTE: C# Color 为 struct，default 为 (0,0,0,0) 透明黑；显式初始化避免 abstract-over-class 的 null 解引用
    public var time:Float;
    public function new(?color:Color = null, ?time:Float = 0) {
        this.color = color != null ? color : new Color(1, 1, 1, 1);
        this.time = time;
    }
}

// Minimal UnityEngine.GradientAlphaKey shim.
class GradientAlphaKey {
    public var alpha:Float;
    public var time:Float;
    public function new(?alpha:Float = 1, ?time:Float = 0) {
        this.alpha = alpha;
        this.time = time;
    }
}

// Minimal UnityEngine.GradientMode shim.
enum abstract GradientMode(Int) {
    var Blend = 0;
    var Fixed = 1;
}
