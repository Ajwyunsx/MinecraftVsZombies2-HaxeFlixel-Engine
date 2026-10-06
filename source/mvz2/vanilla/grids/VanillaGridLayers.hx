// Ported from: Assets/Scripts/Vanilla/Frameworks/Grids/VanillaGridLayers.cs
package mvz2.vanilla.grids;

import mvz2.vanilla.VanillaMod;
import pvzengine.NamespaceID;

class VanillaGridLayers
{
    public static var main:NamespaceID = Get("main");
    public static var carrier:NamespaceID = Get("carrier");
    public static var protector:NamespaceID = Get("protector");
    public static var tool:NamespaceID = Get("tool");

    public static var normalLayerOrders:Array<NamespaceID> = [
        tool,
        protector,
        main,
        carrier
    ];
    public static var protectedLayers:Array<NamespaceID> = [
        tool,
        main,
        carrier
    ];
    public static var sacrificeLayers:Array<NamespaceID> = [
        protector,
        tool,
        main,
        carrier
    ];
    public static var dreamSilkLayers:Array<NamespaceID> = [
        protector,
        tool,
        main,
        carrier
    ];
    public static var coolingCellLayers:Array<NamespaceID> = [
        main,
        protector,
        carrier
    ];
    public static var devourerLayers:Array<NamespaceID> = [
        main,
        protector,
        carrier
    ];
    public static var ufoLayers:Array<NamespaceID> = [
        main,
        protector,
        carrier
    ];

    private static function Get(name:String):NamespaceID
    {
        return new NamespaceID(VanillaMod.spaceName, name);
    }
}
