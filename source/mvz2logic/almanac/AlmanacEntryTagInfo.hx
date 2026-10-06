// Ported from: Assets/Scripts/Logic/Almanac/AlmanacEntryIcon.cs
// PORT-NOTE: C# 文件名（AlmanacEntryIcon.cs）与其唯一类型名（AlmanacEntryTagInfo）不同，
// 为使跨包引用路径（mvz2logic.almanac.AlmanacEntryTagInfo）可用，按类型名建模块。
package mvz2logic.almanac;

import pvzengine.NamespaceID;

class AlmanacEntryTagInfo
{
	public var tagID:NamespaceID;
	public var enumValue:String;

	// PORT-NOTE: C# 有两个构造函数 (tagID, enumValue) 与 (tagID)，Haxe 不支持重载，用可选参数合并。
	public function new(tagID:NamespaceID, enumValue:String = "")
	{
		this.tagID = tagID;
		this.enumValue = enumValue;
	}
}
