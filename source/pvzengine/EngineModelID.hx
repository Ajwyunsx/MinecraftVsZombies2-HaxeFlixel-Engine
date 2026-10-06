// Ported from: Assets/Scripts/Engine/Level/EngineModelID.cs
// PORT-NOTE: C# 中 ToModelID 为 NamespaceID 的扩展方法（namespace PVZEngine）。
//   既有调用点以实例形式调用（`new NamespaceID(...).ToModelID(EngineModelID.TYPE_ENTITY)`，
//   见 mvz2/gamecontent/models/VanillaModelID.hx、mvz2/gamecontent/pickups/Starshard.hx），
//   故除了保留 C# 静态方法，还在 NamespaceID 上通过 @:using 挂载本类的扩展方法（见 pvzengine/NamespaceID.hx）。
package pvzengine;

import pvzengine.NamespaceID;

class EngineModelID
{
	public static inline var TYPE_ENTITY:String = "entity";
	public static inline var TYPE_ARMOR:String = "armor";
	public static function ToModelID(id:NamespaceID, type:String):NamespaceID
	{
		return new NamespaceID(id.SpaceName, ConcatName(type, id.Path));
	}
	public static function ConcatName(type:String, name:String):String
	{
		return '${type}.${name}';
	}
}
