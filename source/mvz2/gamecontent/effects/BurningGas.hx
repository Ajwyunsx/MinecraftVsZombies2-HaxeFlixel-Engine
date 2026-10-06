// Ported from: Assets/Scripts/Vanilla/GameContent/Effects/Chapter1/BurningGas.cs
package mvz2.gamecontent.effects;

import mvz2.vanilla.entities.VanillaEntityExt;
import pvzengine.entities.Entity;
import mvz2.gamecontent.effects.VanillaEffectID.VanillaEffectNames;

@:autoEntityBehaviourDefinition(VanillaEffectNames.burningGas)
class BurningGas extends EffectBehaviour
{
    // #region 公有方法
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
    }
    public override function Update(entity:Entity):Void
    {
        super.Update(entity);
        entity.SetModelProperty("Size", entity.GetScaledSize());
        entity.SetModelProperty("Timeout", entity.Timeout);
    }
    // #endregion
}
