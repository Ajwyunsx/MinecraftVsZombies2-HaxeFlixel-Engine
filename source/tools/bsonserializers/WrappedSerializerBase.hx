// Ported from: Assets/Scripts/Engine/Tools/BsonSerializers/WrappedClassSerializerBase.cs
// PORT-NOTE: C# 文件名为 WrappedClassSerializerBase.cs，其中唯一类型名为 WrappedSerializerBase<TValue>。
// Haxe 要求「模块名 == 主类型名」，故本文件命名为 WrappedSerializerBase.hx。
package tools.bsonserializers;

/**
 * PORT-NOTE: 原类继承 `ClassSerializerBase<TValue> where TValue : class`，并依赖 BSON 的
 * `DiscriminatedWrapperSerializer<T>` / `ScalarDiscriminatorConvention`。Haxe 侧无 MongoDB.Bson 运行时，
 * 故基类改为普通类、上下文参数改为 `Dynamic`，多态包装分支按 TODO-PORT 省略（直接走子类实现）。
 */
class WrappedSerializerBase<TValue>
{
	public function new() {}

	public function DeserializeValue(context:Dynamic, args:Dynamic):TValue
	{
		// TODO-PORT: 原实现先尝试用 DiscriminatedWrapperSerializer<TValue>(_discriminatorConvention, this)
		// 判断当前位置是否为多态包装文档（IsPositionedAtDiscriminatedWrapper），是则按包装反序列化。
		// Haxe 无 BSON 序列化框架，无法还原该判断，直接调用子类实现。
		return DeserializeClassValue(context, args);
	}
	function DeserializeClassValue(context:Dynamic, args:Dynamic):TValue
	{
		throw "abstract";
	}
}
