// Ported from: Assets/Scripts/Engine/Base/Properties/PropertyKey.cs (interface IPropertyKey)
package pvzengine;

// PORT-NOTE: 原 C# 文件 Properties/PropertyKey.cs 同时定义了 IPropertyKey、PropertyKeyHelper、
// InvalidPropertyKey、PropertyKey<T>、PropertyKeyComparer，均位于命名空间 `PVZEngine`。
// Haxe 要求「模块路径 == 主类型名」才能被 `import pvzengine.X` 解析，而既有移植代码分别以
// `import pvzengine.IPropertyKey;`、`import pvzengine.PropertyKey;`、`import pvzengine.PropertyKeyHelper;`
// 三种路径引用它们，因此本文件只保留 IPropertyKey 一个类型，其余类型拆到同名模块中。
// PORT-NOTE: PropertyKeyHelper.IsValid(this IPropertyKey key) 是 C# 扩展方法，既有调用点写作 `key.IsValid()`，
//   这里按工程既有约定（同 IHasModel、ILevelSourceReference）在接口上标注 @:using；
//   静态形式 PropertyKeyHelper.IsValid(key) 亦保留。
@:using(pvzengine.PropertyKeyHelper)
interface IPropertyKey
{
    public var Key(get, never):Int;
    // PORT-NOTE: C# 为 `System.Type Type { get; }`。Haxe 无运行期泛型类型信息，
    // 这里保留同名成员并用 Dynamic 表示（PropertyKey<T> 中返回 null）。
    public var Type(get, never):Dynamic;
    public var DefaultValue(get, never):Dynamic;
}
