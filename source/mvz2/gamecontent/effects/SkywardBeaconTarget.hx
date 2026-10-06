// Ported from: Assets/Scripts/Vanilla/GameContent/Effects/Chapter5/SkywardBeaconTarget.cs
package mvz2.gamecontent.effects;

import mvz2.vanilla.entities.VanillaEntityExt;
import pvzengine.entities.Entity;
import mvz2.gamecontent.effects.VanillaEffectID.VanillaEffectNames;

@:autoEntityBehaviourDefinition(VanillaEffectNames.skywardBeaconTarget)
class SkywardBeaconTarget extends EffectBehaviour
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
    }
    public override function Init(entity:Entity):Void
    {
        super.Init(entity);
        UpdateModel(entity);
    }
    public override function Update(entity:Entity):Void
    {
        super.Update(entity);
        UpdateModel(entity);
    }
    private function UpdateModel(entity:Entity):Void
    {
        entity.SetModelProperty("ShowLine", true);
        var parent = entity.Parent;
        if (parent.ExistsAndAlive())
        {
            entity.SetModelProperty("Dest", parent.Position);
        }
    }
}
