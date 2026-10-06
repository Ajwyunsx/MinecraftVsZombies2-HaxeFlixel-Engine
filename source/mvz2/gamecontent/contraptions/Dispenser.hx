// Ported from: Assets/Scripts/Vanilla/GameContent/Contraptions/Prologue/Dispenser.cs
package mvz2.gamecontent.contraptions;

import mvz2.vanilla.entities.VanillaEntityExt;
import mvz2.vanilla.properties.VanillaEntityPropertyMeta;
import mvz2logic.entities.LogicEntityExt;
import pvzengine.NamespaceID;
import pvzengine.entities.Entity;
import tools.FrameTimer;
using mvz2logic.entities.LogicContraptionProps;

@:autoEntityBehaviourDefinition(VanillaContraptionNames.dispenser)
class Dispenser extends DispenserFamily
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
    }

    public override function Init(entity:Entity):Void
    {
        super.Init(entity);
        InitShootTimer(entity);
        var evocationTimer = new FrameTimer(120);
        SetEvocationTimer(entity, evocationTimer);
    }
    override function UpdateAI(entity:Entity):Void
    {
        super.UpdateAI(entity);
        if (!entity.IsEvoked())
        {
            ShootTick(entity);
            return;
        }

        EvokedUpdate(entity);
    }

    override function OnEvoke(entity:Entity):Void
    {
        super.OnEvoke(entity);
        var evocationTimer = GetEvocationTimer(entity);
        if (evocationTimer != null)
            evocationTimer.Reset();
        entity.SetEvoked(true);
    }
    public static function GetEvocationTimer(entity:Entity):Null<FrameTimer> return entity.GetBehaviourFieldNS(ID, PROP_EVOCATION_TIMER);
    public static function SetEvocationTimer(entity:Entity, timer:FrameTimer):Void entity.SetBehaviourFieldNS(ID, PROP_EVOCATION_TIMER, timer);
    function EvokedUpdate(entity:Entity):Void
    {
        var evocationTimer = GetEvocationTimer(entity);
        if (evocationTimer == null)
            return;
        evocationTimer.Run();
        if (evocationTimer.PassedInterval(2))
        {
            var projectile = Shoot(entity);
            if (projectile != null)
                projectile.Velocity *= 2;
        }
        if (evocationTimer.Expired)
        {
            entity.SetEvoked(false);
            var shootTimer = DispenserFamily.GetShootTimer(entity);
            if (shootTimer != null)
                shootTimer.Reset();
        }
    }
    static var ID:NamespaceID = VanillaContraptionID.dispenser;
    public static var PROP_EVOCATION_TIMER:VanillaEntityPropertyMeta<FrameTimer> = new VanillaEntityPropertyMeta<FrameTimer>("EvocationTimer");
}
