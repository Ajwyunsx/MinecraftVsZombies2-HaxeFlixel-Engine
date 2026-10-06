// Ported from: Assets/Scripts/Vanilla/GameContent/Artifacts/Chapter5/UFOToy.cs
package mvz2.gamecontent.artifacts;

import mvz2.gamecontent.artifacts.VanillaArtifactID.VanillaArtifactNames;
import mvz2.gamecontent.pickups.VanillaPickupID;
import mvz2.vanilla.callbacks.VanillaLevelCallbacks;
import mvz2.vanilla.properties.VanillaArtifactPropertyMeta;
import mvz2logic.artifacts.Artifact;
import mvz2logic.artifacts.ArtifactDefinition;
import pvzengine.NamespaceID;
import pvzengine.callbacks.CallbackResult;
import pvzengine.callbacks.EntityCallbackParams;
import pvzengine.entities.Entity;
import mvz2.vanilla.pickups.VanillaPickupExt;
using mvz2logic.artifacts.LogicArtifactProps;
using mvz2logic.level.LogicLevelExt;

@:autoArtifactDefinition(VanillaArtifactNames.ufoToy)
class UFOToy extends ArtifactDefinition
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
        AddTrigger(VanillaLevelCallbacks.POST_PICKUP_COLLECT, PostPickupCollectCallback);
    }
    function PostPickupCollectCallback(param:EntityCallbackParams, result:CallbackResult):Void
    {
        var pickup = param.entity;
        var level = pickup.Level;
        for (artifact in level.GetArtifacts())
        {
            if (artifact == null || artifact.Definition != this)
                continue;
            var type = GetPickupType(pickup);
            if (type == TYPE_NULL)
                continue;
            var count = GetTypeCount(artifact, type);
            count++;
            if (count >= MAX_COUNT)
            {
                var times = Std.int(count / MAX_COUNT);
                count = count % MAX_COUNT;
                for (_ in 0...times)
                {
                    // PORT-NOTE: C# 重载 Produce(this LevelEngine, EntityDefinition, Vector3, Entity, SpawnParams)
                    // 在移植层命名为 ProduceOnLevel。
                    VanillaPickupExt.ProduceOnLevel(level, pickup.Definition, pickup.GetCenter(), pickup);
                }
                artifact.Highlight();
            }
            SetTypeCount(artifact, type, count);
            UpdateDisplayText(artifact);
        }
    }
    public static function GetPickupType(pickup:Entity):Int
    {
        var id = pickup.GetDefinitionID();
        if (pickupTypeDict.exists(id))
        {
            return pickupTypeDict.get(id);
        }
        return TYPE_NULL;
    }
    public static function GetTypeMask(type:Int):Int
    {
        // PORT-NOTE: C# switch 表达式 → if 链（掩码常量用 inline var 表示，if 链更直观且等语义）。
        if (type == TYPE_RED) return RED_MASK;
        if (type == TYPE_GREEN) return GREEN_MASK;
        if (type == TYPE_BLUE) return BLUE_MASK;
        if (type == TYPE_DIAMOND) return DIAMOND_MASK;
        return 0;
    }
    public static function GetTypeOffset(type:Int):Int
    {
        return COUNT_BITS * type;
    }
    public static function GetCountFlags(artifact:Artifact):Int
    {
        // PORT-NOTE: C# GetProperty<int> 在属性缺失时返回 int 默认值 0，Haxe 侧显式补默认值。
        var value = artifact.GetProperty(PROP_COUNT_FLAGS);
        return value == null ? 0 : value;
    }
    public static function SetCountFlags(artifact:Artifact, value:Int):Void
    {
        artifact.SetProperty(PROP_COUNT_FLAGS, value);
    }
    public static function GetTypeCount(artifact:Artifact, type:Int):Int
    {
        var countFlags = GetCountFlags(artifact);
        return (countFlags & GetTypeMask(type)) >> GetTypeOffset(type);
    }
    public static function SetTypeCount(artifact:Artifact, type:Int, value:Int):Void
    {
        var countFlags = GetCountFlags(artifact);
        var mask = GetTypeMask(type);
        countFlags = (countFlags & (~mask)) | ((value << GetTypeOffset(type)) & mask);
        SetCountFlags(artifact, countFlags);
    }
    public static function UpdateDisplayText(artifact:Artifact):Void
    {
        // PORT-NOTE: C# StringBuilder → Haxe StringBuf。
        var stringBuilder = new StringBuf();
        for (type in typeOrder)
        {
            var count = GetTypeCount(artifact, type);
            if (count > 0)
            {
                if (typeColorDict.exists(type))
                {
                    var color = typeColorDict.get(type);
                    stringBuilder.add('<color=${color}>${count}</color>');
                }
                else
                {
                    stringBuilder.add(count);
                }
            }
        }
        artifact.SetDisplayText(stringBuilder.toString());
    }
    public static inline var TYPE_NULL:Int = -1;
    public static inline var TYPE_RED:Int = 0;
    public static inline var TYPE_GREEN:Int = 1;
    public static inline var TYPE_BLUE:Int = 2;
    public static inline var TYPE_DIAMOND:Int = 3;
    public static inline var TYPE_COUNT:Int = 4;

    public static inline var MAX_COUNT:Int = 3;

    public static inline var COUNT_BITS:Int = 4;
    // PORT-NOTE: C# 为 `const uint`，Haxe 无 uint，改用 Int 常量。
    public static inline var RED_MASK:Int = 0x000F;
    public static inline var GREEN_MASK:Int = 0x00F0;
    public static inline var BLUE_MASK:Int = 0x0F00;
    public static inline var DIAMOND_MASK:Int = 0xF000;

    public static var PROP_COUNT_FLAGS:VanillaArtifactPropertyMeta<Int> = new VanillaArtifactPropertyMeta<Int>("count_flags");
    public static var pickupTypeDict:Map<NamespaceID, Int> = [
        VanillaPickupID.ruby => TYPE_RED,
        VanillaPickupID.emerald => TYPE_GREEN,
        VanillaPickupID.sapphire => TYPE_BLUE,
        VanillaPickupID.diamond => TYPE_DIAMOND
    ];
    public static var typeColorDict:Map<Int, String> = [
        TYPE_RED => "#FF0000",
        TYPE_GREEN => "#00FF00",
        TYPE_BLUE => "#0000FF",
        TYPE_DIAMOND => "#00FFFF"
    ];
    public static var typeOrder:Array<Int> = [
        TYPE_GREEN,
        TYPE_RED,
        TYPE_BLUE,
        TYPE_DIAMOND
    ];
}
