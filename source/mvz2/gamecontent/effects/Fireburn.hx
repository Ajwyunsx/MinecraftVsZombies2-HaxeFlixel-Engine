// Ported from: Assets/Scripts/Vanilla/GameContent/Effects/Chapter4/Fireburn.cs
package mvz2.gamecontent.effects;
import mvz2.gamecontent.effects.VanillaEffectID.VanillaEffectNames;

@:autoEntityBehaviourDefinition(VanillaEffectNames.fireburn)
class Fireburn extends EffectBehaviour
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
    }
}
