// Ported from: Assets/Scripts/Vanilla/GameContent/Buffs/Contraption/Chapter2/VortexHopperSpinBuff.cs
package mvz2.gamecontent.buffs.contraptions;

import mvz2.gamecontent.buffs.VanillaBuffNames;
import mvz2.gamecontent.buffs.enemies.VortexHopperDragBuff;
import mvz2.gamecontent.damages.VanillaDamageEffects;
import mvz2.vanilla.entities.VanillaEntityExt;
import mvz2.vanilla.entities.VanillaEntityProps;
import mvz2.vanilla.enemies.VanillaEnemyProps;
import pvzengine.buffs.Buff;
import pvzengine.damages.DamageEffectList;
import pvzengine.definitions.BuffDefinition;
import pvzengine.entities.EngineEntityProps;
import pvzengine.entities.Entity;
import pvzengine.entities.EntityTypes;
import pvzengine.modifiers.BooleanModifier;
import pvzengine.modifiers.FloatModifier;
import pvzengine.modifiers.NumberOperator;
import unity.Vector2;

@:autoBuffDefinition(VanillaBuffNames.Contraption_vortexHopperSpin)
class VortexHopperSpinBuff extends BuffDefinition
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
        AddModifier(new BooleanModifier(EngineEntityProps.INVINCIBLE, true));
        AddModifier(new BooleanModifier(VanillaEntityProps.CAN_DEACTIVE, false));
        AddModifier(new FloatModifier(EngineEntityProps.GRAVITY, NumberOperator.Multiply, 0));
    }
    public override function PostAdd(buff:Buff):Void
    {
        super.PostAdd(buff);
        var entity = buff.GetEntity();
        if (entity == null)
            return;
        DragEnemiesNearby(entity);
    }
    public override function PostUpdate(buff:Buff):Void
    {
        super.PostUpdate(buff);
        var entity = buff.GetEntity();
        if (entity == null)
            return;
        DragEnemiesNearby(entity);

        var vel = entity.Velocity;
        vel.y = -1;
        entity.Velocity = vel;
        if (entity.GetRelativeY() <= -48)
        {
            entity.Remove();
        }
    }

    public static function DragEnemiesNearby(hopper:Entity):Void
    {
        for (target in hopper.Level.FindEntities(function(e) return e.Type == EntityTypes.ENEMY && IsValidEnemy(hopper, e) && IsInRange(hopper, e)))
        {
            DragEnemy(hopper, target);
        }
    }
    public static function DragEnemy(hopper:Entity, enemy:Entity):Void
    {
        if (enemy.IsDead || enemy.HasBuff(VortexHopperDragBuff))
            return;
        if (VanillaEnemyProps.ImmuneVortex(enemy))
            return;
        enemy.Die(new DamageEffectList([VanillaDamageEffects.DROWN, VanillaDamageEffects.NO_DEATH_EFFECTS]), hopper);
        var hopperPos = hopper.Position;
        hopperPos.y = hopper.GetGroundY();
        var hopperPos2D = new Vector2(hopper.Position.x, hopper.Position.z);
        var targetPos2D = new Vector2(enemy.Position.x, enemy.Position.z);
        var buff = enemy.AddBuff(VortexHopperDragBuff);
        buff.SetProperty(VortexHopperDragBuff.PROP_CENTER, hopperPos);
        buff.SetProperty(VortexHopperDragBuff.PROP_RADIUS, Vector2.Distance(targetPos2D, hopperPos2D));
        buff.SetProperty(VortexHopperDragBuff.PROP_ANGLE, Vector2.SignedAngle(Vector2.right, targetPos2D - hopperPos2D));
    }
    public static function IsInRange(hopper:Entity, target:Entity):Bool
    {
        var hopperPos = new Vector2(hopper.Position.x, hopper.Position.z);
        var targetPos = new Vector2(target.Position.x, target.Position.z);
        var distance = Vector2.Distance(hopperPos, targetPos);
        return distance < VanillaEntityProps.GetRange(hopper);
    }
    public static function IsValidEnemy(hopper:Entity, target:Entity):Bool
    {
        return !target.IsDead && hopper.IsHostile(target) && VanillaEntityExt.IsInWater(target);
    }
}
