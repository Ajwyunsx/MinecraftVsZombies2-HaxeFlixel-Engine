package unity;

// Minimal UnityEngine.RenderTexture shim.
class RenderTexture extends Texture {
    public var depth:Int = 24;
    public var antiAliasing:Int = 1;
    public function new(?width:Int = 0, ?height:Int = 0, ?depth:Int = 24) {
        super(width, height);
        this.depth = depth;
    }
    public static function GetTemporary(width:Int, height:Int):RenderTexture return new RenderTexture(width, height);
    public static function ReleaseTemporary(rt:RenderTexture):Void {}
    // PORT-NOTE: 补全 Unity 的当前渲染目标静态字段（渲染层未实现，仅保存引用）。
    public static var active:RenderTexture = null;
    public function Release():Void {}
    public function Create():Bool return true;
}
