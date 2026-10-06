// Ported from: Assets/Scripts/Vanilla/GameContent/Armors/ArmorEntityBehaviour.cs
package mvz2.gamecontent.entities;

import mvz2.gamecontent.damages.VanillaDamageEffects;
import mvz2.gamecontent.effects.VanillaEffectID;
import mvz2.vanilla.armors.VanillaArmorExt;
import mvz2.vanilla.armors.VanillaArmorProps;
import mvz2.vanilla.entities.VanillaEntityBehaviourNames;
import mvz2.vanilla.entities.VanillaEntityExt;
import mvz2logic.entities.LogicEntityExt;
import pvzengine.NamespaceID;
import pvzengine.armors.Armor;
import pvzengine.armors.ArmorDestroyInfo;
import pvzengine.damages.DamageOutput;
import pvzengine.definitions.EntityBehaviourDefinition;
import pvzengine.entities.EngineEntityProps;
import pvzengine.entities.Entity;
import pvzengine.level.LevelEngine;
import unity.Vector3;

@:autoEntityBehaviourDefinition(VanillaEntityBehaviourNames.armorEntity)
class ArmorEntityBehaviour extends EntityBehaviourDefinition
{
    // #region 公有方法
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
    }
    public override function PostTakeDamage(result:DamageOutput):Void
    {
        super.PostTakeDamage(result);
        var armorResult = result.ArmorResult;
        if (armorResult != null && armorResult.Amount > 0 && !armorResult.HasEffect(VanillaDamageEffects.NO_DAMAGE_BLINK))
        {
            var armor = armorResult.Armor;
            VanillaArmorExt.DamageBlink(armor);
        }

        var shieldResult = result.ShieldResult;
        if (shieldResult != null && shieldResult.Amount > 0 && !shieldResult.HasEffect(VanillaDamageEffects.NO_DAMAGE_BLINK))
        {
            var shield = shieldResult.Armor;
            VanillaArmorExt.DamageBlink(shield);
        }
    }
    public override function PostDestroyArmor(entity:Entity, slot:NamespaceID, armor:Armor, result:ArmorDestroyInfo):Void
    {
        super.PostDestroyArmor(entity, slot, armor, result);
        entity.RemoveArmor(slot);

        if (!VanillaArmorProps.HasNoDiscard(armor))
        {
            var armorID = armor.Definition.GetID();
            var position = LogicEntityExt.GetArmorDisplayPosition(entity, slot, armorID);
            var displayScale = LogicEntityExt.GetArmorDisplayScale(entity, slot, armorID);

            var spawnParam = VanillaEntityExt.GetSpawnParams(entity);
            spawnParam.SetProperty(EngineEntityProps.DISPLAY_SCALE, displayScale);
            // PORT-NOTE: C# `?.Let(e => {...})` → 显式判空块。
            var e = entity.Spawn(VanillaEffectID.brokenArmor, position, spawnParam);
            if (e != null)
            {
                // PORT-NOTE: C# `result?.Source?.GetEntity(level)?.Position`（Nullable<Vector3>）→ Null<Vector3>。
                var sourceEntity = result != null && result.Source != null ? result.Source.GetEntity(entity.Level) : null;
                var sourcePosition:Null<Vector3> = sourceEntity != null ? sourceEntity.Position : null;
                var moveDirection = VanillaEntityExt.GetFacingDirection(entity);
                if (sourcePosition != null)
                {
                    moveDirection = (entity.Position - sourcePosition).normalized;
                }
                e.Velocity = moveDirection * 10;

                e.ChangeModel(armor.Definition.GetModelID());
            }

        }
    }
    // #endregion
}
