// Ported from: Assets/Scripts/Vanilla/GameContent/Buffs/Enemies/Chapter4/ShikaisenReviveBuff.cs
package mvz2.gamecontent.buffs.enemies;

import mvz2.gamecontent.buffs.VanillaBuffNames;
import mvz2.gamecontent.damages.VanillaDamageEffects;
import mvz2.vanilla.audios.VanillaSoundID;
import mvz2.vanilla.callbacks.VanillaLevelCallbacks;
import mvz2.vanilla.properties.VanillaBuffPropertyMeta;
import mvz2logic.entities.LogicEnemyProps;
import pvzengine.buffs.Buff;
import pvzengine.callbacks.CallbackResult;
import pvzengine.callbacks.EntityCallbackParams;
import pvzengine.damages.DamageEffectList;
import pvzengine.definitions.BuffDefinition;
import pvzengine.entities.Entity;
import pvzengine.entities.EntityID;
import pvzengine.modifiers.BooleanModifier;
import unity.Mathf;
using mvz2.vanilla.entities.VanillaEntityExt;
using mvz2logic.entities.LogicEntityExt;

@:autoBuffDefinition(VanillaBuffNames.Enemy_shikaisenRevive)
class ShikaisenReviveBuff extends BuffDefinition
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
        AddModifier(new BooleanModifier(LogicEnemyProps.ASSUME_ALIVE, true));
        AddTrigger(VanillaLevelCallbacks.PRE_ENEMY_FAINT, PreEnemyFaintCallback);
    }
    private function PreEnemyFaintCallback(param:EntityCallbackParams, result:CallbackResult):Void
    {
        var entity = param.entity;
        var fatalOutput = entity.GetLethalDeathInfo();
        if (fatalOutput != null && fatalOutput.HasEffect(VanillaDamageEffects.NO_REVIVAL))
        {
            return;
        }
        var level = entity.Level;
        var buff:Null<Buff> = null;
        var source:Null<Entity> = null;
        for (b in entity.GetBuffs(ShikaisenReviveBuff))
        {
            var sourceID = GetSource(b);
            if (sourceID != null)
            {
                var src = sourceID.GetEntity(level);
                if (src != null && src.ExistsAndAlive())
                {
                    buff = b;
                    source = src;
                    break;
                }
            }
        }
        if (buff == null || source == null || !source.ExistsAndAlive())
            return;
        entity.Revive();
        var costHealth = Mathf.Min(source.Health, entity.GetMaxHealth());
        entity.Health = Mathf.Max(0, entity.Health);
        entity.HealEffects(costHealth, source);
        source.TakeDamage(costHealth, new DamageEffectList([VanillaDamageEffects.SELF_DAMAGE]), source);
        if (source.Health <= 0)
        {
            source.Die();
        }
        result.SetFinalValue(false);

        entity.PlaySound(VanillaSoundID.revived);
        buff.Remove();
    }
    public static function SetSource(buff:Buff, id:EntityID):Void buff.SetProperty(PROP_SOURCE, id);
    public static function GetSource(buff:Buff):Null<EntityID> return buff.GetProperty(PROP_SOURCE);
    public static var PROP_SOURCE:VanillaBuffPropertyMeta<EntityID> = new VanillaBuffPropertyMeta<EntityID>("source");
}
