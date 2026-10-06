// Ported from: Assets/Scripts/Vanilla/GameContent/Contraptions/Chapter6/NetherReactorCore_Evoke.cs
package mvz2.gamecontent.contraptions;

import mvz2.gamecontent.effects.Explosion;
import mvz2.gamecontent.enemies.VanillaEnemyID;
import mvz2.vanilla.entities.VanillaEntityBehaviourNames;
import mvz2.vanilla.audios.VanillaSoundID;
import mvz2.vanilla.entities.VanillaEntityExt;
import mvz2logic.entities.LogicEntityExt;
import mvz2logic.level.LogicLevelExt;
import pvzengine.NamespaceID;
import pvzengine.entities.Entity;
import unity.Vector2Int;
using mvz2.vanilla.entities.VanillaEntityExt;
using mvz2logic.entities.LogicEntityExt;

@:autoEntityBehaviourDefinition(VanillaEntityBehaviourNames.netherReactorCore_Evoke)
class NetherReactorCore_Evoke extends ContraptionEvokeBehaviour
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
    }
    public override function Evoke(entity:Entity):Void
    {
        super.Evoke(entity);
        var column = entity.GetColumn();
        var lane = entity.GetLane();
        var spawnParams = entity.GetSpawnParams();
        for (i in 0...gridOffsets.length)
        {
            var offset = gridOffsets[i];
            var enemyID = i < enemiesID.length ? enemiesID[i] : VanillaEnemyID.mesmerizer;
            var position = entity.Level.GetEntityGridPosition(column + offset.x, lane + offset.y);
            entity.Spawn(enemyID, position, spawnParams);
        }
        Explosion.Spawn(entity, entity.GetCenter(), 120);
        entity.PlaySound(VanillaSoundID.explosion);
        entity.PlaySound(VanillaSoundID.witherSpawn);
        entity.Level.ShakeScreen(10, 0, 15);
    }
    static var gridOffsets:Array<Vector2Int> = [
        // PORT-NOTE: unity shim 的 Vector2Int 没有 right/up/left/down 静态属性，改为等价的显式构造。
        new Vector2Int(1, 0),
        new Vector2Int(0, 1),
        new Vector2Int(-1, 0),
        new Vector2Int(0, -1)
    ];
    static var enemiesID:Array<NamespaceID> = [
        VanillaEnemyID.berserker,
        VanillaEnemyID.netherHunter,
        VanillaEnemyID.mesmerizer,
        VanillaEnemyID.netherMage,
    ];
}
