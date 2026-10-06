// Ported from: Assets/Scripts/Engine/Level/Source/ILevelSourceReference.cs (interface ISerializableSourceReference)
package pvzengine.level;

// PORT-NOTE: 原 C# 文件同时定义三个接口，Haxe 要求「模块名 == 主类型名」以便
//   `import pvzengine.level.ISerializableSourceReference;` 解析，故拆分为独立模块
//   （见 ILevelSourceReference.hx 的说明）。
interface ISerializableSourceReference
{
	public function ToDeserialized(level:LevelEngine):ILevelSourceReference;
}
