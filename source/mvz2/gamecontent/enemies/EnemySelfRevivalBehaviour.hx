// Ported from: Assets/Scripts/Vanilla/GameContent/Enemies/Common/EnemySelfRevivalBehaviour.cs
package mvz2.gamecontent.enemies;

import mvz2.gamecontent.damages.VanillaDamageEffects;
import mvz2.vanilla.audios.VanillaSoundID;
import mvz2.vanilla.callbacks.VanillaLevelCallbacks;
import mvz2.vanilla.entities.VanillaEntityBehaviourNames;
import mvz2.vanilla.entities.VanillaEntityExt;
import mvz2.vanilla.properties.VanillaEntityPropertyMeta;
import mvz2logic.entities.LogicEnemyProps;
import pvzengine.callbacks.CallbackResult;
import pvzengine.callbacks.EntityCallbackParams;
import pvzengine.definitions.EntityBehaviourDefinition;
import pvzengine.entities.Entity;
import pvzengine.modifiers.BooleanModifier;
import tools.Ticks;
import unity.Mathf;
using mvz2.vanilla.entities.VanillaEntityExt;
using mvz2logic.entities.LogicEntityExt;

@:autoEntityBehaviourDefinition(VanillaEntityBehaviourNames.enemySelfRevival)
class EnemySelfRevivalBehaviour extends EntityBehaviourDefinition
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
        AddModifier(new BooleanModifier(LogicEnemyProps.ASSUME_ALIVE, PROP_ASSUME_ALIVE));
        AddTrigger(VanillaLevelCallbacks.PRE_ENEMY_FAINT, PreEnemyFaintCallback);
    }
    public override function Update(entity:Entity):Void
    {
        super.Update(entity);
        SetAssumeAlive(entity, GetReviveTimes(entity) > 0);
    }
    function PreEnemyFaintCallback(param:EntityCallbackParams, result:CallbackResult):Void
    {
        var entity = param.entity;
        if (!entity.HasBehaviour(this))
            return;
        var fatalOutput = entity.GetLethalDeathInfo();
        if (fatalOutput != null && fatalOutput.HasEffect(VanillaDamageEffects.NO_REVIVAL))
        {
            return;
        }
        var reviveTimes = GetReviveTimes(entity);
        if (reviveTimes <= 0)
            return;
        entity.Revive();
        entity.Health = Mathf.Max(0, entity.Health);
        entity.HealEffects(entity.GetMaxHealth(), entity);
        SetReviveTimes(entity, reviveTimes - 1);

        var stunSeconds = GetReviveStunSeconds(entity);
        if (stunSeconds > 0)
        {
            entity.Stun(Ticks.FromSeconds(stunSeconds));
        }
        entity.PlaySound(VanillaSoundID.revived);

        result.SetFinalValue(false);
    }
    public static function IsAssumeAlive(entity:Entity):Bool return entity.GetBehaviourField(PROP_ASSUME_ALIVE);
    public static function SetAssumeAlive(entity:Entity, value:Bool):Void entity.SetBehaviourField(PROP_ASSUME_ALIVE, value);
    public static function GetReviveTimes(entity:Entity):Int return entity.GetBehaviourField(PROP_REVIVE_TIMES);
    public static function SetReviveTimes(entity:Entity, value:Int):Void entity.SetBehaviourField(PROP_REVIVE_TIMES, value);
    public static function GetReviveStunSeconds(entity:Entity):Float return entity.GetBehaviourField(PROP_REVIVE_STUN_SECONDS);
    public static function SetReviveStunSeconds(entity:Entity, value:Float):Void entity.SetBehaviourField(PROP_REVIVE_STUN_SECONDS, value);
    public static var PROP_ASSUME_ALIVE:VanillaEntityPropertyMeta<Bool> = new VanillaEntityPropertyMeta<Bool>("assume_alive");
    public static var PROP_REVIVE_TIMES:VanillaEntityPropertyMeta<Int> = new VanillaEntityPropertyMeta<Int>("revive_times");
    public static var PROP_REVIVE_STUN_SECONDS:VanillaEntityPropertyMeta<Float> = new VanillaEntityPropertyMeta<Float>("revive_stun_seconds");
}
