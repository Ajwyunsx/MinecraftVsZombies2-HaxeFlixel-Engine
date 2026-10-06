// Ported from: Assets/Scripts/Engine/Base/NamespaceIDReference.cs
package pvzengine.base;

import pvzengine.NamespaceID;

// PORT-NOTE: C# 中用 [SerializeField] 修饰的私有字段由 Unity 序列化系统填充（spacename/path）。
// Haxe 没有等价的自动字段注入，这里保留 @:serializeField 标记与私有字段原样（1:1），
// 实际数据由工程的序列化层（SaveManager/SerializeHelper 等）填充。
class NamespaceIDReference
{
    public function new() {}
    public function Get():NamespaceID
    {
        if (cache == null || cache.SpaceName != spacename || cache.Path != path)
        {
            cache = new NamespaceID(spacename, path);
        }
        return cache;
    }
    @:serializeField
    private var spacename:String = null;
    @:serializeField
    private var path:String = null;
    private var cache:Null<NamespaceID> = null;
}
