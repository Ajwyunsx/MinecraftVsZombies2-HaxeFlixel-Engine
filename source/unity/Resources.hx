package unity;

// Minimal UnityEngine.Resources shim.
class Resources {
    // PORT-NOTE: 资源加载统一交给移植层的资源管理器（lime.Assets / 游戏内容管理器）。
    public static function Load(path:String):UnityObject return null;
    public static function LoadAll(path:String):Array<UnityObject> return [];
    public static function LoadAsync(path:String):Dynamic return null;
    public static function UnloadAsset(asset:UnityObject):Void {}
    public static function UnloadUnusedAssets():Void {}
    public static function FindObjectsOfTypeAll(type:Class<Dynamic>):Array<Dynamic> return [];
}
