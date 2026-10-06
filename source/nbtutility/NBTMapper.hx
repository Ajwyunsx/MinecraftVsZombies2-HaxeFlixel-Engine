// Ported from: NBTUtility.dll (NBTMapper) — 外部预编译库，仓库内无 C# 源码

package nbtutility;

// PORT-NOTE: NBTUtility 为预编译 DLL，源码不在仓库中；
// 按其用途（把 NBTReader 读出的标签树映射为 NBTData 对象）重写最小等价实现。
class NBTMapper {
	private function new() {}

	public static function ToObject(reader:NBTReader):NBTData {
		return reader.ReadRoot();
	}
}
