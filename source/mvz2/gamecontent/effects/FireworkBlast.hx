// Ported from: Assets/Scripts/Vanilla/GameContent/Effects/Chapter5/FireworkBlast.cs
package mvz2.gamecontent.effects;

import mvz2.gamecontent.buffs.entities.LightFadeoutBuff;
import mvz2.vanilla.entities.VanillaEntityExt;
import mvz2logic.entities.LogicEntityProps;
import pvzengine.EngineEntityProps;
import pvzengine.entities.Entity;
import tools.RandomGenerator;
import unity.Color;
import unity.Vector3;
import mvz2.gamecontent.effects.VanillaEffectID.VanillaEffectNames;
using mvz2.vanilla.entities.VanillaEntityExt;

@:autoEntityBehaviourDefinition(VanillaEffectNames.fireworkBlast)
class FireworkBlast extends EffectBehaviour
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
    }
    public override function Init(entity:Entity):Void
    {
        super.Init(entity);
        var buff = entity.AddBuff(LightFadeoutBuff);
        buff.SetProperty(LightFadeoutBuff.PROP_SPEED_MULTIPLIER, 3);
    }
    // PORT-NOTE: C# 重载 SpawnFireworkBlast(Entity, Vector3, float, Color)，Haxe 无重载；
    // 已有的调用点（ContraptionEvokeBehaviour_FireworkDispenser 等）传的是 RandomGenerator，故该重载保留原名。
    public static function SpawnFireworkBlast(spawner:Entity, position:Vector3, radius:Float, rng:RandomGenerator):Null<Entity>
    {
        var h = rng.NextFloat();
        var s = 1;
        var v = 1;
        var color = Color.HSVToRGB(h, s, v);
        return SpawnFireworkBlastWithColor(spawner, position, radius, color);
    }
    public static function SpawnFireworkBlastWithColor(spawner:Entity, position:Vector3, radius:Float, color:Color):Null<Entity>
    {
        var param = spawner.GetSpawnParams();
        var size = Vector3.one * (radius * 2);
        param.SetProperty(EngineEntityProps.SIZE, size);
        param.SetProperty(LogicEntityProps.LIGHT_RANGE, size);
        param.SetProperty(EngineEntityProps.TINT, color);
        param.SetProperty(LogicEntityProps.LIGHT_COLOR, color);
        return spawner.Spawn(VanillaEffectID.fireworkBlast, position, param);
    }
}
