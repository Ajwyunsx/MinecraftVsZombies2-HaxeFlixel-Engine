package unity;

// Minimal UnityEngine.Material shim.
class Material extends UnityObject {
    public var shader:Shader;
    public var color:Color = new Color(1, 1, 1, 1);
    public var mainTexture:Texture;
    public var renderQueue:Int = 3000;
    private var properties:Map<String, Dynamic> = [];

    public function new(?shader:Shader) {
        super();
        this.shader = shader;
    }

    public function HasProperty(name:String):Bool return properties.exists(name);
    public function GetInt(name:String):Int return properties.exists(name) ? properties.get(name) : 0;
    public function GetFloat(name:String):Float return properties.exists(name) ? properties.get(name) : 0;
    public function GetColor(name:String):Color return properties.exists(name) ? properties.get(name) : new Color();
    public function GetVector(name:String):Vector4 return properties.exists(name) ? properties.get(name) : new Vector4();
    public function GetTexture(name:String):Texture return properties.exists(name) ? properties.get(name) : null;

    public function SetInt(name:String, value:Int):Void properties.set(name, value);
    public function SetFloat(name:String, value:Float):Void properties.set(name, value);
    public function SetColor(name:String, value:Color):Void properties.set(name, value);
    public function SetVector(name:String, value:Vector4):Void properties.set(name, value);
    public function SetTexture(name:String, value:Texture):Void properties.set(name, value);
    public function SetTextureOffset(name:String, value:Vector2):Void {}
    public function SetTextureScale(name:String, value:Vector2):Void {}
    public function EnableKeyword(keyword:String):Void {}
    public function DisableKeyword(keyword:String):Void {}
}
