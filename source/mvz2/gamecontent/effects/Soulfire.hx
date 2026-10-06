// Ported from: Assets/Scripts/Vanilla/GameContent/Effects/Chapter1/Soulfire.cs
package mvz2.gamecontent.effects;
import mvz2.gamecontent.effects.VanillaEffectID.VanillaEffectNames;

@:autoEntityBehaviourDefinition(VanillaEffectNames.soulfire)
class Soulfire extends EffectBehaviour
{
    // #region 公有方法
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
    }
    // #endregion
}
