// Ported from: Assets/Scripts/Vanilla/GameContent/Pickups/Gems/Diamond.cs
package mvz2.gamecontent.pickups;

import mvz2.vanilla.audios.VanillaSoundID;
import mvz2logic.level.LogicLevelExt;
import pvzengine.definitions.EntityBehaviourDefinition;
import pvzengine.entities.Entity;

@:autoEntityBehaviourDefinition(VanillaPickupNames.diamond)
class Diamond extends EntityBehaviourDefinition
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
    }
    public override function Init(entity:Entity):Void
    {
        super.Init(entity);
        entity.Level.PlaySound(VanillaSoundID.chime);
    }
}
