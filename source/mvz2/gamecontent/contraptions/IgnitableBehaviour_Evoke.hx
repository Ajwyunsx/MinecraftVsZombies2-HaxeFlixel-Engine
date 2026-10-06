// Ported from: Assets/Scripts/Vanilla/GameContent/Contraptions/Common/IgnitableBehaviour_Evoke.cs
package mvz2.gamecontent.contraptions;

import mvz2.vanilla.entities.VanillaEntityBehaviourNames;
import mvz2.vanilla.entities.VanillaEntityExt;
import mvz2logic.entities.LogicEntityExt;
import pvzengine.entities.Entity;
using mvz2logic.entities.LogicContraptionProps;

@:autoEntityBehaviourDefinition(VanillaEntityBehaviourNames.ignitable_Evoke)
class IgnitableBehaviour_Evoke extends ContraptionEvokeBehaviour
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
    }
    public override function Evoke(entity:Entity):Void
    {
        super.Evoke(entity);
        entity.SetEvoked(true);
        IgnitableBehaviour.Ignite(entity);
    }
}
