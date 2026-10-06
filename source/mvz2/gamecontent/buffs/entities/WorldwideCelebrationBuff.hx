// Ported from: Assets/Scripts/Vanilla/GameContent/Buffs/Entity/RandomChina/WorldwideCelebrationBuff.cs
package mvz2.gamecontent.buffs.entities;

import mvz2.gamecontent.buffs.VanillaBuffNames;
import mvz2.vanilla.enemies.VanillaEnemyProps;
import mvz2.vanilla.entities.VanillaEntityProps;
import mvz2.vanilla.properties.VanillaBuffPropertyMeta;
import pvzengine.buffs.Buff;
import pvzengine.definitions.BuffDefinition;
import pvzengine.modifiers.FloatModifier;
import pvzengine.modifiers.NumberOperator;
import tools.FrameTimer;

@:autoBuffDefinition(VanillaBuffNames.Entity_worldwideCelebration)
class WorldwideCelebrationBuff extends BuffDefinition
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
        AddModifier(new FloatModifier(VanillaEnemyProps.SPEED, NumberOperator.Multiply, 2));
        AddModifier(new FloatModifier(VanillaEntityProps.ATTACK_SPEED, NumberOperator.Multiply, 2));
        AddModifier(new FloatModifier(VanillaEntityProps.PRODUCE_SPEED, NumberOperator.Multiply, 2));
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
        if (timer.RunToExpiredOrNull())
        {
            buff.Remove();
        }
    }
    public static var PROP_TIMER:VanillaBuffPropertyMeta<FrameTimer> = new VanillaBuffPropertyMeta<FrameTimer>("Timer");
    public static inline var MAX_TIMEOUT:Int = 900;
}
