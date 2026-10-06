package mvz2.modding;

import mvz2logic.modding.IModLogic;

// Ported from: Assets/Scripts/MVZ2/Modding/ModInfo.cs
// PORT-NOTE: UnityEngine.AddressableAssets.ResourceLocators.IResourceLocator is not available in
// the Haxe port; the resource locator is kept as an untyped handle.
class ModInfo {
    public function new(nsp:String, locator:Dynamic) {
        Namespace = nsp;
        ResourceLocator = locator;
    }

    public var Namespace:String;
    public var LevelDataVersion:Int;
    public var DisplayName:String = "";
    public var IsBuiltin:Bool;
    public var ResourceLocator:Dynamic;
    public var CatalogPath:String;
    public var Logic:IModLogic;
}
