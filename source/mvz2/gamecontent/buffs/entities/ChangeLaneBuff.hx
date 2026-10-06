// Ported from: Assets/Scripts/Vanilla/GameContent/Buffs/Entity/Core/ChangeLaneBuff.cs
package mvz2.gamecontent.buffs.entities;

import mvz2.gamecontent.buffs.VanillaBuffNames;
import mvz2.vanilla.properties.VanillaBuffPropertyMeta;
import pvzengine.buffs.Buff;
import pvzengine.definitions.BuffDefinition;
import unity.Mathf;

@:autoBuffDefinition(VanillaBuffNames.Entity_changeLane)
class ChangeLaneBuff extends BuffDefinition
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
        var targetLane = GetTarget(buff);
        if (targetLane < 0 || targetLane >= entity.Level.GetMaxLaneCount())
            return;
        var sourceLane = GetSource(buff);

        var targetZ = entity.Level.GetEntityLaneZ(targetLane);
        var pos = entity.Position;
        var velocity = entity.Velocity;
        var passed:Bool;
        if (sourceLane > targetLane) // Warp upwards.
        {
            passed = pos.z >= targetZ;
        }
        else // Warp downwards.
        {
            passed = pos.z <= targetZ;
        }

        if (!passed)
        {
            var warpSpeed = GetSpeed(buff);

            // Warp upwards.
            if (sourceLane > targetLane)
            {
                velocity.z = Mathf.Max(warpSpeed, entity.Velocity.z);
            }
            // Warp downwards.
            else
            {
                velocity.z = Mathf.Min(-warpSpeed, entity.Velocity.z);
            }
        }
        else
        {
            pos.z = targetZ;
            velocity.z = 0;
            Stop(buff);
        }
        entity.Position = pos;
        entity.Velocity = velocity;
    }
    public static function Start(buff:Buff, target:Int, source:Int, speed:Float):Void
    {
        var level = buff.Level;
        SetTarget(buff, target);
        SetSource(buff, source);
        SetSpeed(buff, speed);
    }
    public static function Stop(buff:Buff):Void
    {
        buff.Remove();
    }
    public static function GetSpeed(buff:Buff):Float return buff.GetProperty(PROP_SPEED);
    public static function SetSpeed(buff:Buff, value:Float):Void buff.SetProperty(PROP_SPEED, value);
    public static function GetTarget(buff:Buff):Int return buff.GetProperty(PROP_TARGET);
    public static function SetTarget(buff:Buff, value:Int):Void buff.SetProperty(PROP_TARGET, value);
    public static function GetSource(buff:Buff):Int return buff.GetProperty(PROP_SOURCE);
    public static function SetSource(buff:Buff, value:Int):Void buff.SetProperty(PROP_SOURCE, value);
    public static var PROP_SPEED:VanillaBuffPropertyMeta<Float> = new VanillaBuffPropertyMeta<Float>("speed");
    public static var PROP_TARGET:VanillaBuffPropertyMeta<Int> = new VanillaBuffPropertyMeta<Int>("target");
    public static var PROP_SOURCE:VanillaBuffPropertyMeta<Int> = new VanillaBuffPropertyMeta<Int>("source");
}
