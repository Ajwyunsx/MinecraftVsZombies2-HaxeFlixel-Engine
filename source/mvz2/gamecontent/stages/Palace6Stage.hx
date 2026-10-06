// Ported from: Assets/Scripts/Vanilla/GameContent/Stages/Definitions/Palace/Palace6Stage.cs
package mvz2.gamecontent.stages;

import mvz2.gamecontent.seeds.VanillaBlueprintID;
import pvzengine.NamespaceID;

@:autoStageDefinition(VanillaStageNames.palace6)
class Palace6Stage extends HeavyWeaponStageBase
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
    }
    override public function GetBlueprintsID():Array<NamespaceID>
    {
        return [
            VanillaBlueprintID.heavyWeaponNuke,
            VanillaBlueprintID.heavyWeaponRapid,
            VanillaBlueprintID.heavyWeaponSpread,
        ];
    }
}
