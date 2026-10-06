// Ported from: Assets/Scripts/Vanilla/GameContent/Armors/ReflectiveBarrier.cs
package mvz2.gamecontent.armors;

import mvz2.gamecontent.armors.VanillaArmorBehaviourID.VanillaArmorBehaviourNames;
import mvz2.gamecontent.fragments.VanillaFragmentID;
import mvz2.gamecontent.projectiles.VanillaProjectileID;
import mvz2.vanilla.audios.VanillaSoundID;
import mvz2.vanilla.callbacks.VanillaLevelCallbacks;
import mvz2.vanilla.entities.VanillaEntityExt;
import mvz2.vanilla.effects.FragmentExt;
import mvz2.vanilla.projectiles.VanillaProjectileExt;
import mvz2logic.armors.LogicArmorSlots;
import pvzengine.callbacks.CallbackResult;
import pvzengine.callbacks.LevelCallbacks;
import pvzengine.definitions.ArmorBehaviourDefinition;
import unity.Vector3;

@:autoArmorBehaviourDefinition(VanillaArmorBehaviourNames.reflectiveBarrier)
class ReflectiveBarrier extends ArmorBehaviourDefinition
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
        AddTrigger(LevelCallbacks.POST_ENTITY_DEATH, PostEntityDeathCallback);
        AddTrigger(LevelCallbacks.POST_DESTROY_ARMOR, PostArmorDestroyCallback);
        AddTrigger(VanillaLevelCallbacks.POST_PROJECTILE_HIT, PostProjectileHitCallback);
    }
    function PostEntityDeathCallback(param:EntityDeathParams, result:CallbackResult):Void
    {
        var entity = param.entity;
        var info = param.deathInfo;
        if (VanillaEntityExt.WillRemoveOnDeath(entity, info))
            return;
        var shield = entity.GetArmorAtSlot(LogicArmorSlots.shield);
        if (shield == null)
            return;
        if (!shield.Definition.HasBehaviour(this))
            return;
        shield.Destroy();
    }
    function PostArmorDestroyCallback(param:PostArmorDestroyParams, result:CallbackResult):Void
    {
        var entity = param.entity;
        var armor = param.armor;
        var info = param.info;
        if (!armor.Definition.HasBehaviour(this))
            return;
        var pos = entity.Position + new Vector3(VanillaEntityExt.GetFacingX(entity) * 20, 40, 0);
        // PORT-NOTE: C# 是带 position 的重载 CreateFragmentAndPlay(pos, id, emitSpeed)；Haxe 侧改名为 CreateFragmentAndPlayAt。
        FragmentExt.CreateFragmentAndPlayAt(entity, pos, VanillaFragmentID.reflectiveBarrier, 500);
    }
    function PostProjectileHitCallback(param:PostProjectileHitParams, result:CallbackResult):Void
    {
        var hit = param.hit;
        var damage = param.damage;
        if (hit.Pierce)
            return;

        var shield = hit.Shield;
        if (shield == null)
            return;
        var shieldResult = damage != null ? damage.ShieldResult : null;
        if (shieldResult == null)
            return;
        if (!shield.Definition.HasBehaviour(this))
            return;

        var owner = shield.Owner;

        var shootParams = VanillaProjectileExt.GetShootParams(owner);
        shootParams.projectileID = VanillaProjectileID.reflectionBullet;
        shootParams.position = hit.Projectile.GetCenter();
        shootParams.damage = shieldResult.Amount;
        shootParams.soundID = VanillaSoundID.reflection;
        shootParams.velocity = VanillaEntityExt.GetFacingDirection(owner) * 10;
        VanillaProjectileExt.ShootProjectile(owner, shootParams);
    }
}
