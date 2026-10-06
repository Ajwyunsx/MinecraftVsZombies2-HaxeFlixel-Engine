// Ported from: Assets/Scripts/Vanilla/GameContent/Buffs/Contraption/Chapter5/ElasticCloudBounceCooldownBuff.cs
package mvz2.gamecontent.buffs.contraptions;

import haxe.Int64;
import mvz2.gamecontent.buffs.VanillaBuffNames;
import mvz2.vanilla.properties.VanillaBuffPropertyMeta;
import pvzengine.buffs.Buff;
import pvzengine.definitions.BuffDefinition;

@:autoBuffDefinition(VanillaBuffNames.Contraption_elasticCloudBounceCooldown)
class ElasticCloudBounceCooldownBuff extends BuffDefinition
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
    }
    public override function PostUpdate(buff:Buff):Void
    {
        super.PostUpdate(buff);
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
    public static function GetTargetID(buff:Buff):Int64 return buff.GetProperty(PROP_TARGET_ID);
    public static function SetTargetID(buff:Buff, value:Int64):Void buff.SetProperty(PROP_TARGET_ID, value);
    public static var PROP_TIMEOUT:VanillaBuffPropertyMeta<Int> = new VanillaBuffPropertyMeta<Int>("timeout");
    public static var PROP_TARGET_ID:VanillaBuffPropertyMeta<Int64> = new VanillaBuffPropertyMeta<Int64>("target_id");
}
