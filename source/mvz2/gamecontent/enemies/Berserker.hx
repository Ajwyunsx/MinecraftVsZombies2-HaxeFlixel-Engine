// Ported from: Assets/Scripts/Vanilla/GameContent/Enemies/Chapter3/Berserker.cs
package mvz2.gamecontent.enemies;

import mvz2.gamecontent.damages.VanillaDamageEffects;
import mvz2.gamecontent.effects.Explosion;
import mvz2.gamecontent.entities.AIEntityBehaviour;
import mvz2.vanilla.audios.VanillaSoundID;
import mvz2.vanilla.entities.VanillaEntityExt;
import mvz2logic.entities.IDeathEffectsBehaviour;
import pvzengine.damages.DamageEffectList;
import pvzengine.damages.DeathInfo;
import pvzengine.entities.Entity;
import unity.Mathf;
using mvz2.vanilla.entities.VanillaEntityExt;
using mvz2.vanilla.entities.VanillaEntityProps;
using mvz2logic.entities.LogicEntityExt;

@:autoEntityBehaviourDefinition(VanillaEnemyNames.berserker)
class Berserker extends AIEntityBehaviour implements IDeathEffectsBehaviour
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
    }
    public function DeathEffects(entity:Entity, info:DeathInfo):Void
    {
        Explode(entity, entity.GetDamage() * 3, entity.GetFaction());
        entity.Remove();
    }
    // PORT-NOTE: C# 的 Explode 三个重载在 Haxe 中不支持，改为 Explode / ExplodeWithEffects / ExplodeFull 三个名字。
    public static function Explode(entity:Entity, damage:Float, faction:Int):Void
    {
        var effects = new DamageEffectList([VanillaDamageEffects.EXPLOSION, VanillaDamageEffects.DAMAGE_BODY_AFTER_ARMOR_BROKEN, VanillaDamageEffects.MUTE]);
        ExplodeWithEffects(entity, damage, effects, faction);
    }
    public static function ExplodeWithEffects(entity:Entity, damage:Float, effects:DamageEffectList, faction:Int):Void
    {
        ExplodeFull(entity, damage, entity.GetRange(), effects, faction);
    }
    public static function ExplodeFull(entity:Entity, damage:Float, range:Float, effects:DamageEffectList, faction:Int):Void
    {
        var scale = entity.GetFinalScale();
        var scaleX = Mathf.Abs(scale.x);
        var radius = range * scaleX;
        entity.Explode(entity.GetCenter(), radius, faction, damage, effects);

        Explosion.Spawn(entity, entity.GetCenter(), radius);

        entity.PlaySound(VanillaSoundID.explosion, scaleX == 0 ? 1000 : 1 / (scaleX));
    }
}
