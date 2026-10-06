// Ported from: Assets/Scripts/Engine/Level/Collisions/Level/ICollisionSystem.cs
// PORT-NOTE: 从 C# 的 ICollisionSystem.cs 中拆出的独立模块（详见 ICollisionSystem.hx 的 PORT-NOTE）。
// PORT-NOTE: C# 为 struct；上层代码（mvz2/level/components/LightComponent.hx）会就地修改字段
// （`overlapParam.includeIgnored = true;`），且 mvz2/collisions/UnityCollisionSystem.hx 以 `param.hostileMask` 读取，
// 因此实现为带字段的普通类。
package pvzengine.collisions.level;

class OverlapParams
{
    public function new(faction:Int, hostileMask:Int, friendlyMask:Int, includeIgnored:Bool = false)
    {
        this.faction = faction;
        this.hostileMask = hostileMask;
        this.friendlyMask = friendlyMask;
        this.includeIgnored = includeIgnored;
    }
    public static function Hostile(faction:Int, mask:Int, includeIgnored:Bool = false):OverlapParams
    {
        return new OverlapParams(faction, mask, 0, includeIgnored);
    }
    public static function Friendly(faction:Int, mask:Int, includeIgnored:Bool = false):OverlapParams
    {
        return new OverlapParams(faction, 0, mask, includeIgnored);
    }
    public static function AnyFaction(mask:Int, includeIgnored:Bool = false):OverlapParams
    {
        return new OverlapParams(0, mask, mask, includeIgnored);
    }
    public var faction:Int;
    public var hostileMask:Int;
    public var friendlyMask:Int;
    public var includeIgnored:Bool;
}
