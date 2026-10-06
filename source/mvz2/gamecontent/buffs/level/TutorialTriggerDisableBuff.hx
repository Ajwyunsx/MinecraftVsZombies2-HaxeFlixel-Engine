// Ported from: Assets/Scripts/Vanilla/GameContent/Buffs/Level/Chapter1/TutorialTriggerDisableBuff.cs
package mvz2.gamecontent.buffs.level;

import mvz2.gamecontent.buffs.VanillaBuffNames;
import mvz2.gamecontent.seeds.VanillaBlueprintErrors;
import mvz2logic.level.LogicLevelProps;
import pvzengine.definitions.BuffDefinition;
import pvzengine.modifiers.NamespaceIDModifier;
import pvzengine.modifiers.SetOperator;

@:autoBuffDefinition(VanillaBuffNames.Level_tutorialTriggerDisable)
class TutorialTriggerDisableBuff extends BuffDefinition
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
        AddModifier(new NamespaceIDModifier(LogicLevelProps.TRIGGER_DISABLE_ID, SetOperator.Set, VanillaBlueprintErrors.tutorial));
    }
}
