// Ported from: Assets/Scripts/Logic/Talk/ITalkSystem.cs
package mvz2logic.talk;

import pvzengine.NamespaceID;

interface ITalkController
{
	function StartTalk(id:NamespaceID, section:Int, delay:Float = 1, ?onEnd:Void->Void):Void;
	function WillSkipTalk(id:NamespaceID, section:Int):Bool;
	function AutoSkipTalks(id:NamespaceID, section:Int, ?onSkipped:Void->Void):Void;
}

// PORT-NOTE: C# ITalkController.SimpleStartTalk 为接口默认实现，Haxe 接口不支持默认方法，
// 抽出为静态辅助方法（调用处可用 `using` 还原为方法调用形式）。
class ITalkControllerHelper
{
	public static function SimpleStartTalk(controller:ITalkController, groupId:NamespaceID, section:Int, delay:Float = 0, ?onSkipped:Void->Void, ?onStarted:Void->Void, ?onEnd:Void->Void):Void
	{
		if (controller.WillSkipTalk(groupId, section))
		{
			controller.AutoSkipTalks(groupId, section, function() {
				if (onSkipped != null) onSkipped();
				if (onEnd != null) onEnd();
			});
		}
		else
		{
			controller.StartTalk(groupId, section, delay, onEnd);
			if (onStarted != null) onStarted();
		}
	}
}
