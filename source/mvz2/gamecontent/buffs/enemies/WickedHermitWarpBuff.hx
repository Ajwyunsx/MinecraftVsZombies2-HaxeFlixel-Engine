// Ported from: Assets/Scripts/Vanilla/GameContent/Buffs/Enemies/Chapter4/WickedHermitWarpBuff.cs
package mvz2.gamecontent.buffs.enemies;

import mvz2.gamecontent.buffs.VanillaBuffNames;
import mvz2.gamecontent.difficulties.VanillaDifficultyLevelProps;
import mvz2.vanilla.entities.VanillaEntityExt;
import mvz2.vanilla.properties.VanillaBuffPropertyMeta;
import pvzengine.buffs.Buff;
import pvzengine.definitions.BuffDefinition;
import pvzengine.entities.EngineEntityProps;
import pvzengine.entities.Entity;
import pvzengine.entities.EntityCollisionHelper;
import pvzengine.modifiers.IntModifier;
import pvzengine.modifiers.IntegerOperator;
import tools.FrameTimer;
import unity.Mathf;
import unity.Vector3;

@:autoBuffDefinition(VanillaBuffNames.Enemy_wickedHermitWarp)
class WickedHermitWarpBuff extends BuffDefinition
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
        AddModifier(new IntModifier(EngineEntityProps.COLLISION_DETECTION, IntegerOperator.BitOr, EntityCollisionHelper.DETECTION_NO_COLLISION));
    }
    public override function PostAdd(buff:Buff):Void
    {
        super.PostAdd(buff);
        buff.SetProperty(PROP_TIMER, new FrameTimer(MAX_TIME));
    }
    public override function PostUpdate(buff:Buff):Void
    {
        super.PostUpdate(buff);
        var timer = buff.GetProperty(PROP_TIMER);
        if (timer == null || timer.Expired)
        {
            buff.Remove();
            return;
        }

        timer.Run();

        var entity = buff.GetEntity();
        if (entity != null)
        {
            if (entity.IsDead)
            {
                buff.Remove();
                return;
            }
            if (timer.PassedFrame(WARP_TIME))
            {
                VanillaEntityExt.Stun(entity, GetStunDuration(entity));
                var position = entity.Position;
                var column = 0;
                position.x = entity.Level.GetEntityColumnX(column);
                entity.Position = position;
                entity.Velocity = new Vector3(0, 0, 0);
                entity.AddBuff(WickedHermitWarppedBuff);
            }
            var scaleT = 1 - Mathf.Abs(timer.Frame - WARP_TIME) / WARP_TIME;
            entity.SetAnimationFloat("WarpBlend", scaleT);
        }
        if (timer.Expired)
        {
            buff.Remove();
        }
    }
    public override function PostRemove(buff:Buff):Void
    {
        super.PostRemove(buff);
        var entity = buff.GetEntity();
        if (entity != null)
        {
            entity.SetAnimationFloat("WarpBlend", 0);
        }
    }
    public static function GetStunDuration(entity:Entity):Int
    {
        var level = entity.Level;
        return VanillaDifficultyLevelProps.GetWickedHermitZombieStunTime(level);
    }
    public static inline var MAX_TIME:Int = 20;
    public static inline var WARP_TIME:Int = 10;
    public static var PROP_TIMER:VanillaBuffPropertyMeta<FrameTimer> = new VanillaBuffPropertyMeta<FrameTimer>("timer");
}
