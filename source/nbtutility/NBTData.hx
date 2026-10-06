// Ported from: NBTUtility.dll (NBTData) — 外部预编译库，仓库内无 C# 源码

package nbtutility;

// PORT-NOTE: NBTUtility 是预编译 DLL（MVZ2.OldSave.asmdef 的 precompiledReferences），
// 仓库中没有它的源码，因此这里按 NBT 二进制格式规范重写最小等价实现：
// NBTData 为标签容器，值类型映射为 Int / Float / String / haxe.io.Bytes / Array<Dynamic> / NBTData。
class NBTData {
	private var values:Map<String, Dynamic>;

	public var Keys(get, never):Array<String>;
	public var Count(get, never):Int;

	public function new() {
		values = new Map();
	}

	// PORT-NOTE: C# IDictionary.TryGetValue(key, out value) 的 out 参数无法在 Haxe 表达，
	// 改为返回值：不存在时返回 null（调用处 `TryGetValue(key, out var v)` → `var v = TryGetValue(key)`）。
	public function TryGetValue(key:String):Null<Dynamic> {
		if (key == null || !values.exists(key))
			return null;
		return values.get(key);
	}

	public function ContainsKey(key:String):Bool {
		return key != null && values.exists(key);
	}

	// 等价于 C# 索引器 this[key] 的读/写。
	public function get(key:String):Null<Dynamic> {
		return TryGetValue(key);
	}
	public function set(key:String, value:Dynamic):Void {
		if (key == null)
			return;
		values.set(key, value);
	}

	public function Remove(key:String):Bool {
		if (key == null || !values.exists(key))
			return false;
		values.remove(key);
		return true;
	}

	public function Clear():Void {
		values.clear();
	}

	function get_Keys():Array<String> {
		var result = new Array<String>();
		for (key in values.keys())
			result.push(key);
		return result;
	}
	function get_Count():Int {
		var count = 0;
		for (key in values.keys())
			count++;
		return count;
	}
}
