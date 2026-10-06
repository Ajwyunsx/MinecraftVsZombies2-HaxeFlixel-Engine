// Ported from: Assets/Scripts/Vanilla/GameContent/Buffs/Entity/Core/TemporaryUpdateBeforeGameBuff.cs
package mvz2.gamecontent.buffs.entities;

import mvz2.gamecontent.buffs.VanillaBuffNames;
import mvz2.vanilla.properties.VanillaBuffPropertyMeta;
import mvz2logic.entities.LogicEntityProps;
import pvzengine.buffs.Buff;
import pvzengine.definitions.BuffDefinition;
import pvzengine.modifiers.BooleanModifier;
import tools.FrameTimer;

@:autoBuffDefinition(VanillaBuffNames.Entity_temporaryUpdateBeforeGame)
class TemporaryUpdateBeforeGameBuff extends BuffDefinition
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
        AddModifier(new BooleanModifier(LogicEntityProps.UPDATE_BEFORE_GAME, true));
    }
    public override function PostAdd(buff:Buff):Void
    {
        super.PostAdd(buff);
        buff.SetProperty(PROP_TIMER, new FrameTimer(32));
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
        timer.Run();
        if (timer.Expired)
        {
            buff.Remove();
            return;
        }
    }
    public static var PROP_TIMER:VanillaBuffPropertyMeta<FrameTimer> = new VanillaBuffPropertyMeta<FrameTimer>("Timer");
}
