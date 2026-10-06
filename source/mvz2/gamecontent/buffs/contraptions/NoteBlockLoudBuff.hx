// Ported from: Assets/Scripts/Vanilla/GameContent/Buffs/Contraption/Chapter4/NoteBlockLoudBuff.cs
package mvz2.gamecontent.buffs.contraptions;

import mvz2.gamecontent.buffs.VanillaBuffNames;
import mvz2.vanilla.entities.VanillaEntityProps;
import mvz2.vanilla.properties.VanillaBuffPropertyMeta;
import pvzengine.buffs.Buff;
import pvzengine.definitions.BuffDefinition;
import pvzengine.modifiers.FloatModifier;
import pvzengine.modifiers.NumberOperator;
import pvzengine.modifiers.Vector3Modifier;
import tools.FrameTimer;
import unity.Vector3;

@:autoBuffDefinition(VanillaBuffNames.Contraption_noteBlockLoud)
class NoteBlockLoudBuff extends BuffDefinition
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
        AddModifier(new FloatModifier(VanillaEntityProps.DAMAGE, NumberOperator.Multiply, 5));
        AddModifier(new Vector3Modifier(VanillaEntityProps.SHOT_VELOCITY, NumberOperator.Multiply, Vector3.one * 2));
        AddModifier(new FloatModifier(VanillaEntityProps.ATTACK_SPEED, NumberOperator.Multiply, 5));
        AddModifier(new FloatModifier(VanillaEntityProps.RANGE, NumberOperator.Add, 800));
    }
    public override function PostAdd(buff:Buff):Void
    {
        super.PostAdd(buff);
        buff.SetProperty(PROP_TIMER, new FrameTimer(MAX_TIMEOUT));
    }
    public override function PostUpdate(buff:Buff):Void
    {
        super.PostUpdate(buff);
        var timer = buff.GetProperty(PROP_TIMER);
        if (timer == null || timer.Expired)
        {
            buff.Remove();
        }
        else
        {
            timer.Run();
        }
    }
    public static inline var MAX_TIMEOUT:Int = 900;
    public static var PROP_TIMER:VanillaBuffPropertyMeta<FrameTimer> = new VanillaBuffPropertyMeta<FrameTimer>("timer");
}
