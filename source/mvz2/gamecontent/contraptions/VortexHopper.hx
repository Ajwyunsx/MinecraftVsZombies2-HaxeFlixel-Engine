// Ported from: Assets/Scripts/Vanilla/GameContent/Contraptions/Chapter2/VortexHopper.cs
package mvz2.gamecontent.contraptions;

import mvz2.gamecontent.buffs.VanillaBuffID;
import mvz2.gamecontent.buffs.contraptions.VortexHopperEvokedBuff;
import mvz2.gamecontent.buffs.contraptions.VortexHopperSpinBuff;
import mvz2.gamecontent.effects.VanillaEffectID;
import mvz2.vanilla.audios.VanillaSoundID;
import mvz2.vanilla.detection.Detection;
import mvz2.vanilla.entities.VanillaEntityExt;
import mvz2logic.entities.LogicEntityExt;
import mvz2logic.level.LogicLevelExt;
import pvzengine.buffs.BuffExt;
import pvzengine.entities.Entity;
import pvzengine.entities.EntityCollision;
import pvzengine.entities.EntityCollisionHelper;
import pvzengine.entities.EntityTypes;
import unity.Vector3;
using mvz2.vanilla.entities.VanillaColliderExt;
using mvz2.vanilla.entities.VanillaEntityProps;
using mvz2logic.entities.LogicContraptionProps;
using mvz2logic.entities.LogicEntityExt;

@:autoEntityBehaviourDefinition(VanillaContraptionNames.vortexHopper)
class VortexHopper extends ContraptionBehaviour
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
    }
    public override function Init(entity:Entity):Void
    {
        super.Init(entity);
        entity.CollisionMaskHostile |= EntityCollisionHelper.MASK_ENEMY;
    }
    override function UpdateLogic(entity:Entity):Void
    {
        super.UpdateLogic(entity);
        entity.SetAnimationBool("Spinning", IsSpinning(entity));
    }
    public override function PostCollision(collision:EntityCollision, state:Int):Void
    {
        super.PostCollision(collision, state);
        if (state == EntityCollisionHelper.STATE_EXIT)
            return;
        if (!collision.Collider.IsForMain())
            return;
        var hopper = collision.Entity;
        if (IsSpinning(hopper) || hopper.IsAIFrozen())
            return;
        var other = collision.Other;
        if (other.Type != EntityTypes.ENEMY && !Detection.CanDetect(other))
            return;
        if (!VortexHopperSpinBuff.IsValidEnemy(hopper, other))
            return;
        StartSpin(hopper);
        VortexHopperSpinBuff.DragEnemy(hopper, other);
    }
    public override function CanEvoke(entity:Entity):Bool
    {
        if (IsSpinning(entity))
        {
            return false;
        }
        return super.CanEvoke(entity);
    }
    override function OnEvoke(entity:Entity):Void
    {
        super.OnEvoke(entity);
        entity.SetEvoked(true);
        entity.AddBuff(VortexHopperEvokedBuff);
        StartSpin(entity);
    }

    static function StartSpin(hopper:Entity):Void
    {
        hopper.AddBuff(VortexHopperSpinBuff);
        hopper.PlaySound(VanillaSoundID.vortex);

        var pos = hopper.Position;
        pos.y = hopper.GetGroundY();

        // C#: hopper.Level.Spawn(...)?.Let(e => { ... })
        var vortex = hopper.Level.Spawn(VanillaEffectID.vortex, pos, hopper);
        if (vortex != null)
        {
            var vortexScale = hopper.GetRange() / 120;
            vortex.SetScale(Vector3.one * vortexScale);
            vortex.SetDisplayScale(Vector3.one * vortexScale);
        }
    }
    public static function IsSpinning(hopper:Entity):Bool
    {
        return hopper.HasBuff(VanillaBuffID.Contraption.vortexHopperSpin);
    }
}
