// Ported from: Assets/Scripts/Engine/Level/Source/ILevelSourceReference.cs
package pvzengine.level;

import pvzengine.NamespaceID;

// PORT-NOTE: C# 的显式接口实现（`ILevelSourceReference ILevelSourceReference.Clone()` 等）在 Haxe 中
// 无法表达，统一改为普通公开成员；实现类的返回类型使用协变（如 EntitySourceReference.Clone():EntitySourceReference）
// 以满足既有调用点对具体类型的使用。
// PORT-NOTE: 属性访问器声明为 (get, never)，与既有实现（mvz2logic/artifacts/ArtifactSourceReference.hx）
// 及调用点一致。
//
// PORT-NOTE: 既有移植代码以实例形式调用 C# 的扩展方法 `LevelSourceReferenceExt.GetEntity(source, level)`，
// 例如 `source.GetEntity(entity.Level)`（mvz2/gamecontent/bosses/Wither.hx），故用 @:using 把
// LevelSourceReferenceExt 的扩展方法挂到本接口上。
//
// PORT-NOTE: 原 C# 文件同时定义 ILevelSourceReference / ILevelSourceTarget / ISerializableSourceReference，
// 而既有移植代码分别以 `import pvzengine.level.ILevelSourceTarget;`、
// `import pvzengine.level.ISerializableSourceReference;` 引用后两者，Haxe 要求「模块名 == 主类型名」，
// 故拆分为三个模块（本文件只保留 ILevelSourceReference）。
@:using(pvzengine.level.LevelSourceReferenceExt)
// PORT-NOTE: C# 的 EngineEntityExt.IsEntitySpawnedByEntity(this ILevelSourceReference reference, ...)
//   同样是本接口上的扩展方法，既有上层调用点写作 `source.IsEntitySpawnedByEntity(level, cb)`
//   （mvz2/gamecontent/globalcallbacks/AchievementsGlobalCallbacks.hx 2 处），故一并标注。
@:using(pvzengine.entities.EngineEntityExt)
interface ILevelSourceReference
{
	public function Clone():ILevelSourceReference;
	public function GetTarget(level:LevelEngine):Null<ILevelSourceTarget>;
	public var Parent(get, never):Null<ILevelSourceReference>;
	public var Faction(get, never):Int;
	public var DefinitionID(get, never):Null<NamespaceID>;
	public var ID(get, never):haxe.Int64;
	public function ToSerializable():ISerializableSourceReference;
}
