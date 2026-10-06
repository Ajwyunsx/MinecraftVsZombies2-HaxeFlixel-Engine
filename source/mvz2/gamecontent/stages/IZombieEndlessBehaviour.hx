// Ported from: Assets/Scripts/Vanilla/GameContent/Stages/Behaviours/IZombie/IZombieEndlessBehaviour.cs
package mvz2.gamecontent.stages;

import mvz2.gamecontent.enemies.VanillaEnemyID;
import mvz2logic.blueprints.LogicBlueprintID;
import pvzengine.NamespaceID;
import pvzengine.level.StageDefinition;

class IZombieEndlessBehaviour extends IZombieEndlessBaseBehaviour
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
            new IZombieEndlessBaseBehaviour.IZELayoutItem(VanillaIZombieLayoutID.izeComposite, 1.5), // 综合
            new IZombieEndlessBaseBehaviour.IZELayoutItem(VanillaIZombieLayoutID.izeControl, 1.5), // 控制
            new IZombieEndlessBaseBehaviour.IZELayoutItem(VanillaIZombieLayoutID.izeInstakill, 1), // 秒杀

            // B级别
            new IZombieEndlessBaseBehaviour.IZELayoutItem(VanillaIZombieLayoutID.izeSpikes, 0.2), // 木投石车
            new IZombieEndlessBaseBehaviour.IZELayoutItem(VanillaIZombieLayoutID.izeDispensers, 0.2), // 发射器
            new IZombieEndlessBaseBehaviour.IZELayoutItem(VanillaIZombieLayoutID.izeExplosives, 0.2), // 爆炸
            new IZombieEndlessBaseBehaviour.IZELayoutItem(VanillaIZombieLayoutID.izeFire, 0.2), // 火焰
            new IZombieEndlessBaseBehaviour.IZELayoutItem(VanillaIZombieLayoutID.izeAwards, 0.2), // 奖励
        ];
    }
    override public function GetAwardLayouts():Array<IZombieEndlessBaseBehaviour.IZELayoutItem>
    {
        return [
            new IZombieEndlessBaseBehaviour.IZELayoutItem(VanillaIZombieLayoutID.izeAwards),
            new IZombieEndlessBaseBehaviour.IZELayoutItem(VanillaIZombieLayoutID.izeError, 0.2),
        ];
    }
    override public function GetFirstLayoutID():NamespaceID
    {
        return VanillaIZombieLayoutID.izeComposite;
    }
    override public function GetBlueprints():Array<NamespaceID>
    {
        return [
            LogicBlueprintID.FromEntity(VanillaEnemyID.imp),
            LogicBlueprintID.FromEntity(VanillaEnemyID.leatherCappedZombie),
            LogicBlueprintID.FromEntity(VanillaEnemyID.ghost),
            LogicBlueprintID.FromEntity(VanillaEnemyID.skeletonHorse),
            LogicBlueprintID.FromEntity(VanillaEnemyID.reflectiveBarrierZombie),
            LogicBlueprintID.FromEntity(VanillaEnemyID.gargoyle),
            LogicBlueprintID.FromEntity(VanillaEnemyID.ironHelmettedZombie),
            LogicBlueprintID.FromEntity(VanillaEnemyID.wickedHermitZombie),
            LogicBlueprintID.FromEntity(VanillaEnemyID.skeletonWarrior),
            LogicBlueprintID.FromEntity(VanillaEnemyID.dullahan),
        ];
    }
}
