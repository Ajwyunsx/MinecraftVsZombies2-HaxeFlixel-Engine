// Ported from: Assets/Scripts/Vanilla/GameContent/Contraptions/Chapter6/Nuke.cs
package mvz2.gamecontent.contraptions;

import mvz2.gamecontent.buffs.grids.BrokenTileBuff;
import mvz2.gamecontent.damages.VanillaDamageEffects;
import mvz2.gamecontent.effects.VanillaEffectID;
import mvz2.gamecontent.entities.AIEntityBehaviour;
import mvz2.vanilla.audios.VanillaSoundID;
import mvz2.vanilla.callbacks.VanillaLevelCallbacks;
import mvz2.vanilla.contraptions.IExplodeContraptionBehaviour;
import mvz2.vanilla.entities.VanillaEntityExt;
import mvz2.vanilla.level.VanillaLevelExt;
import mvz2logic.entities.LogicEntityExt;
import mvz2logic.level.LogicLevelExt;
import pvzengine.EngineEntityProps;
import pvzengine.callbacks.EntityCallbackParams;
import pvzengine.damages.DamageEffectList;
import pvzengine.entities.Entity;
import pvzengine.entities.EntityTypes;
import pvzengine.entities.SpawnParams;
import pvzengine.grids.LawnGrid;
import pvzengine.level.LevelEngine;
import unity.Color;
import unity.Vector3;
using mvz2.vanilla.entities.VanillaEntityExt;
using mvz2logic.entities.LogicContraptionProps;

@:autoEntityBehaviourDefinition(VanillaContraptionNames.nuke)
class Nuke extends AIEntityBehaviour implements IExplodeContraptionBehaviour
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
    }
    public function Explode(contraption:Entity, range:Float, damage:Float):Void
    {
        if (contraption.IsEvoked())
        {
            ExplodeEvoked(contraption, range, damage);
            ExplodeEffectsEvoked(contraption);
        }
        else
        {
            ExplodeStatic(contraption, range, damage);
            ExplodeEffects(contraption);
        }

        if (contraption.GetRelativeY() < BREAK_TILE_HEIGHT)
        {
            BreakTile(contraption);
        }

        contraption.Level.Triggers.RunCallbackFiltered(VanillaLevelCallbacks.POST_CONTRAPTION_DETONATE, new EntityCallbackParams(contraption), contraption.GetDefinitionID());
    }
    // PORT-NOTE: C# 中显式接口实现与静态方法同名（Haxe 不允许静态/实例同名字段），静态方法改名为 ExplodeStatic。
    public static function ExplodeStatic(entity:Entity, range:Float, damage:Float):Void
    {
        var damageEffects = new DamageEffectList([VanillaDamageEffects.EXPLOSION, VanillaDamageEffects.DAMAGE_BODY_AFTER_ARMOR_BROKEN, VanillaDamageEffects.MUTE, VanillaDamageEffects.NO_DEATH_EFFECTS, VanillaDamageEffects.REMOVE_ON_DEATH]);
        var damageOutputs = entity.Explode(entity.GetCenter(), range, entity.GetFaction(), damage, damageEffects);
        VanillaLevelExt.ClearExplosionCorpses(damageOutputs);
    }
    public static function ExplodeEvoked(entity:Entity, range:Float, damage:Float):Void
    {
        var damageEffects = new DamageEffectList([VanillaDamageEffects.EXPLOSION, VanillaDamageEffects.DAMAGE_BODY_AFTER_ARMOR_BROKEN, VanillaDamageEffects.MUTE, VanillaDamageEffects.NO_DEATH_EFFECTS, VanillaDamageEffects.REMOVE_ON_DEATH]);
        var deathEffects = new DamageEffectList([VanillaDamageEffects.INSTA_KILL, VanillaDamageEffects.MUTE, VanillaDamageEffects.NO_DEATH_EFFECTS, VanillaDamageEffects.REMOVE_ON_DEATH]);
        for (ent in entity.Level.FindEntities(e -> entity.IsHostile(e) && e.IsVulnerableEntity() && !e.IsInvincible()))
        {
            if (ent.Type == EntityTypes.BOSS)
            {
                ent.TakeDamage(damage, damageEffects, entity);
            }
            else
            {
                ent.DieOrRemove(deathEffects, entity);
            }
        }
    }
    // PORT-NOTE: C# 的 ExplodeEffects(Entity) / ExplodeEffects(Entity, SpawnParams) 重载在 Haxe 中合并为带可选参数的一个方法；
    //           ExplodeEffects(LevelEngine, Vector3, Entity, SpawnParams) 改名为 ExplodeEffectsAt。
    public static function ExplodeEffects(entity:Entity, ?smokeSpawnParam:SpawnParams):Void
    {
        if (smokeSpawnParam == null)
        {
            smokeSpawnParam = entity.GetSpawnParams();
            smokeSpawnParam.SetProperty(EngineEntityProps.TINT, new Color(0, 0.5, 0, 1));
        }
        else
        {
            ExplodeEffectsAt(entity.Level, entity.Position, entity, smokeSpawnParam);
        }
    }
    public static function ExplodeEffectsAt(level:LevelEngine, position:Vector3, spawner:Null<Entity>, smokeSpawnParam:SpawnParams):Void
    {
        level.Spawn(VanillaEffectID.nukeSmoke, position, spawner, smokeSpawnParam);
        level.Spawn(VanillaEffectID.nukeFlash, level.GetLawnCenter(), spawner, smokeSpawnParam);
        LogicLevelExt.PlaySoundAt(level, VanillaSoundID.nukeblast, position);
        level.ShakeScreen(10, 0, 60);
    }
    public static function ExplodeEffectsEvoked(entity:Entity):Void
    {
        var smokeSpawnParam = entity.GetSpawnParams();
        smokeSpawnParam.SetProperty(EngineEntityProps.TINT, new Color(0, 0.25, 0, 1));
        smokeSpawnParam.SetProperty(EngineEntityProps.DISPLAY_SCALE, Vector3.one * 2);
        ExplodeEffects(entity, smokeSpawnParam);
    }
    public static function BreakTile(entity:Entity):Void
    {
        var grid = entity.GetGrid();
        if (grid == null)
            return;
        DestroyEntitiesInGrid(grid, entity);
        BrokenTileBuff.Break(grid);
    }
    public static function DestroyEntitiesInGrid(grid:LawnGrid, source:Entity):Void
    {
        var damageEffects = new DamageEffectList([VanillaDamageEffects.REMOVE_ON_DEATH, VanillaDamageEffects.INSTA_KILL]);
        for (entity in grid.GetEntities())
        {
            if (entity == source)
                continue;
            entity.DieOrRemove(damageEffects, entity);
        }
    }
    public static inline var BREAK_TILE_HEIGHT:Float = 64;
}
