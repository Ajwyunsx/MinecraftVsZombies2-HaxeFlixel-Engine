// Ported from: Assets/Scripts/Vanilla/GameContent/Stages/Definitions/Minigames/HeavyWeaponStage.cs
package mvz2.gamecontent.stages;

import mvz2.gamecontent.seeds.VanillaBlueprintID;
import pvzengine.NamespaceID;

@:autoStageDefinition(VanillaStageNames.heavyWeapon)
class HeavyWeaponStage extends HeavyWeaponStageBase
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
    }
    override public function GetBlueprintsID():Array<NamespaceID>
    {
        return [
            VanillaBlueprintID.heavyWeaponFlashbang,
            VanillaBlueprintID.heavyWeaponRapid,
            VanillaBlueprintID.heavyWeaponSpread,
        ];
    }
}
