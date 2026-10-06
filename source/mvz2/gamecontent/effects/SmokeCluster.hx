// Ported from: Assets/Scripts/Vanilla/GameContent/Effects/Chapter1/SmokeCluster.cs
package mvz2.gamecontent.effects;
import mvz2.gamecontent.effects.VanillaEffectID.VanillaEffectNames;

@:autoEntityBehaviourDefinition(VanillaEffectNames.smokeCluster)
class SmokeCluster extends EffectBehaviour
{
    // #region 公有方法
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
    }
    // #endregion
}
