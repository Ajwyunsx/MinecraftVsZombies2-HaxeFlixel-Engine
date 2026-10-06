// Ported from: Assets/Scripts/Engine/Level/Source/LevelSourceReferenceExt.cs
package pvzengine.level;

import pvzengine.entities.Entity;
import pvzengine.entities.EntitySourceReference;

// PORT-NOTE: C# 扩展方法 -> Haxe 静态工具类；同时通过 ILevelSourceReference 上的
// `@:using(pvzengine.level.LevelSourceReferenceExt)` 保留原有的 instance 调用写法
// （`source.GetEntity(level)`）。
class LevelSourceReferenceExt
{
	public static function GetEntity(source:ILevelSourceReference, level:LevelEngine):Null<Entity>
	{
		if (!Std.isOfType(source, EntitySourceReference))
			return null;
		var entSource:EntitySourceReference = cast source;
		return entSource.GetEntity(level);
	}
}
