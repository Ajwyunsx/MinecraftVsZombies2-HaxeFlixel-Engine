// Ported from: Assets/Scripts/Vanilla/GameContent/Enemies/RickrollDrownAchievementBehaviour.cs
package mvz2.gamecontent.enemies;

import mvz2.gamecontent.buffs.enemies.BoatBuff;
import mvz2.gamecontent.damages.VanillaDamageEffects;
import mvz2.gamecontent.entities.AIEntityBehaviour;
import mvz2.vanilla.entities.VanillaEntityBehaviourNames;
import mvz2.vanilla.entities.VanillaEntityExt;
import mvz2.vanilla.unlocks.VanillaUnlockID;
import mvz2logic.Global;
import mvz2logic.level.LogicLevelExt;
import pvzengine.buffs.BuffExt;
import pvzengine.damages.DeathInfo;
import pvzengine.entities.Entity;

@:autoEntityBehaviourDefinition(VanillaEntityBehaviourNames.rickrollDrownAchievement)
class RickrollDrownAchievementBehaviour extends AIEntityBehaviour
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
    }
    public override function PostDeath(entity:Entity, info:DeathInfo):Void
    {
        super.PostDeath(entity, info);
        if (!entity.HasBuff(BoatBuff) && info.Effects.HasEffect(VanillaDamageEffects.DROWN) && !entity.Level.IsIZombie())
        {
            Global.Saves.Unlock(VanillaUnlockID.rickrollDrown);
            Global.Saves.SaveToFile(); // 完成成就后保存游戏。
        }
    }
}
