// Ported from: Assets/Scripts/Vanilla/GameContent/Contraptions/Chapter2/DreamCrystal.cs
package mvz2.gamecontent.contraptions;

import mvz2.gamecontent.buffs.contraptions.DreamCrystalEvocationBuff;
import mvz2.vanilla.audios.VanillaSoundID;
import mvz2.vanilla.entities.VanillaEntityExt;
import mvz2logic.entities.LogicEntityExt;
import pvzengine.buffs.BuffExt;
import pvzengine.entities.Entity;
using mvz2.vanilla.entities.VanillaEntityExt;
using mvz2logic.entities.LogicContraptionProps;
using mvz2logic.entities.LogicEntityExt;

@:autoEntityBehaviourDefinition(VanillaContraptionNames.dreamCrystal)
class DreamCrystal extends ContraptionBehaviour
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
    }
    override function UpdateAI(contraption:Entity):Void
    {
        super.UpdateAI(contraption);
        contraption.HealEffects(HEAL_PER_FRAME, contraption);
    }
    override function UpdateLogic(contraption:Entity):Void
    {
        super.UpdateLogic(contraption);
        var evoked = contraption.HasBuff(DreamCrystalEvocationBuff);
        contraption.SetEvoked(evoked);
        contraption.SetAnimationBool("Evoked", evoked);
    }

    override function OnEvoke(contraption:Entity):Void
    {
        super.OnEvoke(contraption);
        contraption.SetEvoked(true);
        contraption.Health = contraption.GetMaxHealth();
        contraption.AddBuff(DreamCrystalEvocationBuff);
        contraption.PlaySound(VanillaSoundID.sparkle);
    }
    public static inline var HEAL_PER_FRAME:Float = 2;
}
