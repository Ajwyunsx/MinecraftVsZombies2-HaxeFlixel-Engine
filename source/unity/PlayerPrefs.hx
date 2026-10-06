package unity;

// Minimal UnityEngine.PlayerPrefs shim.
class PlayerPrefs {
    public static var storage:Map<String, Dynamic> = new Map();

    public static function HasKey(key:String):Bool {
        return storage.exists(key);
    }
    public static function GetInt(key:String, ?defaultValue:Int = 0):Int {
        if (!storage.exists(key)) return defaultValue;
        return Std.int(storage.get(key));
    }
    public static function SetInt(key:String, value:Int):Void {
        storage.set(key, value);
    }
    public static function GetFloat(key:String, ?defaultValue:Float = 0):Float {
        if (!storage.exists(key)) return defaultValue;
        return storage.get(key);
    }
    public static function SetFloat(key:String, value:Float):Void {
        storage.set(key, value);
    }
    public static function GetString(key:String, ?defaultValue:String = ""):String {
        if (!storage.exists(key)) return defaultValue;
        return storage.get(key);
    }
    public static function SetString(key:String, value:String):Void {
        storage.set(key, value);
    }
    public static function DeleteKey(key:String):Void {
        storage.remove(key);
    }
    public static function DeleteAll():Void {
        storage = new Map();
    }
    public static function Save():Void {}
}
