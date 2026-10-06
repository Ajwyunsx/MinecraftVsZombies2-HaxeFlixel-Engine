// Ported from: Assets/Scripts/Vanilla/GameContent/Shells/VanillaShellID.cs
package mvz2.gamecontent.shells;

import mvz2.vanilla.VanillaMod;
import pvzengine.NamespaceID;

class VanillaShellNames
{
    public static inline var normal:String = "normal";
    public static inline var leather:String = "leather";
    public static inline var flesh:String = "flesh";
    public static inline var bone:String = "bone";
    public static inline var stone:String = "stone";
    public static inline var grass:String = "grass";
    public static inline var metal:String = "metal";
    public static inline var wood:String = "wood";
    public static inline var nether:String = "nether";
    public static inline var diamond:String = "diamond";
    public static inline var sand:String = "sand";
    public static inline var netherrack:String = "netherrack";
    public static inline var cloud:String = "cloud";
    public static inline var lightning:String = "lightning";
    public static inline var shadow:String = "shadow";
}

class VanillaShellID
{
    public static var normal:NamespaceID = Get(VanillaShellNames.normal);
    public static var leather:NamespaceID = Get(VanillaShellNames.leather);
    public static var flesh:NamespaceID = Get(VanillaShellNames.flesh);
    public static var bone:NamespaceID = Get(VanillaShellNames.bone);
    public static var stone:NamespaceID = Get(VanillaShellNames.stone);
    public static var grass:NamespaceID = Get(VanillaShellNames.grass);
    public static var metal:NamespaceID = Get(VanillaShellNames.metal);
    public static var wood:NamespaceID = Get(VanillaShellNames.wood);
    public static var nether:NamespaceID = Get(VanillaShellNames.nether);
    public static var diamond:NamespaceID = Get(VanillaShellNames.diamond);
    public static var sand:NamespaceID = Get(VanillaShellNames.sand);
    public static var netherrack:NamespaceID = Get(VanillaShellNames.netherrack);
    public static var cloud:NamespaceID = Get(VanillaShellNames.cloud);
    public static var lightning:NamespaceID = Get(VanillaShellNames.lightning);
    public static var shadow:NamespaceID = Get(VanillaShellNames.shadow);
    static function Get(name:String):NamespaceID
    {
        return new NamespaceID(VanillaMod.spaceName, name);
    }
}
