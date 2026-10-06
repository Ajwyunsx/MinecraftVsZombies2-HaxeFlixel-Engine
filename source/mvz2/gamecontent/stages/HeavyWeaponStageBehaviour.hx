// Ported from: Assets/Scripts/Vanilla/GameContent/Stages/Behaviours/HeavyWeaponStageBehaviour.cs
package mvz2.gamecontent.stages;

import mvz2.gamecontent.buffs.contraptions.DreamButterflyShieldBuff;
import mvz2.gamecontent.contraptions.Snipenser;
import mvz2.gamecontent.contraptions.VanillaContraptionID;
import mvz2.gamecontent.damages.VanillaDamageEffects;
import mvz2.gamecontent.effects.Explosion;
import mvz2.gamecontent.effects.VanillaEffectID;
import mvz2.gamecontent.pickups.VanillaPickupID;
import mvz2.gamecontent.seeds.VanillaBlueprintErrors;
import mvz2.gamecontent.seeds.VanillaBlueprintID;
import mvz2.gamecontent.sprites.VanillaSprites;
import mvz2.vanilla.audios.VanillaSoundID;
import mvz2.vanilla.callbacks.VanillaLevelCallbacks;
import mvz2.vanilla.callbacks.VanillaLevelCallbacks.PreTakeDamageParams;
import mvz2.vanilla.localization.VanillaStrings;
import mvz2.vanilla.properties.VanillaLevelPropertyMeta;
import mvz2logic.Global;
import mvz2logic.contents.enemies.LogicEnemyExt;
import pvzengine.entities.EntityTypes;
import mvz2logic.entities.HPBarVisibility;
import mvz2logic.entities.LogicEntityExt;
import mvz2logic.entities.LogicEntityProps;
import mvz2logic.inputs.PointerTypes;
import mvz2logic.level.GameOverTypes;
import mvz2logic.level.LogicAreaProps;
import mvz2logic.level.LogicLevelExt;
import mvz2logic.level.LogicLevelProps;
import mvz2logic.localization.LogicStrings;
import mvz2logic.modifiers.SpriteReferenceModifier;
import pvzengine.EntityID;
import pvzengine.NamespaceID;
import pvzengine.callbacks.CallbackResult;
import pvzengine.callbacks.LevelCallbacks;
import pvzengine.callbacks.LevelCallbacks.EntityDeathParams;
import pvzengine.damages.DamageEffectList;
import pvzengine.entities.Entity;
import pvzengine.entities.SpawnParams;
import pvzengine.level.LevelEngine;
using mvz2.vanilla.pickups.VanillaPickupExt;
import pvzengine.level.StageBehaviour;
import pvzengine.level.StageDefinition;
import pvzengine.modifiers.NamespaceIDModifier;
import pvzengine.modifiers.SetOperator;
import unity.Mathf;
import unity.Vector3;

class HeavyWeaponStageBehaviour extends StageBehaviour
{
    public function new(stageDef:StageDefinition)
    {
        super(stageDef);
        AddModifier(new NamespaceIDModifier(LogicLevelProps.STARSHARD_DISABLE_ID, SetOperator.Set, VanillaBlueprintErrors.locked));
        AddModifier(new SpriteReferenceModifier(LogicAreaProps.STARSHARD_ICON, SetOperator.Set, VanillaSprites.snipenserLife));
        stageDef.AddTrigger(VanillaLevelCallbacks.PRE_ENTITY_TAKE_DAMAGE, PreContraptionTakeDamageCallback, EntityTypes.PLANT);
        stageDef.AddTrigger(LevelCallbacks.POST_ENTITY_DEATH, PostContraptionDeathCallback, EntityTypes.PLANT);
    }
    override public function Start(level:LevelEngine):Void
    {
        super.Start(level);
        LogicLevelExt.SetPickaxeActive(level, false);
        LogicLevelExt.SetTriggerActive(level, false);
        LogicLevelProps.SetStarshardCount(level, 2);
        LogicLevelProps.SetStarshardSlotCount(level, 2);
        ShowTip(level);

        RespawnSnipenser(level);
    }
    override public function Update(level:LevelEngine):Void
    {
        super.Update(level);
        if (level.CurrentWave >= 1)
        {
            var snipenserReference = GetSnipenserReference(level);
            var snipenser = snipenserReference != null ? snipenserReference.GetEntity(level) : null;
            if (snipenser == null || !snipenser.ExistsAndAlive())
            {
                if (LogicLevelProps.GetStarshardCount(level) > 0)
                {
                    RespawnSnipenser(level);
                    LogicLevelProps.AddStarshardCount(level, -1);
                }
                else
                {
                    level.GameOver(GameOverTypes.NO_ENEMY, null, VanillaStrings.DEATH_MESSAGE_SNIPENSER_LOST);
                }
            }
            else if (!LogicEntityExt.IsFriendlyEntity(snipenser))
            {
                var damageEffects = new DamageEffectList(VanillaDamageEffects.INSTA_KILL);
                snipenser.Die(damageEffects);
            }
        }
    }
    private function RespawnSnipenser(level:LevelEngine):Void
    {
        var rail = SpawnOrFindRail(level);
        if (rail != null)
        {
            var cart = SpawnOrFindMinecart(level, rail);
            if (cart != null)
            {
                cart.SetParent(rail);

                var snipenser = SpawnOrFindSnipenser(level, cart);
                if (snipenser != null)
                {
                    LogicEnemyExt.RideOn(snipenser, cart);
                    SetSnipenserReference(level, new EntityID(snipenser));
                    snipenser.AddBuff(DreamButterflyShieldBuff);
                }
            }
        }
    }

    private function SpawnOrFindRail(level:LevelEngine):Null<Entity>
    {
        var rail = level.FindFirstEntity(VanillaEffectID.minecartRail);
        if (rail != null && rail.ExistsAndAlive())
            return rail;
        return level.Spawn(VanillaEffectID.minecartRail, new Vector3(level.GetEntityColumnX(0), 0, level.GetEntityLaneZ(2)), null);
    }
    private function SpawnOrFindMinecart(level:LevelEngine, rail:Entity):Null<Entity>
    {
        var minecart = level.FindFirstEntity(VanillaEffectID.minecartRideable);
        if (minecart != null && minecart.ExistsAndAlive())
            return minecart;
        return level.Spawn(VanillaEffectID.minecartRideable, rail.Position, rail);
    }
    private function SpawnOrFindSnipenser(level:LevelEngine, cart:Entity):Null<Entity>
    {
        var snipenser = level.FindFirstEntity(VanillaContraptionID.snipenser);
        if (snipenser != null && snipenser.ExistsAndAlive())
            return snipenser;
        var param = new SpawnParams();
        param.SetProperty(LogicEntityProps.GRID_LAYERS, new Array<NamespaceID>());
        param.SetProperty(LogicEntityProps.HP_BAR_VISIBILITY, HPBarVisibility.FORCE);
        return level.Spawn(VanillaContraptionID.snipenser, cart.Position, cart, param);
    }
    private function PreContraptionTakeDamageCallback(param:PreTakeDamageParams, result:CallbackResult):Void
    {
        var input = param.input;
        var entity = input.Entity;
        var level = entity.Level;
        if (LogicLevelExt.HasBehaviour(level, this) && LogicLevelProps.IsGodMode(level))
        {
            var snipenserReference = GetSnipenserReference(level);
            if (snipenserReference != null && snipenserReference.IsEntity(entity))
            {
                result.SetFinalValue(false);
            }
        }
    }
    private function PostContraptionDeathCallback(param:EntityDeathParams, result:CallbackResult):Void
    {
        var entity = param.entity;
        var level = entity.Level;
        if (LogicLevelExt.HasBehaviour(level, this))
        {
            var snipenserReference = GetSnipenserReference(level);
            if (snipenserReference != null && snipenserReference.IsEntity(entity))
            {
                var rapidUpgrade = Snipenser.GetRapidLevel(entity);
                var spreadUpgrade = Snipenser.GetSpreadLevel(entity);
                var rapidDefinition = level.Content.GetSeedDefinition(VanillaBlueprintID.heavyWeaponRapid);
                var spreadDefinition = level.Content.GetSeedDefinition(VanillaBlueprintID.heavyWeaponSpread);
                var rapidCost = rapidDefinition != null ? rapidDefinition.GetCost() : 0;
                var spreadCost = spreadDefinition != null ? spreadDefinition.GetCost() : 0;
                var rapidRedStones = Std.int(Mathf.Max(0, rapidCost - 25) / 25);
                var spreadRedstones = Std.int(Mathf.Max(0, spreadCost - 25) / 25);
                var totalRedstones = rapidUpgrade * rapidRedStones + spreadUpgrade * spreadRedstones;

                for (i in 0...totalRedstones)
                {
                    entity.Produce(VanillaPickupID.redstone);
                }

                Explosion.Spawn(entity, entity.GetCenter(), 120);
                LogicEntityExt.PlaySound(entity, VanillaSoundID.largeExplosion);
            }
        }
    }

    private function ShowTip(level:LevelEngine):Void
    {
        var textKey = VanillaStrings.ADVICE_HEAVY_WEAPON_TIP_MOUSE;
        if (Global.Input.GetActivePointerType() == PointerTypes.TOUCH)
        {
            textKey = VanillaStrings.ADVICE_HEAVY_WEAPON_TIP_TOUCH;
        }
        LogicLevelExt.ShowAdvice(level, LogicStrings.CONTEXT_ADVICE, textKey, 100, 150, []);
    }

    public static function GetSnipenserReference(level:LevelEngine):Null<EntityID> return level.GetProperty(PROP_SNIPENSER_REFERENCE);
    public static function SetSnipenserReference(level:LevelEngine, value:Null<EntityID>):Void level.SetProperty(PROP_SNIPENSER_REFERENCE, value);
    private static inline var PROP_REGION:String = "heavy_weapon_stage";
    @:levelPropertyRegistry(PROP_REGION)
    public static var PROP_SNIPENSER_REFERENCE:VanillaLevelPropertyMeta<EntityID> = new VanillaLevelPropertyMeta<EntityID>("snipenser_reference");
}
