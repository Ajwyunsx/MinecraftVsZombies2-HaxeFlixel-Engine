// Ported from: Assets/Scripts/MVZ2/Level/CameraLimiter.cs
package mvz2.level;

import mvz2.cameras.ResolutionManager;
import mvz2.managers.MainManager;
import mvz2.options.OptionsManager;
import mvz2logic.options.LogicOptionItemID;
import pvzengine.NamespaceID;
import unity.*;
import unity.Debug;

// PORT-NOTE: C# 的 [DefaultExecutionOrder(1)] 特性在 Haxe 中无对应语义，改为元数据保留。
@:defaultExecutionOrder(1)
class CameraLimiter extends MonoBehaviour
{
	public function UpdateCamera():Void
	{
		UpdateCameraWithSize(Screen.width, Screen.height);
	}
	// TODO-PORT: C# 重载 UpdateCamera(int width, int height)，重命名以区分。
	public function UpdateCameraWithSize(width:Int, height:Int):Void
	{
		if (_camera == null)
			return;
		var isMobile = MainManager.Instance.UseMobileLayout();
		var min = isMobile ? safeAspectMinMobile : safeAspectMin;
		var max = isMobile ? safeAspectMaxMobile : safeAspectMax;
		var currentAspect = width / height;
		var rectSize = new Vector2(1, 1);
		if (min > 0 && currentAspect < min)
		{
			rectSize = new Vector2(1, 1 / (min / currentAspect));
		}
		else if (max > 0 && currentAspect > max)
		{
			rectSize = new Vector2(max / currentAspect, 1);
		}
		var rect = _camera.rect;
		rect.size = rectSize;
		rect.center = new Vector2(0.5, 0.5);
		_camera.rect = rect;
	}
	private function OnEnable():Void
	{
		ResolutionManager.OnResolutionChanged.add(OnResolutionChangedCallback);
		OptionsManager.OnOptionChangedInt.add(OnOptionChangedIntCallback);
		UpdateCamera();
	}
	private function OnDisable():Void
	{
		ResolutionManager.OnResolutionChanged.remove(OnResolutionChangedCallback);
		OptionsManager.OnOptionChangedInt.remove(OnOptionChangedIntCallback);
	}
	private function OnResolutionChangedCallback(width:Int, height:Int):Void
	{
		UpdateCameraWithSize(width, height);
	}
	private function OnOptionChangedIntCallback(option:NamespaceID, value:Int):Void
	{
		if (option == LogicOptionItemID.screenLayout)
		{
			UpdateCamera();
		}
	}

	@:serializeField
	private var safeAspectMin:Float = -1;
	@:serializeField
	private var safeAspectMax:Float = -1;
	@:serializeField
	private var safeAspectMinMobile:Float = 1.7;
	@:serializeField
	private var safeAspectMaxMobile:Float = 1.7;
	@:serializeField
	private var _camera:Camera = null;
}
