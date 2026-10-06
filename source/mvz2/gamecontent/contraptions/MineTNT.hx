// Ported from: Assets/Scripts/Vanilla/GameContent/Contraptions/Prologue/MineTNT.cs
package mvz2.gamecontent.contraptions;

import mvz2.gamecontent.buffs.contraptions.MineTNTInvincibleBuff;
import mvz2.gamecontent.damages.VanillaDamageEffects;
import mvz2.gamecontent.effects.VanillaEffectID;
import mvz2.gamecontent.projectiles.VanillaProjectileID;
import mvz2.vanilla.audios.VanillaSoundID;
import mvz2.vanilla.callbacks.VanillaLevelCallbacks;
import mvz2.vanilla.entities.VanillaEntityExt;
import mvz2.vanilla.entities.VanillaEntityProps;
import mvz2.vanilla.projectiles.VanillaProjectileExt;
import mvz2.vanilla.properties.VanillaEntityPropertyMeta;
import mvz2logic.entities.LogicEntityExt;
import mvz2logic.grids.LogicGridExt;
import mvz2logic.level.LogicLevelExt;
import pvzengine.NamespaceID;
import pvzengine.buffs.BuffExt;
import pvzengine.callbacks.EntityCallbackParams;
import pvzengine.damages.DamageEffectList;
import pvzengine.entities.Entity;
import pvzengine.entities.EntityCollisionHelper;
import pvzengine.entities.EntityCollision;
import pvzengine.grids.LawnGrid;
import tools.FrameTimer;
import unity.Mathf;
import unity.Vector3;
using mvz2.vanilla.entities.VanillaColliderExt;
using mvz2.vanilla.entities.VanillaEntityExt;
using mvz2.vanilla.entities.VanillaEntityProps;
using mvz2logic.entities.LogicEntityExt;
using tools.EnumerableExt;

@:autoEntityBehaviourDefinition(VanillaContraptionNames.mineTNT)
class MineTNT extends ContraptionBehaviour
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
    }
    public override function Init(entity:Entity):Void
    {
        super.Init(entity);

        entity.CollisionMaskHostile |= EntityCollisionHelper.MASK_ENEMY;

        var riseTimer = new FrameTimer(450);
        SetRiseTimer(entity, riseTimer);
        if (entity.Level.IsIZombie())
        {
            riseTimer.Frame = 0;
        }
        entity.SetAnimationBool("Ready", riseTimer.Frame < 30);
    }
    override function UpdateAI(entity:Entity):Void
    {
        super.UpdateAI(entity);
        RiseUpdate(entity);
    }

    override function OnEvoke(entity:Entity):Void
    {
        super.OnEvoke(entity);
        var riseTimer = GetRiseTimer(entity);
        if (riseTimer != null && riseTimer.Frame > 30)
        {
            riseTimer.Frame = 30;
        }
        var grids:Array<LawnGrid> = [];
        for (x in 0...entity.Level.GetMaxColumnCount())
        {
            for (y in 0...entity.Level.GetMaxLaneCount())
            {
                var grid = entity.Level.GetGrid(x, y);
                if (grid != null && grid.CanSpawnEntity(VanillaContraptionID.mineTNT))
                {
                    grids.push(grid);
                }
            }
        }
        // C#: grids.GroupBy(g => g.Column).OrderByDescending(g => g.Key).Take(2)
        var groups:Array<{key:Int, items:Array<LawnGrid>}> = [];
        for (g in grids)
        {
            var found = Lambda.find(groups, item -> item.key == g.Column);
            if (found == null)
            {
                found = {key: g.Column, items: []};
                groups.push(found);
            }
            found.items.push(g);
        }
        groups.sort((a, b) -> b.key - a.key);
        // C#: .SelectMany(g => g.Randomize(entity.RNG)).Take(2)
        var selectedGrids:Array<LawnGrid> = [];
        for (g in groups.slice(0, 2))
        {
            for (grid in g.items.Randomize(entity.RNG))
            {
                selectedGrids.push(grid);
            }
        }
        for (grid in selectedGrids.slice(0, 2))
        {
            FireSeed(entity, grid);
        }
    }
    public static function GetRiseTimer(entity:Entity):Null<FrameTimer>
    {
        return entity.GetBehaviourFieldNS(ID, PROP_RISE_TIMER);
    }
    public static function SetRiseTimer(entity:Entity, timer:FrameTimer):Void
    {
        entity.SetBehaviourFieldNS(ID, PROP_RISE_TIMER, timer);
    }
    function RiseUpdate(entity:Entity):Void
    {
        var riseTimer = GetRiseTimer(entity);
        if (riseTimer == null)
            return;
        riseTimer.Run(entity.GetAttackSpeed());

        if (riseTimer.Frame == 30)
        {
            entity.PlaySound(VanillaSoundID.dirtRise);
        }
        if (riseTimer.Frame < 30 && !riseTimer.Expired)
        {
            if (!entity.HasBuff(MineTNTInvincibleBuff))
                entity.AddBuff(MineTNTInvincibleBuff);
        }
        else
        {
            if (entity.HasBuff(MineTNTInvincibleBuff))
                entity.RemoveBuffs(MineTNTInvincibleBuff);
        }
        entity.SetAnimationBool("Ready", riseTimer.Frame < 30);
    }
    public override function PostCollision(collision:EntityCollision, state:Int):Void
    {
        super.PostCollision(collision, state);
        if (state == EntityCollisionHelper.STATE_EXIT)
            return;
        var other = collision.Other;
        if (!other.IsVulnerableEntity() || !other.ExistsAndAlive())
            return;
        var self = collision.Entity;
        if (!self.IsHostile(other))
            return;
        var otherCollider = collision.OtherCollider;
        if (!otherCollider.IsForMain())
            return;
        var riseTimer = GetRiseTimer(self);
        if (riseTimer == null || !riseTimer.Expired)
            return;
        var damageEffects = new DamageEffectList([VanillaDamageEffects.MUTE, VanillaDamageEffects.IGNORE_ARMOR, VanillaDamageEffects.REMOVE_ON_DEATH, VanillaDamageEffects.NO_DEATH_EFFECTS, VanillaDamageEffects.EXPLOSION]);
        self.Explode(self.Position, self.GetRange(), self.GetFaction(), self.GetDamage(), damageEffects);
        self.Level.Spawn(VanillaEffectID.mineDebris, self.Position, self);
        self.Remove();
        self.PlaySound(VanillaSoundID.mineExplode);
        self.Level.ShakeScreen(10, 0, 15);
        self.Level.Triggers.RunCallbackFiltered(VanillaLevelCallbacks.POST_CONTRAPTION_DETONATE, new EntityCallbackParams(self), self.GetDefinitionID());
    }
    static function FireSeed(contraption:Entity, grid:LawnGrid):Null<Entity>
    {
        var level = contraption.Level;

        var seed = level.Spawn(VanillaProjectileID.mineTNTSeed, contraption.Position, contraption);
        // C#: ?.Let(e => { ... })
        if (seed != null)
        {
            var x = level.GetEntityColumnX(grid.Column);
            var z = level.GetEntityLaneZ(grid.Lane);
            var y = level.GetGroundY(x, z);
            var target = new Vector3(x, y, z);
            var maxY = Mathf.Max(contraption.Position.y, y) + 32;
            seed.Velocity = VanillaProjectileExt.GetLobVelocity(contraption.Position, target, maxY, seed.GetGravity());
        }

        return seed;
    }
    static var ID:NamespaceID = VanillaContraptionID.mineTNT;
    static var PROP_RISE_TIMER:VanillaEntityPropertyMeta<FrameTimer> = new VanillaEntityPropertyMeta<FrameTimer>("RiseTimer");
}
