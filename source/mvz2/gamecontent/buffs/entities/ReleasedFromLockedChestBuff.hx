// Ported from: Assets/Scripts/Vanilla/GameContent/Buffs/Entity/Chapter6/ReleasedFromLockedChestBuff.cs
package mvz2.gamecontent.buffs.entities;

import mvz2.gamecontent.buffs.VanillaBuffNames;
import mvz2.vanilla.entities.VanillaEntityProps;
import mvz2.vanilla.properties.VanillaBuffPropertyMeta;
import mvz2logic.entities.LogicEntityProps;
import pvzengine.buffs.Buff;
import pvzengine.definitions.BuffDefinition;
import pvzengine.entities.EngineEntityProps;
import pvzengine.entities.EntityCollisionHelper;
import pvzengine.modifiers.BooleanModifier;
import pvzengine.modifiers.IntModifier;
import pvzengine.modifiers.IntegerOperator;
import pvzengine.modifiers.NumberOperator;
import pvzengine.modifiers.Vector3Modifier;
import tools.FrameTimer;
import unity.Vector3;

@:autoBuffDefinition(VanillaBuffNames.Entity_releasedfromLockedChest)
class ReleasedFromLockedChestBuff extends BuffDefinition
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
        AddModifier(new Vector3Modifier(EngineEntityProps.DISPLAY_SCALE, NumberOperator.Multiply, PROP_SCALE));
        AddModifier(new Vector3Modifier(LogicEntityProps.SHADOW_SCALE, NumberOperator.Multiply, PROP_SCALE));
        AddModifier(new Vector3Modifier(EngineEntityProps.SCALE, NumberOperator.Multiply, PROP_SCALE));
        AddModifier(new BooleanModifier(VanillaEntityProps.INVISIBLE, true));
        AddModifier(new BooleanModifier(EngineEntityProps.INVINCIBLE, true));
        AddModifier(new IntModifier(EngineEntityProps.COLLISION_DETECTION, IntegerOperator.BitOr, EntityCollisionHelper.DETECTION_NO_COLLISION));
    }
    public override function OnCreate(buff:Buff):Void
    {
        super.OnCreate(buff);
        buff.SetProperty(PROP_TIMER, new FrameTimer(TIMEOUT));
    }
    public override function PostUpdate(buff:Buff):Void
    {
        super.PostUpdate(buff);
        var timer = buff.GetProperty(PROP_TIMER);
        if (timer != null)
        {
            timer.Run();
            buff.SetProperty(PROP_SCALE, Vector3.one * timer.GetPassedPercentage());
        }
        if (timer == null || timer.Expired)
        {
            buff.Remove();
        }
    }
    public static inline var TIMEOUT:Int = 15;
    public static var PROP_TIMER:VanillaBuffPropertyMeta<FrameTimer> = new VanillaBuffPropertyMeta<FrameTimer>("timer");
    public static var PROP_SCALE:VanillaBuffPropertyMeta<Vector3> = new VanillaBuffPropertyMeta<Vector3>("scale");
}
