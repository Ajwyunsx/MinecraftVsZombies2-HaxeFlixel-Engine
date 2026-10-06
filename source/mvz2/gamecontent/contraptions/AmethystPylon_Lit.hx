// Ported from: Assets/Scripts/Vanilla/GameContent/Contraptions/Chapter6/AmethystPylon_Lit.cs
package mvz2.gamecontent.contraptions;

import mvz2.vanilla.entities.VanillaEntityBehaviourNames;
import mvz2.vanilla.entities.VanillaEntityExt;
import mvz2.vanilla.entities.VanillaEntityProps;
import mvz2.vanilla.properties.VanillaEntityPropertyMeta;
import mvz2logic.entities.LogicEntityExt;
import mvz2logic.level.LogicLevelExt;
import pvzengine.definitions.EntityBehaviourDefinition;
import pvzengine.entities.Entity;
import pvzengine.entities.EntityTypes;
import pvzengine.modifiers.FloatModifier;
import pvzengine.modifiers.NumberOperator;
import tools.FrameTimer;
import tools.TimerHelper;
import unity.Mathf;
using mvz2logic.entities.LogicEntityExt;

@:autoEntityBehaviourDefinition(VanillaEntityBehaviourNames.amethystPylon_Lit)
class AmethystPylon_Lit extends EntityBehaviourDefinition
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
        AddModifier(new FloatModifier(VanillaEntityProps.DAMAGE, NumberOperator.Multiply, PROP_DAMAGE_MULTIPLIER));
    }
    public override function Update(entity:Entity):Void
    {
        super.Update(entity);
        var timer = GetCheckTimer(entity);
        if (timer == null)
        {
            timer = TimerHelper.NewSecondTimer(CHECK_SECONDS);
            SetCheckTimer(entity, timer);
        }
        if (timer.RunToExpired())
        {
            lightSourceBuffer.clear();
            entity.Level.GetIlluminationLightSourcesNonAlloc(entity, lightSourceBuffer);
            var count = 0;
            if (entity.Level.IsDay())
            {
                count++;
            }
            for (source in lightSourceBuffer.keys())
            {
                var sourceEntity = entity.Level.FindEntityByID(source);
                if (sourceEntity.ExistsAndAlive() && (sourceEntity.IsVulnerableEntity() || sourceEntity.Type == EntityTypes.CART))
                {
                    count++;
                    if (count >= MAX_LIGHT_SOURCE_COUNT)
                    {
                        break;
                    }
                }
            }
            count = Mathf.ClampInt(count, 0, MAX_LIGHT_SOURCE_COUNT);
            SetDamageMultiplier(entity, Mathf.Max(count * 2, 1));
            entity.SetModelProperty("LightSourceCount", count);
            timer.Reset();
        }
    }
    public static function GetCheckTimer(entity:Entity):Null<FrameTimer> return entity.GetBehaviourField(PROP_CHECK_TIMER);
    public static function SetCheckTimer(entity:Entity, timer:Null<FrameTimer>):Void entity.SetBehaviourField(PROP_CHECK_TIMER, timer);
    public static function GetDamageMultiplier(entity:Entity):Float return entity.GetBehaviourField(PROP_DAMAGE_MULTIPLIER);
    public static function SetDamageMultiplier(entity:Entity, value:Float):Void entity.SetBehaviourField(PROP_DAMAGE_MULTIPLIER, value);

    public static inline var MAX_LIGHT_SOURCE_COUNT:Int = 3;
    public static inline var CHECK_SECONDS:Float = 7 / 30;
    public static var PROP_CHECK_TIMER:VanillaEntityPropertyMeta<FrameTimer> = new VanillaEntityPropertyMeta<FrameTimer>("check_timer");
    public static var PROP_DAMAGE_MULTIPLIER:VanillaEntityPropertyMeta<Float> = new VanillaEntityPropertyMeta<Float>("damage_multiplier");
    static var lightSourceBuffer:Map<haxe.Int64, Bool> = new Map();
}
