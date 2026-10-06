// Ported from: Assets/Scripts/Vanilla/GameContent/Buffs/Contraption/Chapter1/TNTIgnitedBuff.cs
package mvz2.gamecontent.buffs.contraptions;

import mvz2.gamecontent.buffs.VanillaBuffNames;
import mvz2.vanilla.properties.VanillaBuffPropertyMeta;
import pvzengine.buffs.Buff;
import pvzengine.definitions.BuffDefinition;
import pvzengine.entities.EngineEntityProps;
import pvzengine.modifiers.BooleanModifier;
import pvzengine.modifiers.ColorModifier;
import unity.Color;
import unity.Mathf;

@:autoBuffDefinition(VanillaBuffNames.Contraption_tntIgnited)
class TNTIgnitedBuff extends BuffDefinition
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
        AddModifier(new BooleanModifier(EngineEntityProps.INVINCIBLE, true));
        AddModifier(new ColorModifier(EngineEntityProps.COLOR_OFFSET, PROP_COLOR));
    }
    public override function PostAdd(buff:Buff):Void
    {
        super.PostAdd(buff);
        buff.SetProperty(PROP_TIME, 0);
        UpdateMultipliers(buff);
    }
    public override function PostUpdate(buff:Buff):Void
    {
        super.PostUpdate(buff);
        UpdateMultipliers(buff);

        var time = buff.GetProperty(PROP_TIME);
        time++;
        buff.SetProperty(PROP_TIME, time);
    }
    function UpdateMultipliers(buff:Buff):Void
    {
        var time = buff.GetProperty(PROP_TIME);
        var alpha = (Mathf.Sin(time * 24 * Mathf.Deg2Rad) + 1) * 0.5;
        buff.SetProperty(PROP_COLOR, new Color(1, 1, 1, alpha));
    }
    public static var PROP_TIME:VanillaBuffPropertyMeta<Int> = new VanillaBuffPropertyMeta<Int>("Time");
    public static var PROP_COLOR:VanillaBuffPropertyMeta<Color> = new VanillaBuffPropertyMeta<Color>("Color");
}
