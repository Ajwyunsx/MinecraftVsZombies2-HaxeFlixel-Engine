// Ported from: Assets/Scripts/Vanilla/GameContent/Buffs/Level/Chapter2/NightmareDecrepifyBuff.cs
package mvz2.gamecontent.buffs.level;

import mvz2.gamecontent.buffs.VanillaBuffNames;
import mvz2.gamecontent.seeds.VanillaBlueprintErrors;
import mvz2.vanilla.properties.VanillaBuffPropertyMeta;
import mvz2logic.level.LogicLevelProps;
import pvzengine.buffs.Buff;
import pvzengine.definitions.BuffDefinition;
import pvzengine.modifiers.BooleanModifier;
import pvzengine.modifiers.NamespaceIDModifier;
import pvzengine.modifiers.SetOperator;

@:autoBuffDefinition(VanillaBuffNames.Level_nightmareDecrepify)
class NightmareDecrepifyBuff extends BuffDefinition
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
        AddModifier(new NamespaceIDModifier(LogicLevelProps.PICKAXE_DISABLE_ID, SetOperator.Set, VanillaBlueprintErrors.decrepify));
        AddModifier(new BooleanModifier(LogicLevelProps.PICKAXE_DISABLE_ICON, true));

        AddModifier(new NamespaceIDModifier(LogicLevelProps.STARSHARD_DISABLE_ID, SetOperator.Set, VanillaBlueprintErrors.decrepify));
        AddModifier(new BooleanModifier(LogicLevelProps.STARSHARD_DISABLE_ICON, true));
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
        if (timeout <= 0)
        {
            buff.Remove();
        }
    }
    public static var PROP_TIMEOUT:VanillaBuffPropertyMeta<Int> = new VanillaBuffPropertyMeta<Int>("Timeout");
    public static inline var MAX_TIMEOUT:Int = 1800;
}
