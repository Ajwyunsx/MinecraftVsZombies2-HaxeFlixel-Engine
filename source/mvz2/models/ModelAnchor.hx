// Ported from: Assets/Scripts/View/Models/ModelAnchor.cs
package mvz2.models;

class ModelAnchor extends unity.MonoBehaviour
{
	public var key:Null<String>;
	public var KeyHash(get, never):Int;
	function get_KeyHash():Int return keyHash;
	private var keyHash:Int = 0;

	public function new()
	{
		super();
	}

	function Awake():Void
	{
		// PORT-NOTE: Haxe 的 String 无 hashCode，用简易字符串哈希替代 C# string.GetHashCode。
		keyHash = key != null ? ModelAnchor.hashCodeOf(key) : 0;
	}
	// PORT-NOTE: 简易字符串哈希（C# string.GetHashCode 的对应物）。
	public static function hashCodeOf(s:String):Int {
		var h = 0;
		if (s != null) {
			for (i in 0...s.length)
				h = 31 * h + s.charCodeAt(i);
		}
		return h & 0x7FFFFFFF;
	}
}
