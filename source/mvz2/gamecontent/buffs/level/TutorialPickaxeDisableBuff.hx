// Ported from: Assets/Scripts/Vanilla/GameContent/Buffs/Level/Chapter1/TutorialPickaxeDisableBuff.cs
package mvz2.gamecontent.buffs.level;

import mvz2.gamecontent.buffs.VanillaBuffNames;
import mvz2.gamecontent.seeds.VanillaBlueprintErrors;
import mvz2logic.level.LogicLevelProps;
import pvzengine.definitions.BuffDefinition;
import pvzengine.modifiers.NamespaceIDModifier;
import pvzengine.modifiers.SetOperator;

@:autoBuffDefinition(VanillaBuffNames.Level_tutorialPickaxeDisable)
class TutorialPickaxeDisableBuff extends BuffDefinition
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
        AddModifier(new NamespaceIDModifier(LogicLevelProps.PICKAXE_DISABLE_ID, SetOperator.Set, VanillaBlueprintErrors.tutorial));
    }
}
