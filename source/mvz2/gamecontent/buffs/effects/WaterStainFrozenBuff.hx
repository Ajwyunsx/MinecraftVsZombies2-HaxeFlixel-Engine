// Ported from: Assets/Scripts/Vanilla/GameContent/Buffs/Effects/Chapter5/WaterStainFrozenBuff.cs
package mvz2.gamecontent.buffs.effects;

import mvz2.gamecontent.buffs.VanillaBuffNames;
import mvz2.vanilla.properties.VanillaBuffPropertyMeta;
import pvzengine.buffs.Buff;
import pvzengine.definitions.BuffDefinition;
import pvzengine.entities.EngineEntityProps;
import pvzengine.modifiers.BlendOperator;
import pvzengine.modifiers.ColorModifier;
import tools.Ticks;
import unity.Color;
using mvz2.vanilla.entities.VanillaEntityProps;

@:autoBuffDefinition(VanillaBuffNames.Effect_waterStainFrozen)
class WaterStainFrozenBuff extends BuffDefinition
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
        AddModifier(new ColorModifier(EngineEntityProps.TINT, BlendOperator.One, BlendOperator.OneMinusSrcColor, new Color(0.75, 0.75, 0.75, 1)));
    }
    public override function PostUpdate(buff:Buff):Void
    {
        super.PostUpdate(buff);
        var entity = buff.GetEntity();
        if (entity != null)
        {
            entity.Timeout = entity.GetMaxTimeout();
        }

        var timeout = GetTimeout(buff);
        timeout--;
        SetTimeout(buff, timeout);
        if (timeout <= 0)
        {
            buff.Remove();
        }
    }
    public static function GetTimeout(buff:Buff):Int return buff.GetProperty(PROP_TIMEOUT);
    public static function SetTimeout(buff:Buff, value:Int):Void buff.SetProperty(PROP_TIMEOUT, value);
    public static function ResetTimeout(buff:Buff):Void
    {
        SetTimeout(buff, Ticks.FromSeconds(MAX_TIMEOUT_SECONDS));
    }
    public static inline var MAX_TIMEOUT_SECONDS:Float = 40;
    public static var PROP_TIMEOUT:VanillaBuffPropertyMeta<Int> = new VanillaBuffPropertyMeta<Int>("timeout");
}
