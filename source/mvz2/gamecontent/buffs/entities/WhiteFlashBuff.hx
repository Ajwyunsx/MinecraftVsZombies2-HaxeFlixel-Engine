// Ported from: Assets/Scripts/Vanilla/GameContent/Buffs/Entity/Chapter2/WhiteFlashBuff.cs
package mvz2.gamecontent.buffs.entities;

import mvz2.gamecontent.buffs.VanillaBuffNames;
import mvz2.vanilla.properties.VanillaBuffPropertyMeta;
import pvzengine.buffs.Buff;
import pvzengine.definitions.BuffDefinition;
import pvzengine.entities.EngineEntityProps;
import pvzengine.entities.Entity;
import pvzengine.modifiers.ColorModifier;
import unity.Color;

@:autoBuffDefinition(VanillaBuffNames.Entity_whiteFlash)
class WhiteFlashBuff extends BuffDefinition
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
        AddModifier(new ColorModifier(EngineEntityProps.COLOR_OFFSET, PROP_COLOR));
        AddModifier(new ColorModifier(EngineEntityProps.HELMET_COLOR_OFFSET, PROP_COLOR));
    }
    public override function PostUpdate(buff:Buff):Void
    {
        super.PostUpdate(buff);
        var timeout = buff.GetProperty(PROP_TIMEOUT);
        timeout--;
        buff.SetProperty(PROP_TIMEOUT, timeout);

        var alpha:Float = 0;
        var maxTimeout = buff.GetProperty(PROP_MAX_TIMEOUT);
        if (maxTimeout > 0)
        {
            alpha = timeout / maxTimeout;
        }
        buff.SetProperty(PROP_COLOR, new Color(1, 1, 1, alpha));

        if (timeout <= 0)
        {
            buff.Remove();
        }
    }
    public static function AddToEntity(entity:Entity, timeout:Int):Buff
    {
        var buff = entity.NewBuff(WhiteFlashBuff);
        buff.SetProperty(PROP_TIMEOUT, timeout);
        buff.SetProperty(PROP_MAX_TIMEOUT, timeout);
        entity.AddBuff(buff);
        return buff;
    }
    public static var PROP_COLOR:VanillaBuffPropertyMeta<Color> = new VanillaBuffPropertyMeta<Color>("Color");
    public static var PROP_TIMEOUT:VanillaBuffPropertyMeta<Int> = new VanillaBuffPropertyMeta<Int>("Timeout");
    public static var PROP_MAX_TIMEOUT:VanillaBuffPropertyMeta<Int> = new VanillaBuffPropertyMeta<Int>("MaxTimeout");
}
