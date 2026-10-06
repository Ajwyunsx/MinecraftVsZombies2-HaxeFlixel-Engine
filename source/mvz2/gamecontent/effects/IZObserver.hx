// Ported from: Assets/Scripts/Vanilla/GameContent/Effects/Chapter4/IZObserver.cs
package mvz2.gamecontent.effects;

import mvz2.gamecontent.pickups.VanillaPickupID;
import mvz2.vanilla.audios.VanillaSoundID;
import mvz2.vanilla.properties.VanillaEntityPropertyMeta;
import mvz2.vanilla.stats.VanillaStats;
import mvz2logic.Global;
import mvz2logic.entities.LogicEnemyProps;
import mvz2logic.entities.LogicEntityExt;
import pvzengine.entities.Entity;
import pvzengine.entities.EntityTypes;
import mvz2.gamecontent.effects.VanillaEffectID.VanillaEffectNames;
using mvz2.vanilla.pickups.VanillaPickupExt;
using mvz2logic.entities.LogicEntityExt;

@:autoEntityBehaviourDefinition(VanillaEffectNames.izObserver)
class IZObserver extends EffectBehaviour
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
    }
    public override function Update(entity:Entity):Void
    {
        super.Update(entity);
        if (!IsPass(entity))
        {
            var lane = entity.GetLane();
            var rightX = entity.GetBounds().max.x;
            if (entity.Level.EntityExists(function(e) return e.IsHostileEntity() && e.Type == EntityTypes.ENEMY && !e.IsNotActiveEnemy() && e.GetLane() == lane && e.Position.x < rightX))
            {
                SetPass(entity, true);
                Global.Saves.AddStat(VanillaStats.CATEGORY_IZ_OBSERVER_TRIGGER, entity.Level.StageID, 1);
                entity.Produce(VanillaPickupID.emerald);
                entity.PlaySound(VanillaSoundID.gulp);
            }
        }
        entity.SetAnimationBool("Pass", IsPass(entity));
    }
    public static function IsPass(entity:Entity):Bool return entity.GetBehaviourField(PROP_PASS);
    public static function SetPass(entity:Entity, value:Bool):Void entity.SetBehaviourField(PROP_PASS, value);
    private static var PROP_PASS:VanillaEntityPropertyMeta<Bool> = new VanillaEntityPropertyMeta<Bool>("Pass");
}
