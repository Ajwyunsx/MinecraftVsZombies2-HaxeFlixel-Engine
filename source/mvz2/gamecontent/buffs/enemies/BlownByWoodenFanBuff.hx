// Ported from: Assets/Scripts/Vanilla/GameContent/Buffs/Enemies/Chapter5/BlownByWoodenFanBuff.cs
package mvz2.gamecontent.buffs.enemies;

import haxe.Int64;
import mvz2.gamecontent.buffs.VanillaBuffNames;
import mvz2.vanilla.enemies.VanillaEnemyExt;
import mvz2.vanilla.enemies.VanillaMass;
import mvz2.vanilla.entities.VanillaEntityExt;
import mvz2.vanilla.entities.VanillaEntityProps;
import mvz2.vanilla.properties.VanillaBuffPropertyMeta;
import pvzengine.buffs.Buff;
import pvzengine.definitions.BuffDefinition;
import pvzengine.entities.Entity;
import unity.Mathf;
using mvz2logic.contents.enemies.LogicEnemyExt;

@:autoBuffDefinition(VanillaBuffNames.Enemy_blownByWoodenFan)
class BlownByWoodenFanBuff extends BuffDefinition
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
    }
    public override function PostUpdate(buff:Buff):Void
    {
        super.PostUpdate(buff);
        var entity = buff.GetEntity();
        if (entity == null)
            return;
        if (entity.GetRidingEntity() != null)
            return;

        var sourceID = GetSourceID(buff);
        var source = buff.Level.FindEntityByID(sourceID);
        var toLeft = source != null ? source.IsFacingLeft() : false;
        var mass = GetBlowMass(entity);
        if (mass <= VanillaMass.LIGHT)
        {
            var velocity = entity.Velocity;
            if (toLeft)
            {
                velocity.x = Mathf.Min(velocity.x, -BLOW_AWAY_SPEED);
            }
            else
            {
                velocity.x = Mathf.Max(velocity.x, BLOW_AWAY_SPEED);
            }
            entity.Velocity = velocity;

            if (mass <= VanillaMass.VERY_LIGHT)
            {
                if (toLeft && VanillaEnemyExt.IsEnemyOutsideLeft(entity, BLOW_AWAY_SPEED) || !toLeft && VanillaEnemyExt.IsEnemyOutsideRight(entity, BLOW_AWAY_SPEED))
                {
                    VanillaEntityExt.RemoveDieWithSource(entity, source);
                }
            }
        }
        else if (mass <= VanillaMass.MEDIUM)
        {
            var velocity = entity.Velocity;
            if (toLeft)
            {
                velocity.x = Mathf.Min(velocity.x, -KNOCKBACK_SPEED);
            }
            else
            {
                velocity.x = Mathf.Max(velocity.x, KNOCKBACK_SPEED);
            }
            entity.Velocity = velocity;
        }
    }
    public static function GetBlowMass(entity:Entity):Float
    {
        var mass = VanillaEntityProps.GetMass(entity) + VanillaEntityProps.GetBlowMassOffset(entity);
        // 被吹起的敌人应当被判定为轻量
        // 防止贴地的敌人被吹起时直接吹飞
        var onGround = entity.IsOnGround || (entity.GetGravity() >= 0.001 && entity.GetRelativeY() <= 3);
        if (!onGround || VanillaEntityExt.IsInCloud(entity))
        {
            mass -= 2;
        }
        return mass;
    }
    public static function GetSourceID(buff:Buff):Int64 return buff.GetProperty(PROP_SOURCE_ID);
    public static function SetSourceID(buff:Buff, value:Int64):Void buff.SetProperty(PROP_SOURCE_ID, value);
    public static var PROP_SOURCE_ID:VanillaBuffPropertyMeta<Int64> = new VanillaBuffPropertyMeta<Int64>("source_id");
    public static inline var BLOW_AWAY_SPEED:Float = 40;
    public static inline var KNOCKBACK_SPEED:Float = 3;
}
