// Ported from: Assets/Scripts/Vanilla/GameContent/Enemies/Chapter2/MotherTerror.cs
package mvz2.gamecontent.enemies;

import mvz2.gamecontent.buffs.enemies.MotherTerrorLaidBuff;
import mvz2.gamecontent.buffs.enemies.TerrorParasitizedBuff;
import mvz2.gamecontent.entities.AIEntityBehaviour;
import mvz2.gamecontent.shells.VanillaShellID;
import mvz2.vanilla.audios.VanillaSoundID;
import mvz2.vanilla.detection.Detection;
import mvz2.vanilla.entities.VanillaEntityExt;
import mvz2logic.entities.IDeathEffectsBehaviour;
import mvz2logic.entities.LogicEntityExt;
import mvz2logic.level.LogicLevelExt;
import pvzengine.NamespaceID;
import pvzengine.buffs.BuffExt;
import pvzengine.damages.DeathInfo;
import pvzengine.entities.Entity;
import pvzengine.entities.EntityCollision;
import pvzengine.entities.EntityCollisionHelper;
using mvz2.gamecontent.difficulties.VanillaDifficultyLevelProps;
using mvz2.vanilla.entities.VanillaColliderExt;
using mvz2.vanilla.entities.VanillaEntityExt;
using mvz2logic.entities.LogicEntityExt;

@:autoEntityBehaviourDefinition(VanillaEnemyNames.motherTerror)
class MotherTerror extends AIEntityBehaviour implements IDeathEffectsBehaviour
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
    }
    public override function Init(entity:Entity):Void
    {
        super.Init(entity);
        entity.CollisionMaskFriendly |= EntityCollisionHelper.MASK_ENEMY;
    }
    public override function PostCollision(collision:EntityCollision, state:Int):Void
    {
        super.PostCollision(collision, state);
        if (!collision.Collider.IsForMain() || !collision.OtherCollider.IsForMain())
            return;
        var spider = collision.Entity;
        if (!HasEggs(spider))
            return;
        var other = collision.Other;
        if (state != EntityCollisionHelper.STATE_EXIT && spider != other && Detection.CanDetect(other) && spider.IsFriendly(other))
        {
            if (CanLayEgg(other))
            {
                LayEgg(spider, other);
            }
        }
    }
    public function DeathEffects(entity:Entity, info:DeathInfo):Void
    {
        if (!HasEggs(entity))
            return;
        var level = entity.Level;
        var count = level.GetMotherTerrorEggCount();
        for (i in 0...count)
        {
            entity.SpawnWithParams(VanillaEnemyID.parasiteTerror, entity.GetCenter());
        }
        entity.PlaySound(VanillaSoundID.bloody);
        entity.EmitBlood();
    }
    override function UpdateLogic(entity:Entity):Void
    {
        super.UpdateLogic(entity);
        // 设置血量状态。
        entity.SetAnimationInt("EggState", GetEggState(entity));
    }
    public static function HasEggs(spider:Entity):Bool
    {
        return !spider.HasBuff(MotherTerrorLaidBuff);
    }
    public static function CanLayEgg(target:Entity):Bool
    {
        if (target.IsDead)
            return false;
        if (target.IsEntityOf(VanillaEnemyID.motherTerror) || target.IsEntityOf(VanillaEnemyID.parasiteTerror))
            return false;
        if (target.GetShellID() != VanillaShellID.flesh)
            return false;
        if (target.HasBuff(TerrorParasitizedBuff))
            return false;
        return true;
    }
    public static function LayEgg(spider:Entity, target:Entity):Void
    {
        target.AddBuff(TerrorParasitizedBuff);
        target.PlaySound(VanillaSoundID.parasitize);
        spider.AddBuff(MotherTerrorLaidBuff);
    }
    static function GetEggState(entity:Entity):Int
    {
        return HasEggs(entity) ? 1 : -1;
    }
    public static var ID:NamespaceID = VanillaEnemyID.motherTerror;
}
