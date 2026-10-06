// Ported from: Assets/Scripts/Vanilla/GameContent/Enemies/Chapter4/WickedHermitZombie.cs
package mvz2.gamecontent.enemies;

import mvz2.gamecontent.buffs.enemies.WickedHermitWarpBuff;
import mvz2.gamecontent.entities.AIEntityBehaviour;
import mvz2.vanilla.audios.VanillaSoundID;
import mvz2.vanilla.entities.VanillaEntityExt;
import mvz2.vanilla.properties.VanillaEntityPropertyMeta;
import mvz2logic.entities.LogicEntityExt;
import mvz2logic.level.LogicLevelExt;
import pvzengine.EntityID;
import pvzengine.buffs.BuffExt;
import pvzengine.entities.Entity;
using mvz2.vanilla.entities.VanillaEntityExt;
using mvz2logic.entities.LogicEnemyProps;
using mvz2logic.entities.LogicEntityExt;

@:autoEntityBehaviourDefinition(VanillaEnemyNames.wickedHermitZombie)
class WickedHermitZombie extends AIEntityBehaviour
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
    }
    public override function Init(entity:Entity):Void
    {
        super.Init(entity);

        if (!entity.IsPreviewEnemy() && !entity.Level.IsIZombie())
        {
            var talisman = entity.SpawnWithParams(VanillaEnemyID.talismanZombie, entity.Position);
            SetTalismanZombie(entity, new EntityID(talisman));
        }
    }
    override function UpdateAI(enemy:Entity):Void
    {
        super.UpdateAI(enemy);
        if (!IsWarpped(enemy) && !enemy.IsDead)
        {
            var talismanID = GetTalismanZombie(enemy);
            var talisman = talismanID != null ? talismanID.GetEntity(enemy.Level) : null;
            if (!talisman.ExistsAndAlive() || !talisman.IsFriendly(enemy))
            {
                SetTalismanZombie(enemy, null);
                enemy.AddBuff(WickedHermitWarpBuff);
                SetWarpped(enemy, true);
                enemy.PlaySound(VanillaSoundID.gapWarp);
            }
        }
    }
    public static function SetWarpped(entity:Entity, value:Bool):Void
    {
        entity.SetBehaviourField(PROP_WARPPED, value);
    }
    public static function IsWarpped(entity:Entity):Bool
    {
        return entity.GetBehaviourField(PROP_WARPPED);
    }
    public static function SetTalismanZombie(entity:Entity, value:Null<EntityID>):Void
    {
        entity.SetBehaviourField(PROP_TALISMAN_ZOMBIE, value);
    }
    public static function GetTalismanZombie(entity:Entity):Null<EntityID>
    {
        return entity.GetBehaviourField(PROP_TALISMAN_ZOMBIE);
    }
    public static inline var MOVE_INTERVAL:Int = 30;
    public static inline var TALISMAN_DISTANCE:Float = 80;
    public static var PROP_WARPPED:VanillaEntityPropertyMeta<Bool> = new VanillaEntityPropertyMeta<Bool>("warpped");
    public static var PROP_TALISMAN_ZOMBIE:VanillaEntityPropertyMeta<EntityID> = new VanillaEntityPropertyMeta<EntityID>("MoveTimer");
}
