// Ported from: Assets/Scripts/Logic/Layers.cs
package mvz2logic;

import unity.LayerMask;

class Layers {
    public static var DEFAULT:Int = LayerMask.NameToLayer("Default");
    public static var GRID:Int = LayerMask.NameToLayer("Grid");
    public static var RAYCAST_RECEIVER:Int = LayerMask.NameToLayer("RaycastReceiver");
    public static var PICKUP:Int = LayerMask.NameToLayer("Pickup");
    public static var LIGHT_TEXTURE:Int = LayerMask.NameToLayer("LightTexture");

    public static function GetMask(layers:Array<Int>):LayerMask {
        if (layers == null) {
            throw "ArgumentNullException: layers";
        }

        var num = 0;
        for (num2 in layers) {
            num |= 1 << num2;
        }
        return new LayerMask(num);
    }
}
