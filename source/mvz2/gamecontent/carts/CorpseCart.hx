// Ported from: Assets/Scripts/Vanilla/GameContent/Carts/CorpseCart.cs
package mvz2.gamecontent.carts;

import mvz2.gamecontent.carts.VanillaCartID.VanillaCartNames;
import mvz2.gamecontent.enemies.VanillaEnemyID;
import mvz2.vanilla.carts.VanillaCartExt;
import mvz2.vanilla.entities.VanillaEntityExt;
import mvz2.vanilla.properties.VanillaEntityPropertyMeta;
import pvzengine.entities.Entity;
import tools.FrameTimer;
import tools.TimerHelper;

@:autoEntityBehaviourDefinition(VanillaCartNames.corpseCart)
class CorpseCart extends CartBehaviour
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
    }
    public override function Update(entity:Entity):Void
    {
        super.Update(entity);
        if (!VanillaCartExt.IsCartTriggered(entity))
            return;
        var timer = entity.GetProperty(PROP_RELEASE_ZOMBIE_TIMER);
        if (timer == null)
        {
            timer = TimerHelper.NewSecondTimer(RELEASE_INTERVAL_SECONDS);
            entity.SetProperty(PROP_RELEASE_ZOMBIE_TIMER, timer);
        }
        if (timer.RunToExpired())
        {
            VanillaEntityExt.SpawnWithParams(entity, VanillaEnemyID.zombie, entity.Position);
            timer.Reset();
        }
    }
    public static inline var RELEASE_INTERVAL_SECONDS:Float = 0.5;
    public static var PROP_RELEASE_ZOMBIE_TIMER:VanillaEntityPropertyMeta<FrameTimer> = new VanillaEntityPropertyMeta<FrameTimer>("release_zombie_timer");
}
