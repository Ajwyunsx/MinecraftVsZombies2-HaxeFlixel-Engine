// Ported from: Assets/Scripts/Vanilla/GameContent/Effects/Chapter2/MagneticLine.cs
package mvz2.gamecontent.effects;

import mvz2.vanilla.entities.VanillaEntityExt;
import pvzengine.entities.Entity;
import mvz2.gamecontent.effects.VanillaEffectID.VanillaEffectNames;

@:autoEntityBehaviourDefinition(VanillaEffectNames.magneticLine)
class MagneticLine extends EffectBehaviour
{
    // #region 公有方法
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
    }
    public override function Init(entity:Entity):Void
    {
        super.Init(entity);
        entity.SetModelProperty("Source", entity.Position);
        entity.SetModelProperty("Dest", entity.Position);
    }
    public override function Update(entity:Entity):Void
    {
        super.Update(entity);
        if (!entity.Parent.ExistsAndAlive() || !entity.Target.ExistsAndAlive())
        {
            entity.Remove();
            return;
        }
        entity.Position = entity.Parent.Position;
        entity.SetModelProperty("Source", entity.Position);
        entity.SetModelProperty("Dest", entity.Target.GetCenter());
    }
    // #endregion
}
