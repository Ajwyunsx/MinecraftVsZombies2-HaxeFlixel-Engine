// Ported from: Assets/Scripts/Vanilla/GameContent/Contraptions/Common/IgnitableBehaviour_Trigger.cs
package mvz2.gamecontent.contraptions;

import mvz2.vanilla.entities.VanillaEntityBehaviourNames;
import mvz2.vanilla.entities.VanillaEntityExt;
import pvzengine.entities.Entity;

@:autoEntityBehaviourDefinition(VanillaEntityBehaviourNames.ignitable_Trigger)
class IgnitableBehaviour_Trigger extends ContraptionTriggerBehaviour
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
    }
    public override function CanTrigger(entity:Entity):Bool
    {
        return super.CanTrigger(entity) && !IgnitableBehaviour.IsIgnited(entity);
    }
    public override function Trigger(entity:Entity):Void
    {
        super.Trigger(entity);
        IgnitableBehaviour.Ignite(entity);
    }
}
