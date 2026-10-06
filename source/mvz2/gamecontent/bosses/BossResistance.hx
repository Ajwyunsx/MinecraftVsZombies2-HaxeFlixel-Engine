// Ported from: Assets/Scripts/Vanilla/GameContent/Bosses/BossResistance/BossResistance.cs
package mvz2.gamecontent.bosses;

import mvz2.gamecontent.damages.VanillaDamageEffects;
import mvz2.vanilla.entities.VanillaEntityBehaviourNames;
import mvz2.vanilla.properties.VanillaEntityPropertyMeta;
import pvzengine.callbacks.CallbackResult;
import pvzengine.damages.DamageInput;
import pvzengine.damages.DamageOutput;
import pvzengine.definitions.EntityBehaviourDefinition;
import pvzengine.entities.Entity;
import unity.Mathf;

@:autoEntityBehaviourDefinition(VanillaEntityBehaviourNames.bossResistance)
class BossResistance extends EntityBehaviourDefinition
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
    }
    override public function Update(entity:Entity):Void
    {
        super.Update(entity);

        var current = GetCurrentDamageAmount(entity);
        var decay = GetDecay(entity);
        SetCurrentDamageAmount(entity, Mathf.Max(0, current - decay));
    }
    override public function PreTakeDamage(damageInfo:DamageInput, result:CallbackResult):Void
    {
        super.PreTakeDamage(damageInfo, result);
        var bypassBossArmor = damageInfo.HasEffect(VanillaDamageEffects.BYPASS_BOSS_ARMOR);
        if (bypassBossArmor)
            return;

        var entity = damageInfo.Entity;

        var max = GetMaxDamageAmount(entity);
        var current = GetCurrentDamageAmount(entity);
        current = Mathf.Clamp(current, 0, GetMaxDamageAmount(entity));
        var currentDamageLimit = Mathf.Max(0, max - current);
        if (damageInfo.Amount > currentDamageLimit)
        {
            damageInfo.SetAmount(currentDamageLimit);
        }
    }
    override public function PostTakeDamage(output:DamageOutput):Void
    {
        super.PostTakeDamage(output);
        for (result in output.GetAllResults())
        {
            var bypassBossArmor = result.HasEffect(VanillaDamageEffects.BYPASS_BOSS_ARMOR);
            if (bypassBossArmor)
                return;
            var entity = result.Entity;
            var amount = GetCurrentDamageAmount(entity);
            amount += result.Amount;
            SetCurrentDamageAmount(entity, amount);
        }
    }
    public static function GetCurrentDamageAmount(entity:Entity):Float
    {
        return entity.GetBehaviourField(PROP_CURRENT_DAMAGE_AMOUNT);
    }
    public static function SetCurrentDamageAmount(entity:Entity, value:Float):Void
    {
        entity.SetBehaviourField(PROP_CURRENT_DAMAGE_AMOUNT, value);
    }
    public static function GetMaxDamageAmount(entity:Entity):Float
    {
        return entity.GetBehaviourField(PROP_MAX_DAMAGE_AMOUNT);
    }
    public static function SetMaxDamageAmount(entity:Entity, value:Float):Void
    {
        entity.SetBehaviourField(PROP_MAX_DAMAGE_AMOUNT, value);
    }
    public static function GetDecay(entity:Entity):Float
    {
        return entity.GetBehaviourField(PROP_DECAY);
    }
    public static function SetDecay(entity:Entity, value:Float):Void
    {
        entity.SetBehaviourField(PROP_DECAY, value);
    }
    private static var PROP_CURRENT_DAMAGE_AMOUNT:VanillaEntityPropertyMeta<Float> = new VanillaEntityPropertyMeta<Float>("current_damage_amount");
    private static var PROP_MAX_DAMAGE_AMOUNT:VanillaEntityPropertyMeta<Float> = new VanillaEntityPropertyMeta<Float>("max_damage_amount", 600);
    private static var PROP_DECAY:VanillaEntityPropertyMeta<Float> = new VanillaEntityPropertyMeta<Float>("decay", 40);
}
