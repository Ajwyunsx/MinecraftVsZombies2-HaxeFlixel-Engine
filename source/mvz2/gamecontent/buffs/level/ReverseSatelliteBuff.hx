// Ported from: Assets/Scripts/Vanilla/GameContent/Buffs/Level/Chapter3/ReverseSatelliteBuff.cs
package mvz2.gamecontent.buffs.level;

import mvz2.gamecontent.buffs.VanillaBuffNames;
import mvz2.gamecontent.enemies.VanillaEnemyID;
import mvz2.vanilla.audios.VanillaSoundID;
import mvz2.vanilla.properties.VanillaBuffPropertyMeta;
import mvz2logic.level.LogicLevelExt;
import mvz2logic.level.LogicLevelProps;
import pvzengine.buffs.Buff;
import pvzengine.definitions.BuffDefinition;
import pvzengine.modifiers.FloatModifier;
import pvzengine.modifiers.NumberOperator;
import tools.Transitions;
import unity.Mathf;

@:autoBuffDefinition(VanillaBuffNames.Level_reverseSatellite)
class ReverseSatelliteBuff extends BuffDefinition
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
        AddModifier(new FloatModifier(LogicLevelProps.CAMERA_ROTATION, NumberOperator.Add, PROP_CAMERA_ROTATION));
    }
    public override function PostAdd(buff:Buff):Void
    {
        super.PostAdd(buff);
        LogicLevelExt.PlaySound(buff.Level, VanillaSoundID.boon);
    }
    public override function PostUpdate(buff:Buff):Void
    {
        super.PostUpdate(buff);
        var time = buff.GetProperty(PROP_TIME);
        time++;
        buff.SetProperty(PROP_TIME, time);

        var timeout = buff.GetProperty(PROP_TIMEOUT);
        if (buff.Level.EntityExists(VanillaEnemyID.reverseSatellite))
        {
            timeout = MAX_TIMEOUT;
        }
        else
        {
            timeout--;
        }
        buff.SetProperty(PROP_TIMEOUT, timeout);


        var rotation = Mathf.Min(time, timeout) / MAX_TIMEOUT;
        rotation = Transitions.EaseInAndOut(rotation);
        buff.SetProperty(PROP_CAMERA_ROTATION, rotation * MAX_ROTATION);
        if (timeout <= 0)
        {
            buff.Remove();
        }
    }
    public static var PROP_CAMERA_ROTATION:VanillaBuffPropertyMeta<Float> = new VanillaBuffPropertyMeta<Float>("CameraRotation");
    public static var PROP_TIME:VanillaBuffPropertyMeta<Int> = new VanillaBuffPropertyMeta<Int>("Time");
    public static var PROP_TIMEOUT:VanillaBuffPropertyMeta<Int> = new VanillaBuffPropertyMeta<Int>("Timeout");
    public static inline var MAX_TIMEOUT:Int = 30;
    public static inline var MAX_ROTATION:Int = 180;
}
