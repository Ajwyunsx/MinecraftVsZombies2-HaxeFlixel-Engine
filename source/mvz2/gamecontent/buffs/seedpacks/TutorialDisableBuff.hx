// Ported from: Assets/Scripts/Vanilla/GameContent/Buffs/SeedPacks/Stages/TutorialDisableBuff.cs
package mvz2.gamecontent.buffs.seedpacks;

import mvz2.gamecontent.buffs.VanillaBuffNames;
import mvz2.gamecontent.seeds.VanillaBlueprintErrors;
import pvzengine.definitions.BuffDefinition;
import pvzengine.level.EngineSeedProps;
import pvzengine.modifiers.NamespaceIDModifier;
import pvzengine.modifiers.SetOperator;

@:autoBuffDefinition(VanillaBuffNames.SeedPack_tutorialBlueprintDisable)
class TutorialDisableBuff extends BuffDefinition
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
        AddModifier(new NamespaceIDModifier(EngineSeedProps.DISABLE_ID, SetOperator.Set, VanillaBlueprintErrors.tutorial));
    }
}
