// Ported from: Assets/Scripts/Vanilla/GameContent/Effects/Chapter2/NightmareaperSplash.cs
package mvz2.gamecontent.effects;

import mvz2.vanilla.level.VanillaAreaProps;
import pvzengine.entities.Entity;
import mvz2.gamecontent.effects.VanillaEffectID.VanillaEffectNames;

@:autoEntityBehaviourDefinition(VanillaEffectNames.nightmareaperSplash)
class NightmareaperSplash extends EffectBehaviour
{
    // #region 公有方法
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
    }
    public override function Init(entity:Entity):Void
    {
        super.Init(entity);
        entity.SetTint(VanillaAreaProps.GetWaterColor(entity.Level));
    }
    // #endregion
}
