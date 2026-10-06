// Ported from: Assets/Scripts/Vanilla/GameContent/Effects/Chapter4/ThunderBoltHorizontal.cs
package mvz2.gamecontent.effects;

import mvz2.vanilla.audios.VanillaSoundID;
import pvzengine.entities.Entity;
import mvz2.gamecontent.effects.VanillaEffectID.VanillaEffectNames;

@:autoEntityBehaviourDefinition(VanillaEffectNames.thunderBoltHorizontal)
class ThunderBoltHorizontal extends EffectBehaviour
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
    }
    public override function Init(entity:Entity):Void
    {
        super.Init(entity);
        entity.Level.PlaySound(VanillaSoundID.thunder);
    }
}
