// Ported from: Assets/Scripts/Engine/Tools/Unity/Log.cs
package pvzengine;

import unity.Debug;

/**
 * C# 的 `Log` 类位于全局命名空间（Tools 程序集，Tools/Unity/Log.cs），
 * 因此默认包的 `HaxePort/source/Log.hx` 才是它的正典移植。
 * PORT-NOTE: 既有上层调用点大量使用 `import pvzengine.Log;`（另有 `pvzengine.base.Log`、
 * `mvz2logic.Log`），而 Haxe 无法在“与目标同名的模块”中引用默认包的 `Log`（名称遮蔽），
 * 故此处按同一实现再提供一份，保证这些 import 都能解析；成员签名与原实现完全一致。
 */
class Log
{
	public static function LogMessage(message:String):Void
	{
		Debug.Log(message);
	}
	public static function LogWarning(message:String):Void
	{
		Debug.LogWarning(message);
	}
	public static function LogError(message:String):Void
	{
		Debug.LogError(message);
	}
	public static function LogException(exception:Dynamic):Void
	{
		Debug.LogException(exception);
	}
}
