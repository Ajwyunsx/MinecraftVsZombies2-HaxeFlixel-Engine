// Ported from: Assets/Scripts/Engine/Level/Collisions/ColliderUpdateMode.cs
package pvzengine.collisions;

// PORT-NOTE: C# enum → Haxe enum abstract。
// PORT-NOTE: mvz2/collisions/UnityEntityCollider.hx 中另有一个同名的 mvz2.collisions.ColliderUpdateMode
// （其值为 Main = 1 / Custom = 2），两者互不影响；本类型是 C# PVZEngine.Collisions.ColliderUpdateMode 的移植。
enum abstract ColliderUpdateMode(Int)
{
    var Main = 0;
    var Custom = 1;
}
