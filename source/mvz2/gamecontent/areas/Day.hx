// Ported from: Assets/Scripts/Vanilla/GameContent/Areas/Day.cs
package mvz2.gamecontent.areas;

import mvz2.gamecontent.areas.VanillaAreaID.VanillaAreaNames;
import mvz2.gamecontent.effects.VanillaEffectID;
import pvzengine.definitions.AreaDefinition;
import pvzengine.level.LevelEngine;
import unity.Vector3;

@:autoAreaDefinition(VanillaAreaNames.day)
class Day extends AreaDefinition
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
    }
    public override function Setup(level:LevelEngine):Void
    {
        level.Spawn(VanillaEffectID.miner, new Vector3(600, 0, 60), null);
    }
}
