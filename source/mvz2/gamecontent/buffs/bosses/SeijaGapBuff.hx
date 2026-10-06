// Ported from: Assets/Scripts/Vanilla/GameContent/Buffs/Boss/Chapter3/SeijaGapBuff.cs
package mvz2.gamecontent.buffs.bosses;

import mvz2.gamecontent.buffs.VanillaBuffNames;
import mvz2.vanilla.modifiers.VanillaModifierPriorities;
import mvz2.vanilla.properties.VanillaBuffPropertyMeta;
import mvz2logic.entities.LogicEntityProps;
import pvzengine.buffs.Buff;
import pvzengine.collisions.EntityCollisionHelper;
import pvzengine.definitions.BuffDefinition;
import pvzengine.entities.EngineEntityProps;
import pvzengine.modifiers.BooleanModifier;
import pvzengine.modifiers.IntModifier;
import pvzengine.modifiers.IntegerOperator;
import pvzengine.modifiers.NumberOperator;
import pvzengine.modifiers.Vector3Modifier;
import unity.Mathf;
import unity.Vector3;

@:autoBuffDefinition(VanillaBuffNames.Boss_seijaGap)
class SeijaGapBuff extends BuffDefinition
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
        AddModifier(new IntModifier(EngineEntityProps.COLLISION_DETECTION, IntegerOperator.BitOr, EntityCollisionHelper.DETECTION_NO_COLLISION, VanillaModifierPriorities.FORCE));
        AddModifier(new BooleanModifier(EngineEntityProps.INVINCIBLE, true));
        AddModifier(new Vector3Modifier(LogicEntityProps.SHADOW_SCALE, NumberOperator.Multiply, PROP_SHADOW_SCALE));
    }

    public override function PostUpdate(buff:Buff):Void
    {
        super.PostUpdate(buff);
        var time = buff.GetProperty(PROP_TIME);
        time++;
        time = Mathf.ClampInt(time, 0, MAX_TIME);
        buff.SetProperty(PROP_TIME, time);
        buff.SetProperty(PROP_SHADOW_SCALE, Vector3.one * Mathf.Clamp01(1 - time / TIME_THRESOLD));
    }
    public static inline var TIME_THRESOLD:Int = 20;
    public static inline var MAX_TIME:Int = 40;
    public static var PROP_TIME:VanillaBuffPropertyMeta<Int> = new VanillaBuffPropertyMeta<Int>("Time");
    public static var PROP_SHADOW_SCALE:VanillaBuffPropertyMeta<Vector3> = new VanillaBuffPropertyMeta<Vector3>("ShadowScale");
}
