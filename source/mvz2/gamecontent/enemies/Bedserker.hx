// Ported from: Assets/Scripts/Vanilla/GameContent/Enemies/Chapter3/Bedserker.cs
package mvz2.gamecontent.enemies;

import mvz2.gamecontent.damages.VanillaDamageEffects;
import mvz2.gamecontent.entities.AIEntityBehaviour;
import mvz2.vanilla.audios.VanillaSoundID;
import mvz2.vanilla.entities.VanillaEntityExt;
import mvz2.vanilla.entities.VanillaFactions;
import mvz2.vanilla.properties.VanillaEntityPropertyMeta;
import mvz2logic.entities.IDeathEffectsBehaviour;
import mvz2logic.level.LogicLevelExt;
import pvzengine.EngineEntityProps;
import pvzengine.damages.DamageEffectList;
import pvzengine.damages.DeathInfo;
import pvzengine.entities.Entity;
import pvzengine.modifiers.ColorModifier;
import tools.FrameTimer;
import unity.Color;
import unity.Mathf;
using mvz2.vanilla.entities.VanillaEntityProps;
using mvz2logic.entities.LogicEntityExt;

@:autoEntityBehaviourDefinition(VanillaEnemyNames.bedserker)
class Bedserker extends AIEntityBehaviour implements IDeathEffectsBehaviour
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
        AddModifier(new ColorModifier(EngineEntityProps.COLOR_OFFSET, PROP_COLOR_OFFSET));
    }
    public override function Init(entity:Entity):Void
    {
        super.Init(entity);
        SetExplosionTimer(entity, new FrameTimer(EXPLOSION_TIMEOUT));
    }
    override function UpdateLogic(entity:Entity):Void
    {
        super.UpdateLogic(entity);
        if (!entity.IsDead)
        {
            var explosionTimer = GetExplosionTimer(entity);
            var color = Color.clear;
            if (explosionTimer != null)
            {
                explosionTimer.Run();
                if (explosionTimer.PassedFrame(30))
                {
                    entity.PlaySound(VanillaSoundID.fuse);
                }
                if (explosionTimer.PassedFrame(20))
                {
                    entity.PlaySound(VanillaSoundID.parabotTick);
                }
                if (explosionTimer.Expired)
                {
                    entity.Die(new DamageEffectList([VanillaDamageEffects.NO_NEUTRALIZE]), entity);
                }
                if (explosionTimer.Frame <= 30 && explosionTimer.Frame % 4 < 2)
                {
                    color = Color.white;
                }
                else
                {
                    var x = Mathf.Pow((explosionTimer.MaxFrame - explosionTimer.Frame) / (explosionTimer.MaxFrame / 5), 3);
                    var alpha = (-Mathf.Cos(x) + 1) * 0.25;
                    color = new Color(1, 0, 0, alpha);
                }
            }
            entity.SetProperty(PROP_COLOR_OFFSET, color);
        }
    }
    public function DeathEffects(entity:Entity, info:DeathInfo):Void
    {
        var effects = new DamageEffectList([VanillaDamageEffects.EXPLOSION, VanillaDamageEffects.DAMAGE_BODY_AFTER_ARMOR_BROKEN, VanillaDamageEffects.MUTE, VanillaDamageEffects.BYPASS_BOSS_ARMOR]);
        Berserker.ExplodeWithEffects(entity, entity.GetDamage() * 18, effects, VanillaFactions.NEUTRAL);
        entity.Level.ShakeScreen(20, 0, 30);
        entity.Remove();
    }
    public static function SetExplosionTimer(entity:Entity, timer:FrameTimer):Void entity.SetBehaviourField(PROP_EXPLOSION_TIMER, timer);
    public static function GetExplosionTimer(entity:Entity):Null<FrameTimer> return entity.GetBehaviourField(PROP_EXPLOSION_TIMER);
    public static inline var EXPLOSION_TIMEOUT:Int = 300;
    public static var PROP_EXPLOSION_TIMER:VanillaEntityPropertyMeta<FrameTimer> = new VanillaEntityPropertyMeta<FrameTimer>("ExplosionTimer");
    public static var PROP_COLOR_OFFSET:VanillaEntityPropertyMeta<Color> = new VanillaEntityPropertyMeta<Color>("ColorOffset");
}
