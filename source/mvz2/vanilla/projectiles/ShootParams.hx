// Ported from: Assets/Scripts/Vanilla/GameContent/Projectiles/VanillaProjectileExt.cs
package mvz2.vanilla.projectiles;

import pvzengine.NamespaceID;
import pvzengine.entities.SpawnParams;
import unity.Vector3;

// C# STRUCT: ShootParams
class ShootParams
{
    public function new()
    {
    }
    public var projectileID:Null<NamespaceID>;
    public var position:Vector3 = new Vector3(0, 0, 0);
    public var pivot:Vector3 = new Vector3(0, 0, 0);
    public var velocity:Vector3 = new Vector3(0, 0, 0);
    public var soundID:Null<NamespaceID>;
    public var damage:Float = 0;
    public var faction:Int = 0;
    public var spawnParam:SpawnParams;
}
