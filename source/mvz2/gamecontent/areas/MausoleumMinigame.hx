// Ported from: Assets/Scripts/Vanilla/GameContent/Areas/MausoleumMinigame.cs
package mvz2.gamecontent.areas;

import mvz2.gamecontent.areas.VanillaAreaID.VanillaAreaNames;
import pvzengine.definitions.AreaDefinition;
import pvzengine.level.LevelEngine;

@:autoAreaDefinition(VanillaAreaNames.mausoleumMinigame)
class MausoleumMinigame extends AreaDefinition
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
    }
}
