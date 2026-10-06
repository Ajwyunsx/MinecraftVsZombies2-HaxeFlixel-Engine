// Ported from: Assets/Scripts/MVZ2/Managers/PerformanceManager.cs
package mvz2.managers;

import mvz2.options.OptionsManager;
import mvz2logic.options.FPSModes;
import mvz2logic.options.LogicOptionItemID;
import pvzengine.NamespaceID;
import unity.*;
import unity.Debug;
import mvz2.localization.LanguageManager;
import unity.scenemanagement.SceneInstance.Scene;
import unity.scenemanagement.SceneInstance;
import Main;

class PerformanceManager extends MonoBehaviour
{
	private function Awake():Void
	{
		animatorBatchData.Init();
		OptionsManager.OnOptionChangedInt.add(OnOptionChangedIntCallback);
	}
	public function Update():Void
	{
		// 帧率计算
		frameCount++;
		fpsTimer += Time.deltaTime;

		if (fpsTimer >= fpsCheckInterval)
		{
			// 计算当前FPS
			currentFPS = frameCount / fpsCheckInterval;
			frameCount = 0;
			fpsTimer = 0;

			var fpsString = Main.LanguageManager._(FPS_TEMPLATE, [currentFPS]);
			Main.Scene.SetFPS(fpsString);
		}
	}
	private function OnOptionChangedIntCallback(id:NamespaceID, value:Int):Void
	{
		if (id == LogicOptionItemID.fpsMode)
		{
			UpdateFPSMode(value);
		}
	}
	public function UpdatePerformanceMonitor():Void
	{
		if (frameCount == 0)
		{
			// 动态调整批量大小
			AdjustBatchSize();
		}
	}

	function AdjustBatchSize():Void
	{
	}
	private function UpdateFPSMode(mode:Int):Void
	{
		var fpsActive = mode != FPSModes.DISABLED;
		Main.Scene.SetFPSEnabled(fpsActive);
		if (fpsActive)
		{
			var corner = new Vector2(1, 0);
			switch (mode)
			{
				case FPSModes.TOP_LEFT:
					corner = new Vector2(0, 1);
				case FPSModes.TOP_RIGHT:
					corner = new Vector2(1, 1);
				case FPSModes.BOTTOM_LEFT:
					corner = new Vector2(0, 0);
				default:
			}
			Main.Scene.SetFPSCorner(corner);
		}
	}

	public var Main(get, never):MainManager;
	function get_Main():MainManager return MainManager.Instance;
	@:translateMsg("帧率显示")
	public static inline var FPS_TEMPLATE:String = "FPS: {0}";
	// 运行时变量
	private var fpsTimer:Float;
	private var frameCount:Float;
	private var currentFPS:Float;

	// 动态调整参数
	@:header("动态调整设置")
	@:serializeField private var fpsCheckInterval:Float = 1;    // 性能检测间隔（秒）

	@:serializeField private var animatorBatchData:PerformanceData = null;
}

class PerformanceData
{
	public var minBatchSize:Int = 40;      // 最小批量
	public var maxBatchSize:Int = 100;    // 最大批量
	public var minFPS:Float = 30;      // 最小批量
	public var maxFPS:Float = 45;    // 最大批量
	public var initialBatchSize:Int = 100; // 初始批量
	// PORT-NOTE: C# 的 [NonSerialized] 在 Haxe 中无对应语义，直接作为普通字段。
	public var currentBatchSize:Int = 100;

	public function Init():Void
	{
		currentBatchSize = initialBatchSize;
	}
	public function Adjust(currentFPS:Float):Void
	{
		var percentage = (currentFPS - minFPS) / (maxFPS - minFPS);
		currentBatchSize = Mathf.CeilToInt(Mathf.Lerp(minBatchSize, maxBatchSize, percentage));
	}
	public function new() {}
}
