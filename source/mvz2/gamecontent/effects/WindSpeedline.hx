// Ported from: Assets/Scripts/Vanilla/GameContent/Effects/Chapter5/WindSpeedline.cs
package mvz2.gamecontent.effects;

import mvz2.vanilla.entities.VanillaEntityExt;
import pvzengine.entities.Entity;
import mvz2.gamecontent.effects.VanillaEffectID.VanillaEffectNames;

@:autoEntityBehaviourDefinition(VanillaEffectNames.windSpeedline)
class WindSpeedline extends EffectBehaviour
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
    }
    public override function Init(entity:Entity):Void
    {
        super.Init(entity);
        UpdateModelSize(entity);
    }
    public override function Update(entity:Entity):Void
    {
        super.Update(entity);
        UpdateModelSize(entity);
        if (!entity.Parent.ExistsAndAlive())
        {
            entity.Remove();
        }
        else
        {
            entity.SetFlipX(entity.Parent.IsFlipX());
        }
    }
    private function UpdateModelSize(entity:Entity):Void
    {
        var size = entity.GetScaledSize();
        size.y = 80;
        entity.SetModelProperty("Size", size);
    }
}
