// Ported from: Assets/Scripts/Vanilla/GameContent/Contraptions/Chapter6/AmethystPylon_Evoke.cs
package mvz2.gamecontent.contraptions;

import mvz2.gamecontent.effects.VanillaEffectID;
import mvz2.vanilla.entities.VanillaEntityBehaviourNames;
import mvz2.vanilla.entities.VanillaEntityExt;
import pvzengine.EngineEntityProps;
import pvzengine.EntityID;
import pvzengine.entities.Entity;
using mvz2.vanilla.entities.VanillaEntityExt;
using mvz2logic.entities.LogicContraptionProps;

@:autoEntityBehaviourDefinition(VanillaEntityBehaviourNames.amethystPylon_Evoke)
class AmethystPylon_Evoke extends ContraptionEvokeBehaviour
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
    }
    public override function Evoke(entity:Entity):Void
    {
        super.Evoke(entity);
        var sourcePosition = AmethystPylon.GetLaserPosition(entity);
        var param = entity.GetSpawnParams();
        param.SetProperty(EngineEntityProps.FLIP_X, entity.IsFacingLeft());

        // C#: entity.Spawn(...)?.Let(l => { ... })
        var l = entity.Spawn(VanillaEffectID.masterSpark, sourcePosition, param);
        if (l != null)
        {
            AmethystPylon.SetMasterSparkID(entity, new EntityID(l));
            l.SetParent(entity);
            entity.SetEvoked(true);
        }
    }
}
