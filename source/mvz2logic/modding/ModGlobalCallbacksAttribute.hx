// Ported from: Assets/Scripts/Logic/Modding/ModGlobalCallbacksAttribute.cs
package mvz2logic.modding;

// [AttributeUsage(AttributeTargets.Class, AllowMultiple = false, Inherited = false)]
// PORT-NOTE: Haxe 无 C# 特性机制，标注类的用法改为 `@:modGlobalCallbacks` 元数据；本类保留以 1:1 记录原类型。
class ModGlobalCallbacksAttribute
{
	public function new() {}
}
