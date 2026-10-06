// Ported from: Assets/Scripts/Vanilla/GameContent/Stages/Behaviours/IZombie/IZombieEndless2Behaviour.cs
package mvz2.gamecontent.stages;

import mvz2.gamecontent.enemies.VanillaEnemyID;
import mvz2logic.blueprints.LogicBlueprintID;
import pvzengine.NamespaceID;
import pvzengine.level.StageDefinition;

class IZombieEndless2Behaviour extends IZombieEndlessBaseBehaviour
{
    public function new(stageDef:StageDefinition)
    {
        super(stageDef);
    }
    override public function GetNormalLayouts():Array<IZombieEndlessBaseBehaviour.IZELayoutItem>
    {
        // PORT-NOTE: C# 的 `yield return` 迭代器方法改为返回数组。
        return [
            // A级别
            new IZombieEndlessBaseBehaviour.IZELayoutItem(VanillaIZombieLayoutID.ize2Composite, 1.2), // 综合
            new IZombieEndlessBaseBehaviour.IZELayoutItem(VanillaIZombieLayoutID.ize2Control, 1.2), // 控制
            new IZombieEndlessBaseBehaviour.IZELayoutItem(VanillaIZombieLayoutID.ize2Spectral, 1.0), // 幽灵（有1个药桶）

            // B级别
            new IZombieEndlessBaseBehaviour.IZELayoutItem(VanillaIZombieLayoutID.ize2Spikes, 0.4), // 木斜
            new IZombieEndlessBaseBehaviour.IZELayoutItem(VanillaIZombieLayoutID.ize2Dispensers, 0.4), // 发射器（有1个药桶）
            new IZombieEndlessBaseBehaviour.IZELayoutItem(VanillaIZombieLayoutID.ize2Impale, 0.4), // 穿刺
            new IZombieEndlessBaseBehaviour.IZELayoutItem(VanillaIZombieLayoutID.ize2Fire, 0.4), // 火焰
            new IZombieEndlessBaseBehaviour.IZELayoutItem(VanillaIZombieLayoutID.ize2Instakill, 0.2), // 秒杀
            new IZombieEndlessBaseBehaviour.IZELayoutItem(VanillaIZombieLayoutID.izeAwards, 0.2), // 奖励
        ];
    }
    override public function GetAwardLayouts():Array<IZombieEndlessBaseBehaviour.IZELayoutItem>
    {
        return [
            new IZombieEndlessBaseBehaviour.IZELayoutItem(VanillaIZombieLayoutID.izeAwards),
            new IZombieEndlessBaseBehaviour.IZELayoutItem(VanillaIZombieLayoutID.ize2Gunpowder, 0.2),
        ];
    }
    override public function GetFirstLayoutID():NamespaceID
    {
        return VanillaIZombieLayoutID.ize2Composite;
    }
    override public function GetBlueprints():Array<NamespaceID>
    {
        return [
            LogicBlueprintID.FromEntity(VanillaEnemyID.imp),
            LogicBlueprintID.FromEntity(VanillaEnemyID.leatherCappedZombie),
            LogicBlueprintID.FromEntity(VanillaEnemyID.skeletonStatue),
            LogicBlueprintID.FromEntity(VanillaEnemyID.hacker),
            LogicBlueprintID.FromEntity(VanillaEnemyID.ironHelmettedZombie),
            LogicBlueprintID.FromEntity(VanillaEnemyID.cannoneerZombie),
            LogicBlueprintID.FromEntity(VanillaEnemyID.shadowCell),
            LogicBlueprintID.FromEntity(VanillaEnemyID.zombieCat),
            LogicBlueprintID.FromEntity(VanillaEnemyID.zombieCloud),
            LogicBlueprintID.FromEntity(VanillaEnemyID.popCaptain),
        ];
    }
}
