// Ported from: Assets/Scripts/Vanilla/GameContent/Effects/Chapter1/GasBehaviour.cs
package mvz2.gamecontent.effects;

import mvz2.vanilla.audios.VanillaSoundID;
import mvz2.vanilla.entities.VanillaEntityBehaviourNames;
import mvz2.vanilla.entities.VanillaEntityExt;
import mvz2.vanilla.properties.VanillaEntityPropertyMeta;
import mvz2logic.level.LogicLevelExt;
import pvzengine.entities.Entity;
import tools.Ticks;
import unity.Mathf;

@:autoEntityBehaviourDefinition(VanillaEntityBehaviourNames.gas)
class GasBehaviour extends EffectBehaviour
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
    }
    public override function Init(entity:Entity):Void
    {
        super.Init(entity);
        entity.Level.AddLoopSoundEntity(VanillaSoundID.poisonGas, entity.ID);
    }
    public override function Update(entity:Entity):Void
    {
        super.Update(entity);
        entity.SetModelProperty("Size", entity.GetScaledSize());
        entity.SetModelProperty("Stopped", IsDisappearing(entity));
    }
    public static function IsDisappearing(entity:Entity):Bool
    {
        return entity.Timeout <= GetDisappearTimeoutTicks(entity);
    }
    public static function Disappear(entity:Entity):Void
    {
        entity.Timeout = Mathf.MinInt(entity.Timeout, GetDisappearTimeoutTicks(entity));
    }
    public static function GetDisappearTimeoutTicks(entity:Entity):Int
    {
        return Ticks.FromSeconds(GetDisappearTimeoutSeconds(entity));
    }
    public static function GetDisappearTimeoutSeconds(entity:Entity):Float
    {
        return entity.GetProperty(PROP_DISAPPEAR_TIMEOUT);
    }
    public static function SetDisappearTimeoutSeconds(entity:Entity, value:Float):Void
    {
        entity.SetProperty(PROP_DISAPPEAR_TIMEOUT, value);
    }

    private static var PROP_DISAPPEAR_TIMEOUT:VanillaEntityPropertyMeta<Float> = new VanillaEntityPropertyMeta<Float>("disappear_timeout", 1.0);
}
