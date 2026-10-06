// Ported from: Assets/Scripts/Engine/Level/Collisions/ColliderConstructor.cs
// PORT-NOTE: C# 为 struct。Haxe 没有值类型，改为普通类，构造参数全部给默认值，
// 以支持 C# 中的 `new ColliderConstructor()`（等价于 struct 的零初始化，
// 见 mvz2/metas/MetaXMLParser.hx 的 LoadColliderConstructor）。
// PORT-NOTE: 缺少 struct 的按值拷贝语义：`var newCons = cons;` 这类赋值在 Haxe 中只是引用别名，
// 因此上层 mvz2logic/armors/MetaArmorDefinition.hx 就地修改 size/offset 会影响到原实例（C# 中不会）。
package pvzengine.collisions;

import pvzengine.NamespaceID;
import unity.Vector3;

class ColliderConstructor
{
    public function new(name:String = null, armorSlot:NamespaceID = null, size:Vector3 = null, offset:Vector3 = null, pivot:Vector3 = null)
    {
        this.name = name;
        this.armorSlot = armorSlot;
        this.size = size;
        this.offset = offset;
        this.pivot = pivot;
    }
    public var name:String;
    public var armorSlot:NamespaceID;
    public var size:Vector3 = new Vector3(0, 0, 0); // PORT-NOTE: C# Vector3 为 struct，默认 (0,0,0)；显式初始化避免 abstract-over-class 的 null 解引用
    public var offset:Vector3 = new Vector3(0, 0, 0); // PORT-NOTE: C# Vector3 为 struct，默认 (0,0,0)；显式初始化避免 abstract-over-class 的 null 解引用
    public var pivot:Vector3 = new Vector3(0, 0, 0); // PORT-NOTE: C# Vector3 为 struct，默认 (0,0,0)；显式初始化避免 abstract-over-class 的 null 解引用
}
