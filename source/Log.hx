// Ported from: Tools/Unity/Log.cs
// PORT-NOTE: 该类型在 C# 中位于全局命名空间（Tools 程序集），因此 Haxe 侧同样不使用 package。
import unity.Debug;

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
