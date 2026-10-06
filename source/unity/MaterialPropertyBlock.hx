package unity;

// Minimal UnityEngine.MaterialPropertyBlock shim.
class MaterialPropertyBlock {
    private var ints:Map<String, Int> = [];
    private var floats:Map<String, Float> = [];
    private var colors:Map<String, Color> = [];
    private var vectors:Map<String, Vector4> = [];
    private var textures:Map<String, Texture> = [];

    public function new() {}

    public function SetInt(name:String, value:Int):Void ints.set(name, value);
    public function SetFloat(name:String, value:Float):Void floats.set(name, value);
    public function SetColor(name:String, value:Color):Void colors.set(name, value);
    public function SetVector(name:String, value:Vector4):Void vectors.set(name, value);
    public function SetTexture(name:String, value:Texture):Void textures.set(name, value);
    public function Clear():Void {
        ints.clear();
        floats.clear();
        colors.clear();
        vectors.clear();
        textures.clear();
    }
    public function GetInt(name:String):Int return ints.exists(name) ? ints.get(name) : 0;
    public function GetFloat(name:String):Float return floats.exists(name) ? floats.get(name) : 0;
    public function GetColor(name:String):Color return colors.exists(name) ? colors.get(name) : new Color();
    public function GetVector(name:String):Vector4 return vectors.exists(name) ? vectors.get(name) : new Vector4();

    // C# 没有该方法，是移植层内部用于 GetPropertyBlock/SetPropertyBlock 的深拷贝辅助。
    public function CopyFrom(other:MaterialPropertyBlock):Void {
        if (other == null) {
            Clear();
            return;
        }
        Clear();
        for (k in other.ints.keys()) ints.set(k, other.ints.get(k));
        for (k in other.floats.keys()) floats.set(k, other.floats.get(k));
        for (k in other.colors.keys()) colors.set(k, other.colors.get(k));
        for (k in other.vectors.keys()) vectors.set(k, other.vectors.get(k));
        for (k in other.textures.keys()) textures.set(k, other.textures.get(k));
    }
}
