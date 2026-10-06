// Ported from: Assets/Scripts/Vanilla/GameContent/Buffs/Level/Chapter5/Boss/RedDragonClearedBuff.cs
package mvz2.gamecontent.buffs.level;

import mvz2.gamecontent.buffs.VanillaBuffNames;
import mvz2.vanilla.properties.VanillaBuffPropertyMeta;
import mvz2logic.level.LogicLevelProps;
import mvz2logic.level.LogicStageProps;
import pvzengine.buffs.Buff;
import pvzengine.definitions.BuffDefinition;
import pvzengine.modifiers.BooleanModifier;

@:autoBuffDefinition(VanillaBuffNames.Level_redDragonCleared)
class RedDragonClearedBuff extends BuffDefinition
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
        AddModifier(new BooleanModifier(LogicLevelProps.PAUSE_DISABLED, true));
        AddModifier(new BooleanModifier(LogicStageProps.AUTO_COLLECT_ALL, true));
    }
    public override function PostAdd(buff:Buff):Void
    {
        super.PostAdd(buff);
        buff.SetProperty(PROP_TIMEOUT, MAX_TIMEOUT);
    }
    public override function PostUpdate(buff:Buff):Void
    {
        super.PostUpdate(buff);
        var timeout = buff.GetProperty(PROP_TIMEOUT);
        timeout--;
        buff.SetProperty(PROP_TIMEOUT, timeout);

        var level = buff.Level;
        if (timeout <= 0)
        {
            level.Clear();
            buff.Remove();
        }
    }
    public static var PROP_TIMEOUT:VanillaBuffPropertyMeta<Int> = new VanillaBuffPropertyMeta<Int>("Timeout");
    public static inline var MAX_TIMEOUT:Int = 480;
}
