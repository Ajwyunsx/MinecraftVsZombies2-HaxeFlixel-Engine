// Ported from: Assets/Scripts/Vanilla/GameContent/Contraptions/Chapter1/MoonlightSensor.cs
package mvz2.gamecontent.contraptions;

import mvz2.gamecontent.buffs.contraptions.MoonlightSensorEvokedBuff;
import mvz2.gamecontent.buffs.contraptions.MoonlightSensorLaunchingBuff;
import mvz2.vanilla.audios.VanillaSoundID;
import mvz2.vanilla.entities.VanillaEntityExt;
import mvz2.vanilla.properties.VanillaEntityPropertyMeta;
import mvz2logic.entities.LogicEntityExt;
import mvz2logic.level.LogicLevelExt;
import pvzengine.NamespaceID;
import pvzengine.buffs.BuffExt;
import pvzengine.entities.Entity;
import tools.FrameTimer;
import unity.Color;
using mvz2.vanilla.entities.VanillaEntityExt;
using mvz2.vanilla.entities.VanillaEntityProps;
using mvz2logic.entities.LogicEntityExt;

@:autoEntityBehaviourDefinition(VanillaContraptionNames.moonlightSensor)
class MoonlightSensor extends ContraptionBehaviour
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
    }
    public override function Init(entity:Entity):Void
    {
        super.Init(entity);
        entity.AddBuff(MoonlightSensorLaunchingBuff);
        var productionTimer = new FrameTimer(PRODUCTION_INTERVAL);
        SetProductionTimer(entity, productionTimer);
        var upgradeTimer = new FrameTimer(UPGRADE_TIME);
        SetUpgradeTimer(entity, upgradeTimer);
    }
    override function UpdateAI(entity:Entity):Void
    {
        super.UpdateAI(entity);
        ProductionUpdate(entity);
        UpgradeUpdate(entity);
    }
    override function UpdateLogic(entity:Entity):Void
    {
        super.UpdateLogic(entity);
        entity.UpdateShineRing();
        entity.SetAnimationBool("Upgraded", GetUpgraded(entity));
    }

    public override function CanEvoke(entity:Entity):Bool
    {
        return super.CanEvoke(entity) && !entity.HasBuff(MoonlightSensorEvokedBuff);
    }

    override function OnEvoke(entity:Entity):Void
    {
        super.OnEvoke(entity);
        entity.AddBuff(MoonlightSensorEvokedBuff);
        Upgrade(entity);
        entity.PlaySound(VanillaSoundID.sparkle);
        entity.SetAnimationBool("Sparks", true);
    }
    public static function Upgrade(entity:Entity):Void
    {
        var timer = GetUpgradeTimer(entity);
        if (timer != null)
            timer.Reset();
        SetUpgraded(entity, true);
        entity.RemoveBuffs(MoonlightSensorLaunchingBuff);
        entity.PlaySound(VanillaSoundID.screw);
    }
    public static function GetProductionTimer(entity:Entity):Null<FrameTimer>
    {
        return entity.GetBehaviourFieldNS(ID, PROP_PRODUCTION_TIMER);
    }
    public static function SetProductionTimer(entity:Entity, timer:FrameTimer):Void
    {
        entity.SetBehaviourFieldNS(ID, PROP_PRODUCTION_TIMER, timer);
    }
    public static function GetUpgradeTimer(entity:Entity):Null<FrameTimer>
    {
        return entity.GetBehaviourFieldNS(ID, PROP_UPGRADE_TIMER);
    }
    public static function SetUpgradeTimer(entity:Entity, timer:FrameTimer):Void
    {
        entity.SetBehaviourFieldNS(ID, PROP_UPGRADE_TIMER, timer);
    }
    public static function GetOrCreateUpgradeTimer(entity:Entity):Null<FrameTimer>
    {
        var timer = GetUpgradeTimer(entity);
        if (timer == null)
        {
            timer = new FrameTimer(UPGRADE_TIME);
            SetUpgradeTimer(entity, timer);
        }
        return timer;
    }
    public static function GetUpgraded(entity:Entity):Bool
    {
        return entity.GetBehaviourFieldNS(ID, PROP_UPGRADED);
    }
    public static function SetUpgraded(entity:Entity, value:Bool):Void
    {
        entity.SetBehaviourFieldNS(ID, PROP_UPGRADED, value);
    }
    function ProductionUpdate(entity:Entity):Void
    {
        var productionTimer = GetProductionTimer(entity);
        if (productionTimer == null)
            return;
        productionTimer.Run(entity.GetProduceSpeed());
        if (entity.Level.IsNoEnergy())
        {
            productionTimer.Frame = productionTimer.MaxFrame;
        }
        if (productionTimer.Expired)
        {
            var energyDirection = entity.IsFriendlyEntity() ? 1 : -1;
            entity.Level.AddEnergy(1 * energyDirection);
            productionTimer.Reset();
        }
    }
    function UpgradeUpdate(entity:Entity):Void
    {
        if (GetUpgraded(entity))
            return;
        var upgradeTimer = GetOrCreateUpgradeTimer(entity);
        if (upgradeTimer.RunToExpiredAndNotNull())
        {
            Upgrade(entity);
        }
    }
    public static inline var PRODUCTION_INTERVAL:Int = 30;
    public static inline var UPGRADE_TIME:Int = 3600;
    static var productionColor:Color = new Color(0.5, 0.5, 0.5, 0);
    static var ID:NamespaceID = VanillaContraptionID.moonlightSensor;
    public static var PROP_UPGRADED:VanillaEntityPropertyMeta<Bool> = new VanillaEntityPropertyMeta<Bool>("Upgraded");
    public static var PROP_UPGRADE_TIMER:VanillaEntityPropertyMeta<FrameTimer> = new VanillaEntityPropertyMeta<FrameTimer>("UpgradeTimer");
    public static var PROP_PRODUCTION_TIMER:VanillaEntityPropertyMeta<FrameTimer> = new VanillaEntityPropertyMeta<FrameTimer>("ProductionTimer");
}
