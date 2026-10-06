// Ported from: Assets/Scripts/Vanilla/GameContent/Buffs/Enemies/Chapter2/MotherTerrorLaidBuff.cs
package mvz2.gamecontent.buffs.enemies;

import mvz2.gamecontent.buffs.VanillaBuffNames;
import mvz2.vanilla.enemies.VanillaEnemyProps;
import mvz2.vanilla.properties.VanillaBuffPropertyMeta;
import pvzengine.buffs.Buff;
import pvzengine.definitions.BuffDefinition;
import pvzengine.modifiers.FloatModifier;
import pvzengine.modifiers.NumberOperator;
import tools.FrameTimer;

@:autoBuffDefinition(VanillaBuffNames.Enemy_motherTerrorLaid)
class MotherTerrorLaidBuff extends BuffDefinition
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
        AddModifier(new FloatModifier(VanillaEnemyProps.SPEED, NumberOperator.Multiply, 0.3));
    }
    public override function PostAdd(buff:Buff):Void
    {
        super.PostAdd(buff);
        buff.SetProperty(PROP_TIMER, new FrameTimer(600));
    }
    public override function PostUpdate(buff:Buff):Void
    {
        super.PostUpdate(buff);
        var timer = buff.GetProperty(PROP_TIMER);
        if (timer == null)
        {
            buff.Remove();
            return;
        }
        if (timer.RunToExpired())
        {
            buff.Remove();
        }
    }
    public static var PROP_TIMER:VanillaBuffPropertyMeta<FrameTimer> = new VanillaBuffPropertyMeta<FrameTimer>("timer");
}
