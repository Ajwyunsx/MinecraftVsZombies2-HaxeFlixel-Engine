// Ported from: Assets/Scripts/Engine/Level/Damage/HealInput.cs
package pvzengine.damages;

import pvzengine.armors.Armor;
import pvzengine.entities.Entity;
import pvzengine.level.ILevelSourceReference;

class HealInput
{
    // PORT-NOTE: C# 有两个构造函数：
    //   HealInput(float amount, Entity entity, ILevelSourceReference? source)
    //   HealInput(float amount, Entity entity, Armor armor, ILevelSourceReference? source)
    // Haxe 不支持构造函数重载，且两处既有调用点分别使用 3 参（第 3 参为 source）与 4 参（第 3 参为 armor）形式，
    // 故第 3 个参数声明为 Dynamic 并按类型分派：是 Armor 则走治疗护甲分支，否则视为 source。
    public function new(amount:Float, entity:Entity, armorOrSource:Dynamic = null, source:Null<ILevelSourceReference> = null)
    {
        OriginalAmount = amount;
        Amount = amount;
        Entity = entity;
        if (Std.isOfType(armorOrSource, Armor))
        {
            Armor = cast armorOrSource;
            Source = source;
            ToArmor = true;
        }
        else
        {
            Armor = null;
            Source = cast armorOrSource;
            ToArmor = false;
        }
    }
    public function Add(value:Float):Void
    {
        Amount += value;
    }
    public function Multiply(value:Float):Void
    {
        Amount *= value;
    }
    public var OriginalAmount(default, null):Float;
    public var Amount(default, null):Float;
    public var Entity(default, null):Entity;
    public var Armor(default, null):Null<Armor>;
    public var Source:Null<ILevelSourceReference>;
    public var ToArmor(default, null):Bool;
}
