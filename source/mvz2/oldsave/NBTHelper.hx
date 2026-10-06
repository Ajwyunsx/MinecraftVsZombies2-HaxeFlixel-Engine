// Ported from: Assets/Scripts/OldSave/NBTHelper.cs

package mvz2.oldsave;

import nbtutility.NBTData;

// PORT-NOTE: C# 扩展方法（this NBTData nbt）→ Haxe 静态普通方法，调用处由 `nbt.LoadInt(...)`
// 改为 `NBTHelper.LoadInt(nbt, ...)`（PORTING.md §扩展方法）。
// PORT-NOTE: C# internal static class → Haxe 普通 class（Haxe 无 internal 可见性）。
// PORT-NOTE: C# byte/short/long → Haxe Int/Int/haxe.Int64；byte[] → haxe.io.Bytes。
class NBTHelper {
	private function new() {}

	public static function LoadBool(nbt:NBTData, key:String, defaultValue:Bool):Bool {
		var data = nbt.TryGetValue(key);
		return data != null ? (cast(data, Int) > 0) : defaultValue;
	}
	public static function LoadByte(nbt:NBTData, key:String, defaultValue:Int):Int {
		var data = nbt.TryGetValue(key);
		return data != null ? cast(data, Int) : defaultValue;
	}
	public static function LoadShort(nbt:NBTData, key:String, defaultValue:Int):Int {
		var data = nbt.TryGetValue(key);
		return data != null ? cast(data, Int) : defaultValue;
	}
	public static function LoadInt(nbt:NBTData, key:String, defaultValue:Int):Int {
		var data = nbt.TryGetValue(key);
		return data != null ? cast(data, Int) : defaultValue;
	}
	public static function LoadLong(nbt:NBTData, key:String, defaultValue:haxe.Int64):haxe.Int64 {
		var data = nbt.TryGetValue(key);
		return data != null ? cast(data, haxe.Int64) : defaultValue;
	}
	public static function LoadFloat(nbt:NBTData, key:String, defaultValue:Float):Float {
		var data = nbt.TryGetValue(key);
		return data != null ? cast(data, Float) : defaultValue;
	}
	public static function LoadDouble(nbt:NBTData, key:String, defaultValue:Float):Float {
		var data = nbt.TryGetValue(key);
		return data != null ? cast(data, Float) : defaultValue;
	}
	public static function LoadString(nbt:NBTData, key:String, defaultValue:String):String {
		var data = nbt.TryGetValue(key);
		return data != null ? cast(data, String) : defaultValue;
	}
	public static function LoadByteArray(nbt:NBTData, key:String, defaultValue:haxe.io.Bytes):haxe.io.Bytes {
		var data = nbt.TryGetValue(key);
		return data != null ? cast(data, haxe.io.Bytes) : defaultValue;
	}
}
