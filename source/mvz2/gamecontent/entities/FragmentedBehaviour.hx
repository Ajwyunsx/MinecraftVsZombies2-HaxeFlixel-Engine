// Ported from: Assets/Scripts/Vanilla/GameContent/Entities/Behaviours/FragmentedBehaviour.cs
package mvz2.gamecontent.entities;

import mvz2.gamecontent.damages.VanillaDamageEffects;
import mvz2.gamecontent.effects.Fragment;
import mvz2.vanilla.effects.FragmentExt;
import mvz2.vanilla.entities.VanillaEntityBehaviourNames;
import mvz2.vanilla.entities.VanillaEntityExt;
import pvzengine.EntityID;
import pvzengine.damages.DamageOutput;
import pvzengine.damages.DeathInfo;
import pvzengine.definitions.EntityBehaviourDefinition;
import pvzengine.entities.Entity;

@:autoEntityBehaviourDefinition(VanillaEntityBehaviourNames.fragmented)
class FragmentedBehaviour extends EntityBehaviourDefinition
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
    }
    public override function Init(entity:Entity):Void
    {
        super.Init(entity);
        var fragment = FragmentExt.CreateFragment(entity);
        var fragmentRef = new EntityID(fragment);
        FragmentExt.SetFragment(entity, fragmentRef);
    }
    public override function Update(entity:Entity):Void
    {
        super.Update(entity);
        // PORT-NOTE: C# `?.Let(e => {...})` → 显式判空块。
        var fragment = FragmentExt.GetOrCreateFragment(entity);
        if (fragment != null)
        {
            Fragment.AddEmitSpeed(fragment, FragmentExt.GetFragmentTickDamage(entity));
        }
        FragmentExt.SetFragmentTickDamage(entity, 0);
    }
    public override function PostDeath(entity:Entity, damageInfo:DeathInfo):Void
    {
        super.PostDeath(entity, damageInfo);
        if (damageInfo.HasEffect(VanillaDamageEffects.SACRIFICE) || VanillaEntityExt.WillRemoveOnDeath(entity, damageInfo))
            return;
        if (damageInfo.HasEffect(VanillaDamageEffects.FALL_OFF) || damageInfo.HasEffect(VanillaDamageEffects.DROWN))
            return;
        var fragment = FragmentExt.GetOrCreateFragment(entity);
        if (fragment != null)
        {
            Fragment.AddEmitSpeed(fragment, 500);
        }
    }
    public override function PostTakeDamage(result:DamageOutput):Void
    {
        super.PostTakeDamage(result);
        var bodyResult = result.BodyResult;
        if (bodyResult != null && !FragmentExt.NoDamageFragments(bodyResult.Entity))
        {
            FragmentExt.AddFragmentTickDamage(bodyResult.Entity, bodyResult.Amount);
        }
    }
}
