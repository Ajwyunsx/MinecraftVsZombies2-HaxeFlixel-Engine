// Ported from: Assets/Scripts/Vanilla/GameContent/Effects/Chapter4/EmberParticles.cs
package mvz2.gamecontent.effects;
import mvz2.gamecontent.effects.VanillaEffectID.VanillaEffectNames;

@:autoEntityBehaviourDefinition(VanillaEffectNames.emberParticles)
class EmberParticles extends EffectBehaviour
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
    }
}
