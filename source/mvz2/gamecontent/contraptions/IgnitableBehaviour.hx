// Ported from: Assets/Scripts/Vanilla/GameContent/Contraptions/Common/IgnitableBehaviour.cs
package mvz2.gamecontent.contraptions;

import mvz2.gamecontent.buffs.contraptions.TNTIgnitedBuff;
import mvz2.gamecontent.entities.AIEntityBehaviour;
import mvz2.vanilla.entities.VanillaEntityBehaviourNames;
import mvz2.vanilla.audios.VanillaSoundID;
import mvz2.vanilla.entities.VanillaEntityExt;
import mvz2.vanilla.properties.VanillaEntityPropertyMeta;
import mvz2logic.entities.LogicEntityExt;
import mvz2logic.level.LogicLevelExt;
import pvzengine.buffs.BuffExt;
import pvzengine.entities.Entity;
import tools.FrameTimer;
import unity.Mathf;
import unity.Vector3;
using mvz2.vanilla.entities.VanillaEntityExt;
using mvz2.vanilla.entities.VanillaEntityProps;
using mvz2logic.entities.LogicEntityExt;

@:autoEntityBehaviourDefinition(VanillaEntityBehaviourNames.ignitable)
class IgnitableBehaviour extends AIEntityBehaviour
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
    }
    public override function Init(entity:Entity):Void
    {
        super.Init(entity);
        SetExplosionTimer(entity, new FrameTimer(30));
    }
    override function UpdateAI(entity:Entity):Void
    {
        super.UpdateAI(entity);
        if (IsIgnited(entity))
        {
            IgnitedUpdate(entity);
        }
    }
    function IgnitedUpdate(entity:Entity):Void
    {
        var timer = GetExplosionTimer(entity);
        if (timer == null)
            return;
        timer.Run(entity.GetAttackSpeed());

        if (timer.Frame < 5)
        {
            entity.SetDisplayScale(Vector3.one * Mathf.Lerp(2, 1, timer.Frame / 5));
        }
        if (timer.Expired)
        {
            var range = entity.GetRange();
            var damage = entity.GetDamage();
            entity.BehaviourExplode(range, damage);
            entity.Remove();
        }
    }
    public static function Ignite(entity:Entity):Void
    {
        SetIgnited(entity, true);
        entity.PlaySound(VanillaSoundID.fuse);
        entity.AddBuff(TNTIgnitedBuff);
    }
    public static function IsIgnited(entity:Entity):Bool return entity.GetProperty(PROP_IGNITED);
    public static function SetIgnited(entity:Entity, value:Bool):Void entity.SetProperty(PROP_IGNITED, value);
    public static function GetExplosionTimer(entity:Entity):Null<FrameTimer> return entity.GetProperty(PROP_EXPLOSION_TIMER);
    public static function SetExplosionTimer(entity:Entity, timer:FrameTimer):Void entity.SetProperty(PROP_EXPLOSION_TIMER, timer);
    public static var PROP_IGNITED:VanillaEntityPropertyMeta<Bool> = new VanillaEntityPropertyMeta<Bool>("ignited");
    public static var PROP_EXPLOSION_TIMER:VanillaEntityPropertyMeta<FrameTimer> = new VanillaEntityPropertyMeta<FrameTimer>("explosion_timer");
}
