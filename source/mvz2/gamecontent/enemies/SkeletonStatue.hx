// Ported from: Assets/Scripts/Vanilla/GameContent/Enemies/Chapter6/SkeletonStatue.cs
package mvz2.gamecontent.enemies;

import mvz2.vanilla.audios.VanillaSoundID;
import mvz2.vanilla.entities.VanillaEntityExt;
import mvz2.vanilla.enemies.VanillaEnemyStates;
import mvz2.vanilla.properties.VanillaEntityPropertyMeta;
import mvz2logic.entities.LogicEnemyProps;
import pvzengine.EngineEntityProps;
import pvzengine.definitions.EntityBehaviourDefinition;
import pvzengine.entities.Entity;
import pvzengine.modifiers.BooleanModifier;
import pvzengine.modifiers.NumberOperator;
import pvzengine.modifiers.Vector3Modifier;
import tools.FrameTimer;
import tools.TimerHelper;
import unity.Vector3;
using mvz2.vanilla.entities.VanillaEntityProps;
using mvz2logic.entities.LogicEntityExt;

@:autoEntityBehaviourDefinition(VanillaEnemyNames.skeletonStatue)
class SkeletonStatue extends EntityBehaviourDefinition
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
        AddModifier(new BooleanModifier(LogicEnemyProps.HARMLESS, PROP_HARMLESS));
        AddModifier(new Vector3Modifier(EngineEntityProps.SIZE, NumberOperator.Multiply, PROP_SIZE_MULTIPLIER));
    }
    public override function Update(entity:Entity):Void
    {
        super.Update(entity);
        if (IsReviving(entity))
        {
            entity.SetProperty(PROP_SIZE_MULTIPLIER, new Vector3(1, 0.3, 1));
            entity.SetProperty(PROP_HARMLESS, true);
            // PORT-NOTE: C# 的 `&` 对 bool 是逻辑与（非短路）；Haxe 的 `&` 是按位与（Int），必须写成 `&&`。
            if (!entity.IsDead && !entity.IsAIFrozen())
            {
                var reviveTimer = GetReviveTimer(entity);
                if (reviveTimer == null)
                {
                    reviveTimer = TimerHelper.NewSecondTimer(REVIVE_SECONDS);
                    SetReviveTimer(entity, reviveTimer);
                }
                if (reviveTimer.RunToExpired(entity.GetAttackSpeed()))
                {
                    SetReviving(entity, false);
                    entity.PlaySound(VanillaSoundID.revived);
                    entity.Health = entity.GetMaxHealth();
                }
            }
        }
        else
        {
            entity.SetProperty(PROP_SIZE_MULTIPLIER, Vector3.one);
            entity.SetProperty(PROP_HARMLESS, false);
        }
    }
    public static inline var REVIVE_SECONDS:Float = 5;
    public static inline var REVIVE_SECONDS_PER_DEATH:Float = 2;
    public static function IsReviving(entity:Entity):Bool return entity.GetBehaviourField(PROP_REVIVING);
    public static function SetReviving(entity:Entity, value:Bool):Void entity.SetBehaviourField(PROP_REVIVING, value);
    public static function GetReviveTimer(entity:Entity):Null<FrameTimer> return entity.GetBehaviourField(PROP_REVIVE_TIMER);
    public static function SetReviveTimer(entity:Entity, value:Null<FrameTimer>):Void entity.SetBehaviourField(PROP_REVIVE_TIMER, value);
    public static inline var STATE_REVIVING:Int = VanillaEnemyStates.SKELETON_STATUE_REVIVING;
    public static var PROP_REVIVING:VanillaEntityPropertyMeta<Bool> = new VanillaEntityPropertyMeta<Bool>("reviving");
    public static var PROP_HARMLESS:VanillaEntityPropertyMeta<Bool> = new VanillaEntityPropertyMeta<Bool>("harmless");
    public static var PROP_REVIVE_TIMER:VanillaEntityPropertyMeta<FrameTimer> = new VanillaEntityPropertyMeta<FrameTimer>("revive_timer");
    public static var PROP_SIZE_MULTIPLIER:VanillaEntityPropertyMeta<Vector3> = new VanillaEntityPropertyMeta<Vector3>("size_multiplier");
}
