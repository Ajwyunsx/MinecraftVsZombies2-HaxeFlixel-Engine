// Ported from: Assets/Scripts/Vanilla/GameContent/IZombie/IZE/IZE1/IZELayout.cs
package mvz2.gamecontent.izombie;

import mvz2.gamecontent.contraptions.VanillaContraptionID;
import mvz2logic.izombie.IIZombieMap;
import mvz2logic.izombie.IZombieLayoutDefinition;
import tools.RandomGenerator;
import unity.Mathf;

// abstract
class IZELayout extends IZombieLayoutDefinition
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name, 5);
    }
    // C#: public override sealed void Fill(IIZombieMap map, RandomGenerator rng)
    public override function Fill(map:IIZombieMap, rng:RandomGenerator):Void
    {
        FillEndlessContraptions(map, rng);
        FillFurnaces(map, rng);
    }
    // abstract
    // PORT-NOTE: C# 的 protected 抽象方法在 Haxe 中无对应可见性，改为 private（Haxe 子类仍可 override）。
    private function FillEndlessContraptions(map:IIZombieMap, rng:RandomGenerator):Void
    {
        throw "abstract";
    }
    // PORT-NOTE: C# 的 protected 方法在 Haxe 中无对应可见性，改为 private。
    private function FillFurnaces(map:IIZombieMap, rng:RandomGenerator):Void
    {
        // PORT-NOTE: C# Mathf.Max(int, int) 返回 int，此处用 Mathf.MaxInt；C# 的整除 map.Rounds / 2 用 Std.int 还原。
        var furnaceCount = Mathf.MaxInt(4, 8 - Std.int(map.Rounds / 2));
        RandomFillWithCount(map, VanillaContraptionID.furnace, furnaceCount, rng);
        RandomFillWithCount(map, VanillaContraptionID.smallDispenser, 8 - furnaceCount, rng);
    }
}
