// Ported from: Assets/Scripts/Vanilla/GameContent/Buffs/Level/Chapter4/AncientEgyptBuff.cs
package mvz2.gamecontent.buffs.level;

import mvz2.gamecontent.buffs.VanillaBuffNames;
import mvz2.vanilla.properties.VanillaBuffPropertyMeta;
import mvz2logic.level.LogicLevelProps;
import pvzengine.buffs.Buff;
import pvzengine.definitions.BuffDefinition;
import pvzengine.modifiers.BooleanModifier;
import tools.FrameTimer;

@:autoBuffDefinition(VanillaBuffNames.Level_ancientEgypt)
class AncientEgyptBuff extends BuffDefinition
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
        AddModifier(new BooleanModifier(LogicLevelProps.MUSIC_LOW_QUALITY, true));
        AddModifier(new BooleanModifier(LogicLevelProps.GRAPHICS_DOWNGRADE, true));
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
    public static var PROP_TIMER:VanillaBuffPropertyMeta<FrameTimer> = new VanillaBuffPropertyMeta<FrameTimer>("Timer");
    public static inline var MAX_TIMEOUT:Int = 900;
}
