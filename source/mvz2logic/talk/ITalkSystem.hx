// Ported from: Assets/Scripts/Logic/Talk/ITalkSystem.cs
// PORT-NOTE: 同文件的 ITalkController（含默认实现辅助类）已拆为独立模块 mvz2logic/talk/ITalkController.hx。
package mvz2logic.talk;

import mvz2logic.archive.IArchiveInterface;
import mvz2logic.maps.IMapInterface;
import mvz2logic.scenes.IDialogDisplayer;
import pvzengine.level.LevelEngine;
import system.threading.tasks.Task;

interface ITalkSystem extends IDialogDisplayer extends ITalkController
{
	function StartSection(section:Int):Task;
	function GetLevel():Null<LevelEngine>;
	function GetMap():Null<IMapInterface>;
	function GetArchive():Null<IArchiveInterface>;
}

// PORT-NOTE: C# ITalkSystem.IsInArchive/IsInMap/IsInLevel 为接口默认实现，
// Haxe 接口不支持默认方法，抽出为静态辅助方法（调用处可用 `using` 还原为方法调用形式）。
class ITalkSystemHelper
{
	public static function IsInArchive(system:ITalkSystem):Bool return system.GetArchive() != null;
	public static function IsInMap(system:ITalkSystem):Bool return system.GetMap() != null;
	public static function IsInLevel(system:ITalkSystem):Bool return system.GetLevel() != null;
}
