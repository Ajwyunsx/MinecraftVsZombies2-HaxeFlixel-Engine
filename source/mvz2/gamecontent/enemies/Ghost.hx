// Ported from: Assets/Scripts/Vanilla/GameContent/Enemies/Chapter1/Ghost.cs
package mvz2.gamecontent.enemies;

import mvz2.gamecontent.buffs.enemies.FlyBuff;
import mvz2.gamecontent.buffs.enemies.GhostBuff;
import mvz2.gamecontent.damages.VanillaDamageEffects;
import mvz2.gamecontent.entities.AIEntityBehaviour;
import mvz2.vanilla.unlocks.VanillaUnlockID;
import mvz2logic.Global;
import mvz2logic.level.LogicLevelExt;
import pvzengine.NamespaceID;
import pvzengine.buffs.BuffExt;
import pvzengine.damages.DeathInfo;
import pvzengine.entities.Entity;

@:autoEntityBehaviourDefinition(VanillaEnemyNames.ghost)
class Ghost extends AIEntityBehaviour
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
    }
    public override function Init(entity:Entity):Void
    {
        super.Init(entity);
        if (!entity.HasBuff(GhostBuff))
        {
            entity.AddBuff(GhostBuff);
        }
        var buff = entity.AddBuff(FlyBuff);
        buff.SetProperty(FlyBuff.PROP_TARGET_HEIGHT, 1);
    }
    override function UpdateLogic(entity:Entity):Void
    {
        super.UpdateLogic(entity);
        if (!entity.HasBuff(GhostBuff))
        {
            entity.AddBuff(GhostBuff);
        }
    }
    public override function PostDeath(entity:Entity, info:DeathInfo):Void
    {
        super.PostDeath(entity, info);
        if (!GhostBuff.IsEverIlluminatedEntity(entity) && !info.Effects.HasEffect(VanillaDamageEffects.WHACK) && !entity.Level.IsIZombie())
        {
            Global.Saves.Unlock(VanillaUnlockID.ghostBuster);
            Global.Saves.SaveToFile(); // 完成成就后保存游戏。
        }
    }
    public static var ID:NamespaceID = VanillaEnemyID.ghost;
}
