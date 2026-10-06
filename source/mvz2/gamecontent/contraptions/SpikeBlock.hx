// Ported from: Assets/Scripts/Vanilla/GameContent/Contraptions/Chapter3/SpikeBlock.cs
package mvz2.gamecontent.contraptions;

@:autoEntityBehaviourDefinition(VanillaContraptionNames.spikeBlock)
class SpikeBlock extends SpikesBehaviour
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
    }
    override function get_AttackCooldown():Int return ATTACK_COOLDOWN;
    public static inline var ATTACK_COOLDOWN:Int = 30;
}
