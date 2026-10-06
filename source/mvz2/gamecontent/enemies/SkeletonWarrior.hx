// Ported from: Assets/Scripts/Vanilla/GameContent/Enemies/Chapter4/SkeletonWarrior.cs
package mvz2.gamecontent.enemies;

import mvz2.gamecontent.buffs.armors.IZombieSkeletonWarriorArmorBuff;
import mvz2.gamecontent.buffs.enemies.IZombieSkeletonWarriorBuff;
import mvz2.gamecontent.entities.AIEntityBehaviour;
import mvz2logic.armors.LogicArmorSlots;
import mvz2logic.level.LogicLevelExt;
import pvzengine.buffs.BuffExt;
import pvzengine.entities.Entity;
using mvz2.vanilla.entities.VanillaEntityExt;

@:autoEntityBehaviourDefinition(VanillaEnemyNames.skeletonWarrior)
class SkeletonWarrior extends AIEntityBehaviour
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
    }
    public override function Init(entity:Entity):Void
    {
        super.Init(entity);
        if (entity.Level.IsIZombie())
        {
            entity.AddBuff(IZombieSkeletonWarriorBuff);
            var helmet = entity.GetMainArmor();
            var shield = entity.GetArmorAtSlot(LogicArmorSlots.shield);
            if (helmet != null)
                helmet.AddBuff(IZombieSkeletonWarriorArmorBuff);
            if (shield != null)
                shield.AddBuff(IZombieSkeletonWarriorArmorBuff);
        }
    }
}
