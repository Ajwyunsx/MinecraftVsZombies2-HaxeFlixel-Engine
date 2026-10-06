// Ported from: Assets/Scripts/Vanilla/GameContent/Spawns/UFOBlitzSpawnDefinition.cs
package mvz2.gamecontent.spawns;

import mvz2.gamecontent.enemies.VanillaSpawnNames;
import mvz2logic.spawns.LogicSpawnDefinition;
import mvz2logic.spawns.SpawnEndlessBehaviour;
import mvz2logic.spawns.SpawnPreviewBehaviour;

@:autoSpawnDefinition(VanillaSpawnNames.undeadFlyingObjectBlitz)
class UFOBlitzSpawnDefinition extends LogicSpawnDefinition
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
        var preview = new SpawnPreviewBehaviour();
        var inLevel = new UFOSpawnInLevelBehaviour(1, 20);
        var endless = new SpawnEndlessBehaviour();
        SetBehaviours(inLevel, preview, endless);
    }
}
