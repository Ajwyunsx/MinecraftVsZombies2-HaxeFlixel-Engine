package unity;

// Minimal UnityEngine.Shader shim.
class Shader extends UnityObject {
    private static var propertyIDs:Map<String, Int> = [];
    private static var nextID:Int = 1;

    public static function PropertyToID(name:String):Int {
        if (!propertyIDs.exists(name)) {
            nextID++;
            propertyIDs.set(name, nextID);
        }
        return propertyIDs.get(name);
    }
    public static function Find(name:String):Shader return new Shader();

    // PORT-NOTE: 新增 Shader 全局属性设置接口（供 ModelManager 等处使用），实际着色器由渲染层后续实现。
    public static var globalInts:Map<String, Int> = new Map();
    public static var globalFloats:Map<String, Float> = new Map();
    public static function SetGlobalInt(name:String, value:Int):Void {
        globalInts.set(name, value);
    }
    public static function GetGlobalInt(name:String):Int {
        return globalInts.exists(name) ? globalInts.get(name) : 0;
    }
    public static function SetGlobalFloat(name:String, value:Float):Void {
        globalFloats.set(name, value);
    }
    // PORT-NOTE: 新增 Shader.SetGlobalColor（GraphicsManager 设置全局光照颜色用），实际着色器由渲染层后续实现。
    public static var globalColors:Map<String, Color> = new Map();
    public static function SetGlobalColor(name:String, value:Color):Void {
        globalColors.set(name, value);
    }
    public static function GetGlobalColor(name:String):Color {
        return globalColors.exists(name) ? globalColors.get(name) : Color.black;
    }
}
