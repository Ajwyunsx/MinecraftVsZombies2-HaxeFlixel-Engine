// Ported from: Assets/Scripts/Vanilla/GameContent/Stages/Behaviours/IZombie/IZombieEndlessBaseBehaviour.cs
package mvz2.gamecontent.stages;

import mvz2logic.izombie.IZombieLayoutDefinition;
import mvz2logic.level.LogicLevelExt;
import mvz2logic.level.LogicLevelProps;
import pvzengine.NamespaceID;
import pvzengine.level.LevelEngine;
import pvzengine.level.StageDefinition;
import tools.RandomGenerator;
import unity.Mathf;

// abstract
class IZombieEndlessBaseBehaviour extends IZombieBehaviour
{
    public function new(stageDef:StageDefinition)
    {
        super(stageDef);
        // PORT-NOTE: C# 的 abstract IEnumerable 方法改为 Array，子类返回数组字面量。
        for (item in GetNormalLayouts())
        {
            normalLayouts.push(item);
        }
        for (item in GetAwardLayouts())
        {
            awardLayouts.push(item);
        }
    }
    override public function Start(level:LevelEngine):Void
    {
        super.Start(level);
        LogicLevelProps.SetPickaxeRemainCount(level, START_PICKAXE_COUNT);
    }
    override public function NextRoundWithLayout(level:LevelEngine, layoutID:NamespaceID):Void
    {
        super.NextRoundWithLayout(level, layoutID);
        if (level.CurrentFlag % ROUNDS_PER_PICKAXE == 0 && LogicLevelProps.IsPickaxeCountLimited(level))
        {
            var pickaxeCount = LogicLevelProps.GetPickaxeRemainCount(level);
            pickaxeCount = Mathf.MinInt(LogicLevelProps.GetPickaxeCountLimit(level), pickaxeCount + 1);
            LogicLevelProps.SetPickaxeRemainCount(level, pickaxeCount);
        }
    }
    override public function GetNewLayout(round:Int, rng:RandomGenerator):NamespaceID
    {
        if (round == 0)
            return GetFirstLayoutID();

        if (round % 5 == 0)
        {
            // TODO-PORT: C# Tools 扩展方法 WeightedRandom<T>(this IEnumerable<T>, Func<T,float>, RandomGenerator)（Engine 子模块源码缺失，需由 pvzengine 工作包提供）。
            // Haxe 端 RandomGenerator.WeightedRandom 接受 Array<Int>，此处将 float 权重放大 100 倍取整。
            var weights = [for (i in awardLayouts) Std.int(i.weight * 100)];
            var index = rng.WeightedRandom(weights);
            return awardLayouts[index].id;
        }

        var normalWeights = [for (i in normalLayouts) Std.int(i.weight * 100)];
        var normalIndex = rng.WeightedRandom(normalWeights);
        return normalLayouts[normalIndex].id;
    }

    override public function GetMaxRounds():Int
    {
        return -1;
    }
    override public function ReplaceBlueprints(level:LevelEngine, layout:IZombieLayoutDefinition):Void
    {
        LogicLevelExt.FillSeedPacks(level, GetBlueprints());
    }
    // abstract
    public function GetFirstLayoutID():NamespaceID
    {
        throw "abstract";
    }
    // abstract
    public function GetNormalLayouts():Array<IZELayoutItem>
    {
        throw "abstract";
    }
    // abstract
    public function GetAwardLayouts():Array<IZELayoutItem>
    {
        throw "abstract";
    }
    // abstract
    public function GetBlueprints():Array<NamespaceID>
    {
        throw "abstract";
    }
    public static inline var ROUNDS_PER_PICKAXE:Int = 2;
    public static inline var START_PICKAXE_COUNT:Int = 1;
    override public function get_AllowPickaxe():Bool return true;
    private var normalLayouts:Array<IZELayoutItem> = new Array<IZELayoutItem>();
    private var awardLayouts:Array<IZELayoutItem> = new Array<IZELayoutItem>();
}

// C#: public struct IZELayoutItem
class IZELayoutItem
{
    public var id:NamespaceID;
    public var weight:Float;

    public function new(id:NamespaceID, weight:Float = 1)
    {
        this.id = id;
        this.weight = weight;
    }
}
