// Ported from: Assets/Scripts/Vanilla/GameContent/Buffs/Level/Chapter5/BeaconMeteorBuff.cs
package mvz2.gamecontent.buffs.level;

import mvz2.gamecontent.buffs.VanillaBuffID;
import mvz2.gamecontent.buffs.VanillaBuffNames;
import mvz2.gamecontent.projectiles.VanillaProjectileID;
import mvz2.vanilla.audios.VanillaSoundID;
import mvz2.vanilla.entities.VanillaEntityProps;
import mvz2.vanilla.properties.VanillaBuffPropertyMeta;
import mvz2logic.entities.LogicEntityExt;
import mvz2logic.entities.LogicEntityProps;
import pvzengine.buffs.Buff;
import pvzengine.definitions.BuffDefinition;
import pvzengine.entities.EngineEntityProps;
import pvzengine.entities.Entity;
import pvzengine.entities.SpawnParams;
import pvzengine.level.LevelEngine;
import tools.FrameTimer;
import tools.RandomGenerator;
import unity.Vector3;

@:autoBuffDefinition(VanillaBuffNames.Level_beaconMeteor)
class BeaconMeteorBuff extends BuffDefinition
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
    }
    public override function OnCreate(buff:Buff):Void
    {
        super.OnCreate(buff);
        SetTimer(buff, new FrameTimer(90));
        SetState(buff, STATE_WAIT);
    }
    public override function PostUpdate(buff:Buff):Void
    {
        super.PostUpdate(buff);
        var state = GetState(buff);
        var timer = GetTimer(buff);
        switch (state)
        {
            case STATE_WAIT:
                if (timer != null)
                {
                    timer.Run();
                    if (timer.Expired)
                    {
                        timer.ResetTime(FALL_INTERVAL);
                        SetState(buff, STATE_FALL);
                    }
                }
            case STATE_FALL:
                if (timer != null)
                {
                    timer.Run();
                    if (timer.Expired)
                    {
                        timer.Reset();

                        var rng = GetRNG(buff);
                        if (rng != null)
                        {
                            SpawnMeteor(buff.Level, rng, GetFaction(buff), GetDamage(buff), GetHSVOffset(buff), GetVariant(buff));
                        }

                        var count = GetCount(buff);
                        count--;
                        SetCount(buff, count);
                        if (count <= 0)
                        {
                            buff.Remove();
                        }
                    }
                }
        }
    }
    public static function SpawnMeteor(level:LevelEngine, rng:RandomGenerator, faction:Int, damage:Float, hsvOffset:Vector3, variant:Int):Null<Entity>
    {
        var column = rng.Next(0, level.GetMaxColumnCount());
        var lane = rng.Next(0, level.GetMaxLaneCount());
        var x = level.GetEntityColumnX(column);
        var z = level.GetEntityLaneZ(lane);
        var y = level.GetGroundY(x, z);
        var landPos = new Vector3(x, y, z);

        var velX = rng.Next(VELOCITY_X_MIN, VELOCITY_X_MAX);
        var velZ = rng.Next(VELOCITY_Z_MIN, VELOCITY_Z_MAX);
        var velocity = new Vector3(velX, VELOCITY_Y, velZ);
        var pos = landPos - velocity * 30;

        var param = new SpawnParams();
        param.SetProperty(EngineEntityProps.FACTION, faction);
        param.SetProperty(VanillaEntityProps.DAMAGE, damage);
        param.SetProperty(LogicEntityProps.HSV_OFFSET, hsvOffset);
        param.SetProperty(LogicEntityProps.VARIANT, variant);
        // C#: level.Spawn(...)?.Let(e => { ... });
        var meteor = level.Spawn(VanillaProjectileID.beaconMeteor, pos, null, param);
        if (meteor != null)
        {
            meteor.Velocity = velocity;
            LogicEntityExt.PlaySound(meteor, VanillaSoundID.bombFalling);
            meteor.AddBuff(VanillaBuffID.Projectile.beaconMeteorNoDestroy);
        }
        return meteor;
    }
    public static function SetDamage(buff:Buff, value:Float):Void buff.SetProperty(PROP_DAMAGE, value);
    public static function GetDamage(buff:Buff):Float return buff.GetProperty(PROP_DAMAGE);
    public static function SetCount(buff:Buff, value:Int):Void buff.SetProperty(PROP_COUNT, value);
    public static function GetCount(buff:Buff):Int return buff.GetProperty(PROP_COUNT);
    public static function SetFaction(buff:Buff, value:Int):Void buff.SetProperty(PROP_FACTION, value);
    public static function GetFaction(buff:Buff):Int return buff.GetProperty(PROP_FACTION);
    public static function SetState(buff:Buff, value:Int):Void buff.SetProperty(PROP_STATE, value);
    public static function GetState(buff:Buff):Int return buff.GetProperty(PROP_STATE);
    public static function SetHSVOffset(buff:Buff, value:Vector3):Void buff.SetProperty(HSV_OFFSET, value);
    public static function GetHSVOffset(buff:Buff):Vector3 return buff.GetProperty(HSV_OFFSET);
    public static function SetVariant(buff:Buff, value:Int):Void buff.SetProperty(PROP_VARIANT, value);
    public static function GetVariant(buff:Buff):Int return buff.GetProperty(PROP_VARIANT);
    public static function SetTimer(buff:Buff, value:FrameTimer):Void buff.SetProperty(PROP_TIMER, value);
    public static function GetTimer(buff:Buff):Null<FrameTimer> return buff.GetProperty(PROP_TIMER);
    public static function SetRNG(buff:Buff, value:RandomGenerator):Void buff.SetProperty(PROP_RNG, value);
    public static function GetRNG(buff:Buff):Null<RandomGenerator> return buff.GetProperty(PROP_RNG);
    public static inline var VELOCITY_X_MIN:Float = -5;
    public static inline var VELOCITY_X_MAX:Float = 5;
    public static inline var VELOCITY_Z_MIN:Float = -5;
    public static inline var VELOCITY_Z_MAX:Float = 5;
    public static inline var VELOCITY_Y:Float = -25;
    public static inline var STATE_WAIT:Int = 0;
    public static inline var STATE_FALL:Int = 1;
    public static inline var FALL_INTERVAL:Int = 6;
    public static inline var VARIANT_DEFAULT:Int = 0;
    public static inline var VARIANT_BOULDER:Int = 1;
    public static var PROP_DAMAGE:VanillaBuffPropertyMeta<Float> = new VanillaBuffPropertyMeta<Float>("damage");
    public static var PROP_FACTION:VanillaBuffPropertyMeta<Int> = new VanillaBuffPropertyMeta<Int>("faction");
    public static var PROP_COUNT:VanillaBuffPropertyMeta<Int> = new VanillaBuffPropertyMeta<Int>("count");
    public static var HSV_OFFSET:VanillaBuffPropertyMeta<Vector3> = new VanillaBuffPropertyMeta<Vector3>("hsv_offset");
    public static var PROP_VARIANT:VanillaBuffPropertyMeta<Int> = new VanillaBuffPropertyMeta<Int>("variant");
    public static var PROP_TIMER:VanillaBuffPropertyMeta<FrameTimer> = new VanillaBuffPropertyMeta<FrameTimer>("timer");
    public static var PROP_RNG:VanillaBuffPropertyMeta<RandomGenerator> = new VanillaBuffPropertyMeta<RandomGenerator>("rng");
    public static var PROP_STATE:VanillaBuffPropertyMeta<Int> = new VanillaBuffPropertyMeta<Int>("state");
}
