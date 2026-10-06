// Ported from: Assets/Scripts/Vanilla/GameContent/Effects/Chapter2/NightmarePortal.cs
package mvz2.gamecontent.effects;

import mvz2.vanilla.entities.VanillaEntityExt;
import mvz2.vanilla.properties.VanillaEntityPropertyMeta;
import pvzengine.NamespaceID;
import pvzengine.entities.Entity;
import mvz2.gamecontent.effects.VanillaEffectID.VanillaEffectNames;
using mvz2logic.entities.LogicEntityProps;
using mvz2.vanilla.entities.VanillaEntityExt;

@:autoEntityBehaviourDefinition(VanillaEffectNames.nightmarePortal)
class NightmarePortal extends EffectBehaviour
{
    // #region 公有方法
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
    }
    public override function Init(entity:Entity):Void
    {
        super.Init(entity);
        SetSpawnTime(entity, MAX_SPAWN_TIME);
        entity.SetSortingOrder(-10);
    }
    public override function Update(entity:Entity):Void
    {
        super.Update(entity);
        var spawnTime = GetSpawnTime(entity);
        if (spawnTime > 0)
        {
            spawnTime--;
            SetSpawnTime(entity, spawnTime);
            if (spawnTime == 0)
            {
                var enemyID = GetEnemyID(entity);
                if (NamespaceID.IsValid(enemyID))
                {
                    entity.SpawnWithParams(enemyID, entity.Position);
                }
            }
        }
    }
    public static function GetSpawnTime(entity:Entity):Int
    {
        return entity.GetBehaviourFieldNS(ID, PROP_SPAWN_TIME);
    }
    public static function SetSpawnTime(entity:Entity, value:Int):Void
    {
        entity.SetBehaviourFieldNS(ID, PROP_SPAWN_TIME, value);
    }
    public static function GetEnemyID(entity:Entity):Null<NamespaceID>
    {
        return entity.GetBehaviourFieldNS(ID, PROP_ENEMY_ID);
    }
    public static function SetEnemyID(entity:Entity, value:NamespaceID):Void
    {
        entity.SetBehaviourFieldNS(ID, PROP_ENEMY_ID, value);
    }
    // #endregion

    // #region 属性字段
    public static var ID:NamespaceID = VanillaEffectID.nightmarePortal;
    public static inline var MAX_SPAWN_TIME:Int = 15;
    public static var PROP_SPAWN_TIME:VanillaEntityPropertyMeta<Int> = new VanillaEntityPropertyMeta<Int>("SpawnTime");
    public static var PROP_ENEMY_ID:VanillaEntityPropertyMeta<NamespaceID> = new VanillaEntityPropertyMeta<NamespaceID>("EnemyID");
    // #endregion
}
