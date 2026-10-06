// Ported from: Assets/Scripts/Vanilla/GameContent/Buffs/Entity/Chapter4/DivineShieldBuff.cs
package mvz2.gamecontent.buffs.entities;

import mvz2.gamecontent.buffs.VanillaBuffID;
import mvz2.gamecontent.buffs.VanillaBuffNames;
import mvz2.gamecontent.fragments.VanillaFragmentID;
import mvz2.gamecontent.models.VanillaModelID;
import mvz2.gamecontent.shells.VanillaShellID;
import mvz2.vanilla.audios.VanillaSoundID;
import mvz2.vanilla.callbacks.VanillaLevelCallbacks;
import mvz2.vanilla.effects.FragmentExt;
import mvz2.vanilla.entities.VanillaEntityExt;
import mvz2.vanilla.models.VanillaModelKeys;
import mvz2.vanilla.properties.VanillaBuffPropertyMeta;
import mvz2logic.Global;
import mvz2logic.entities.LogicEntityExt;
import mvz2logic.models.LogicModelHelper;
import pvzengine.NamespaceID;
import pvzengine.buffs.Buff;
import pvzengine.callbacks.CallbackResult;
import pvzengine.callbacks.LevelCallbacks;
import pvzengine.damages.BodyDamageResult;
import pvzengine.definitions.BuffDefinition;
import pvzengine.entities.Entity;
import pvzengine.callbacks.LevelCallbacks.EntityDeathParams;
import mvz2.vanilla.callbacks.VanillaLevelCallbacks.PreTakeDamageParams;

@:autoBuffDefinition(VanillaBuffNames.Entity_divineShield)
class DivineShieldBuff extends BuffDefinition
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
        AddModelInsertion(LogicModelHelper.ANCHOR_ROOT, VanillaModelKeys.divineShield, VanillaModelID.divineShield);
        AddTrigger(VanillaLevelCallbacks.PRE_ENTITY_TAKE_DAMAGE, PreEntityTakeDamageCallback, -100);
        AddTrigger(LevelCallbacks.POST_ENTITY_DEATH, PostEntityDeathCallback);
    }
    public override function PostAdd(buff:Buff):Void
    {
        super.PostAdd(buff);
        var entity = buff.GetEntity();
        if (entity == null)
            return;
        LogicEntityExt.PlaySound(entity, VanillaSoundID.divineShield);
    }
    public override function PostRemove(buff:Buff):Void
    {
        super.PostRemove(buff);
        if (buff.Target != null)
            buff.Target.AddBuff(VanillaBuffID.Entity.divineShieldCooldown);
    }
    public override function PostUpdate(buff:Buff):Void
    {
        super.PostUpdate(buff);
        var entity = buff.GetEntity();
        if (entity == null)
            return;
        var model = buff.GetInsertedModel(VanillaModelKeys.divineShield);
        if (model == null)
            return;
        model.SetModelProperty("Size", entity.GetSize());
    }
    private function PreEntityTakeDamageCallback(param:PreTakeDamageParams, result:CallbackResult):Void
    {
        var input = param.input;
        if (NamespaceID.IsValid(input.ShieldTarget))
            return;
        if (input.Amount <= 0)
            return;
        var entity = input.Entity;
        var buff = entity.GetFirstBuff(DivineShieldBuff);
        if (buff == null)
            return;

        var output = param.output;
        var bodyResult = new BodyDamageResult(input, Global.Game.GetShellDefinition(VanillaShellID.stone));
        bodyResult.Fatal = false;
        bodyResult.Amount = 0;
        bodyResult.SpendAmount = input.OriginalAmount;
        output.BodyResult = bodyResult;
        buff.Remove();

        result.SetFinalValue(false);
        PlayBreakEffect(entity);
    }
    private function PostEntityDeathCallback(param:EntityDeathParams, result:CallbackResult):Void
    {
        var entity = param.entity;
        var info = param.deathInfo;
        if (VanillaEntityExt.WillRemoveOnDeath(entity, info))
            return;
        for (buff in entity.GetBuffs(DivineShieldBuff))
        {
            PlayBreakEffect(entity);
            buff.Remove();
        }
    }
    public static function PlayBreakEffect(entity:Entity):Void
    {
        LogicEntityExt.PlaySound(entity, VanillaSoundID.crystalBreak, 1, 0.5);
        FragmentExt.CreateFragmentAndPlayAt(entity, entity.GetCenter(), VanillaFragmentID.divineShield, 50);
    }
    public static inline var HEALTH_SPEED:Float = 1 / 6;
    public static inline var MAX_PARASITE_HEALTH:Float = 50;
    public static var PROP_PARASITE_HEALTH:VanillaBuffPropertyMeta<Int> = new VanillaBuffPropertyMeta<Int>("ParasiteHealth");
    public static inline var DAMAGE:Float = 100;
}
