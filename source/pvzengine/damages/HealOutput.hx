// Ported from: Assets/Scripts/Engine/Level/Damage/HealOutput.cs
package pvzengine.damages;

import pvzengine.armors.Armor;
import pvzengine.entities.Entity;
import pvzengine.level.ILevelSourceReference;

class HealOutput
{
    public function new(entity:Entity, source:Null<ILevelSourceReference>)
    {
        Source = source;
        Entity = entity;
    }

    public var Source:Null<ILevelSourceReference>;
    public var Entity:Entity;
    public var OriginalAmount:Float;
    public var Amount:Float;
    public var RealAmount:Float;
    public var Armor:Null<Armor>;
    public var ToArmor:Bool;
}
