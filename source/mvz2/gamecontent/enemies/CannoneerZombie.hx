// Ported from: Assets/Scripts/Vanilla/GameContent/Enemies/Chapter5/CannoneerZombie.cs
package mvz2.gamecontent.enemies;

import mvz2.gamecontent.contraptions.TNT;
import mvz2.gamecontent.contraptions.VanillaContraptionID;
import mvz2.gamecontent.entities.AIEntityBehaviour;
import mvz2.vanilla.unlocks.VanillaUnlockID;
import mvz2logic.Global;
import mvz2logic.entities.LogicEntityExt;
import pvzengine.damages.DeathInfo;
import pvzengine.entities.Entity;
import pvzengine.entities.EntitySourceReference;

@:autoEntityBehaviourDefinition(VanillaEnemyNames.cannoneerZombie)
class CannoneerZombie extends AIEntityBehaviour
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
    }
    public override function PostDeath(entity:Entity, info:DeathInfo):Void
    {
        super.PostDeath(entity, info);
        if (Std.isOfType(info.Source, EntitySourceReference))
        {
            var entitySource:EntitySourceReference = cast info.Source;
            var sourceEnt = entitySource.GetEntity(entity.Level);
            if (sourceEnt != null && sourceEnt.IsEntityOf(VanillaContraptionID.tnt) && TNT.IsCharged(sourceEnt))
            {
                Global.Saves.Unlock(VanillaUnlockID.railgun);
            }
        }
    }
}
