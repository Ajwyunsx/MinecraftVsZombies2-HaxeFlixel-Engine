// Ported from: Assets/Scripts/MVZ2/Managers/GraphicsManager.cs
package mvz2.models;

import haxe.ds.GenericStack;
import unity.Application;  // UNKNOWNIMPORT
import unity.Color;  // UNKNOWNIMPORT
import unity.MonoBehaviour;  // UNKNOWNIMPORT
import unity.Shader;  // UNKNOWNIMPORT
import unity.TextureFormat;  // UNKNOWNIMPORT
import mvz2.managers.MainManager;
import mvz2.options.OptionsManager;
import mvz2logic.options.LogicOptionItemID;
import pvzengine.NamespaceID;
import unity.*;
import unity.Debug;

class GraphicsManager extends MonoBehaviour
{
	public function Init():Void
	{
		LogGraphics();
		CheckSupportedColorFormat();
		CheckSupportedDepthFormat();
		// Flixel 渲染桥不使用 Unity 全局 shader 属性；避免图形上下文初始化期间
		// 进入仅为 Unity 保留的全局 shader 路径。
		if (false) {
			Shader.SetGlobalInt("_LightStarted", 1);
			ResetLighting();
		}
	}
	// PORT-NOTE: C# 中 `#if UNITY_EDITOR [InitializeOnLoadMethod] ... #endif` 的编辑器初始化代码
	// （ResetLightingStatic / EditorApplication.playModeStateChanged）不适用于本移植工程，未移植。
	private static function SetLightingStatic(background:Color, backgroundTint:Color, global:Color):Void
	{
		Shader.SetGlobalColor("_LightBackground", background);
		Shader.SetGlobalColor("_BackgroundTint", backgroundTint);
		Shader.SetGlobalColor("_LightGlobal", global);
	}
	private static function ResetLightingStatic():Void
	{
		SetLightingStatic(Color.white, Color.white, Color.white);
	}
	public function SetLighting(background:Color, backgroundTint:Color, global:Color):Void
	{
		SetLightingStatic(background, backgroundTint, global);
	}
	public function ResetLighting():Void
	{
		ResetLightingStatic();
	}
	public function GetSupportedColorFormat():GraphicsFormat
	{
		if (confirmedColorFormat)
		{
			return supportedColorFormat;
		}
		return CheckSupportedColorFormat();
	}
	public function GetSupportedDepthFormat():GraphicsFormat
	{
		if (confirmedDepthFormat)
		{
			return supportedDepthFormat;
		}
		return CheckSupportedDepthFormat();
	}
	private function CheckSupportedColorFormat():GraphicsFormat
	{
		Debug.Log("Checking supported color formats...");
		var format = SystemInfo.GetGraphicsFormat(DefaultFormat.LDR);
		if (!SystemInfo.IsFormatSupported(format, FormatUsage.Render))
		{
			Debug.LogWarning("Cannot find a supported color format for device, using default color format.");
			return GraphicsFormat.R8G8B8A8_SRGB;
		}
		else
		{
			Debug.Log('Found supported color format $format.');
			confirmedColorFormat = true;
			supportedColorFormat = format;
			return format;
		}
	}
	private function CheckSupportedDepthFormat():GraphicsFormat
	{
		Debug.Log("Checking supported depth formats...");
		var format = SystemInfo.GetGraphicsFormat(DefaultFormat.DepthStencil);
		if (!SystemInfo.IsFormatSupported(format, FormatUsage.Render))
		{
			Debug.LogWarning("Cannot find a supported depth format for device, using default depth format.");
			return GraphicsFormat.None;
		}
		else
		{
			Debug.Log('Found supported depth format $format.');
			confirmedDepthFormat = true;
			supportedDepthFormat = format;
			return format;
		}
	}
	private function LogGraphics():Void
	{
		var sb = new StringBuf();

		sb.add('Quality: ${QualitySettings.names[QualitySettings.GetQualityLevel()]}\n');

		sb.add("系统信息：\n");
		sb.add('deviceModel: ${SystemInfo.deviceModel}\n');
		sb.add('deviceType: ${SystemInfo.deviceType}\n');
		sb.add('operatingSystem: ${SystemInfo.operatingSystem}\n');
		sb.add('operatingSystemFamily: ${SystemInfo.operatingSystemFamily}\n');
		sb.add('processorCount: ${SystemInfo.processorCount}\n');
		sb.add('processorFrequency: ${SystemInfo.processorFrequency}\n');
		sb.add('processorType: ${SystemInfo.processorType}\n');
		sb.add('supportsAccelerometer: ${SystemInfo.supportsAccelerometer}\n');
		sb.add('supportsAudio: ${SystemInfo.supportsAudio}\n');
		sb.add('supportsGyroscope: ${SystemInfo.supportsGyroscope}\n');
		sb.add('supportsLocationService: ${SystemInfo.supportsLocationService}\n');
		sb.add('supportsVibration: ${SystemInfo.supportsVibration}\n');
		sb.add('systemMemorySize: ${SystemInfo.systemMemorySize}\n');

		sb.add("\n");
		sb.add("显示设备信息：\n");
		sb.add('graphicsDeviceID: ${SystemInfo.graphicsDeviceID}\n');
		sb.add('graphicsDeviceName: ${SystemInfo.graphicsDeviceName}\n');
		sb.add('graphicsDeviceType: ${SystemInfo.graphicsDeviceType}\n');
		sb.add('graphicsDeviceVendor: ${SystemInfo.graphicsDeviceVendor}\n');
		sb.add('graphicsDeviceVendorID: ${SystemInfo.graphicsDeviceVendorID}\n');
		sb.add('graphicsDeviceVersion: ${SystemInfo.graphicsDeviceVersion}\n');
		sb.add('graphicsMemorySize: ${SystemInfo.graphicsMemorySize}\n');
		sb.add('graphicsMultiThreaded: ${SystemInfo.graphicsMultiThreaded}\n');
		sb.add('graphicsShaderLevel: ${SystemInfo.graphicsShaderLevel}\n');
		sb.add('graphicsUVStartsAtTop: ${SystemInfo.graphicsUVStartsAtTop}\n');
		sb.add('maxGraphicsBufferSize: ${SystemInfo.maxGraphicsBufferSize}\n');
		sb.add('supportsGraphicsFence: ${SystemInfo.supportsGraphicsFence}\n');
		sb.add('renderingThreadingMode: ${SystemInfo.renderingThreadingMode}\n');
		sb.add('hasHiddenSurfaceRemovalOnGPU: ${SystemInfo.hasHiddenSurfaceRemovalOnGPU}\n');
		sb.add('hasDynamicUniformArrayIndexingInFragmentShaders: ${SystemInfo.hasDynamicUniformArrayIndexingInFragmentShaders}\n');
		sb.add('supportsShadows: ${SystemInfo.supportsShadows}\n');
		sb.add('supportsRawShadowDepthSampling: ${SystemInfo.supportsRawShadowDepthSampling}\n');
		sb.add('supportsMotionVectors: ${SystemInfo.supportsMotionVectors}\n');
		sb.add('supports3DTextures: ${SystemInfo.supports3DTextures}\n');
		sb.add('supports2DArrayTextures: ${SystemInfo.supports2DArrayTextures}\n');
		sb.add('supports3DRenderTextures: ${SystemInfo.supports3DRenderTextures}\n');
		sb.add('supportsCubemapArrayTextures: ${SystemInfo.supportsCubemapArrayTextures}\n');
		sb.add('copyTextureSupport: ${SystemInfo.copyTextureSupport}\n');
		sb.add('supportsComputeShaders: ${SystemInfo.supportsComputeShaders}\n');
		sb.add('renderingThreadingMode: ${SystemInfo.renderingThreadingMode}\n');
		sb.add('supportsGeometryShaders: ${SystemInfo.supportsGeometryShaders}\n');
		sb.add('supportsTessellationShaders: ${SystemInfo.supportsTessellationShaders}\n');
		sb.add('supportsInstancing: ${SystemInfo.supportsInstancing}\n');
		sb.add('supportsHardwareQuadTopology: ${SystemInfo.supportsHardwareQuadTopology}\n');
		sb.add('supports32bitsIndexBuffer: ${SystemInfo.supports32bitsIndexBuffer}\n');
		sb.add('supportsSparseTextures: ${SystemInfo.supportsSparseTextures}\n');
		sb.add('supportedRenderTargetCount: ${SystemInfo.supportedRenderTargetCount}\n');
		sb.add('supportsSeparatedRenderTargetsBlend: ${SystemInfo.supportsSeparatedRenderTargetsBlend}\n');
		sb.add('supportedRandomWriteTargetCount: ${SystemInfo.supportedRandomWriteTargetCount}\n');
		sb.add('supportsMultisampledTextures: ${SystemInfo.supportsMultisampledTextures}\n');
		sb.add('supportsMultisampleAutoResolve: ${SystemInfo.supportsMultisampleAutoResolve}\n');
		sb.add('supportsTextureWrapMirrorOnce: ${SystemInfo.supportsTextureWrapMirrorOnce}\n');
		sb.add('usesReversedZBuffer: ${SystemInfo.usesReversedZBuffer}\n');
		sb.add('npotSupport: ${SystemInfo.npotSupport}\n');
		sb.add('maxTextureSize: ${SystemInfo.maxTextureSize}\n');
		sb.add('maxCubemapSize: ${SystemInfo.maxCubemapSize}\n');
		sb.add('maxComputeBufferInputsVertex: ${SystemInfo.maxComputeBufferInputsVertex}\n');
		sb.add('maxComputeBufferInputsFragment: ${SystemInfo.maxComputeBufferInputsFragment}\n');
		sb.add('maxComputeBufferInputsGeometry: ${SystemInfo.maxComputeBufferInputsGeometry}\n');
		sb.add('maxComputeBufferInputsDomain: ${SystemInfo.maxComputeBufferInputsDomain}\n');
		sb.add('maxComputeBufferInputsHull: ${SystemInfo.maxComputeBufferInputsHull}\n');
		sb.add('maxComputeBufferInputsCompute: ${SystemInfo.maxComputeBufferInputsCompute}\n');
		sb.add('maxComputeWorkGroupSize: ${SystemInfo.maxComputeWorkGroupSize}\n');
		sb.add('maxComputeWorkGroupSizeX: ${SystemInfo.maxComputeWorkGroupSizeX}\n');
		sb.add('maxComputeWorkGroupSizeY: ${SystemInfo.maxComputeWorkGroupSizeY}\n');
		sb.add('maxComputeWorkGroupSizeZ: ${SystemInfo.maxComputeWorkGroupSizeZ}\n');
		sb.add('supportsAsyncCompute: ${SystemInfo.supportsAsyncCompute}\n');
		sb.add('supportsGraphicsFence: ${SystemInfo.supportsGraphicsFence}\n');
		sb.add('supportsAsyncGPUReadback: ${SystemInfo.supportsAsyncGPUReadback}\n');
		sb.add('supportsRayTracing: ${SystemInfo.supportsRayTracing}\n');
		sb.add('supportsSetConstantBuffer: ${SystemInfo.supportsSetConstantBuffer}\n');
		sb.add('minConstantBufferOffsetAlignment: ${SystemInfo.constantBufferOffsetAlignment}\n');
		sb.add('hasMipMaxLevel: ${SystemInfo.hasMipMaxLevel}\n');
		sb.add('supportsMipStreaming: ${SystemInfo.supportsMipStreaming}\n');
		sb.add('usesLoadStoreActions: ${SystemInfo.usesLoadStoreActions}\n');

		sb.add('supportedTextureFormats: ');
		for (format in TextureFormat.values())
		{
			if (!IsValidEnumValue(format))
				continue;
			if (SystemInfo.SupportsTextureFormat(format))
			{
				sb.add('$format,');
			}
		}
		sb.add("\n");
		sb.add('supportedRenderTextureFormats: ');
		for (format in RenderTextureFormat.values())
		{
			if (!IsValidEnumValue(format))
				continue;
			if (SystemInfo.SupportsRenderTextureFormat(format))
			{
				sb.add('$format,');
			}
		}
		sb.add("\n");
		sb.add('supportedGraphicsFormats: ');
		for (format in GraphicsFormat.values())
		{
			if (!IsValidEnumValue(format))
				continue;
			if (SystemInfo.IsFormatSupported(format, FormatUsage.Render))
			{
				sb.add('$format,');
			}
		}
		sb.add("\n");
		Debug.Log(sb.toString());
	}
	// PORT-NOTE: C# 通过反射检查枚举值是否标记了 [Obsolete]。
	// Haxe 枚举/枚举抽象无等价运行期反射，改为检查静态标记表。
	// TODO-PORT: 反射检查 [Obsolete] 特性无等价实现。
	private function IsValidEnumValue(value:Dynamic):Bool
	{
		return true;
	}
	private function Awake():Void
	{
		OptionsManager.OnOptionChangedBool.add(OnOptionChangedBoolCallback);
		OptionsManager.OnOptionChangedInt.add(OnOptionChangedIntCallback);
	}
	private function OnOptionChangedBoolCallback(id:NamespaceID, value:Bool):Void
	{
		if (id == LogicOptionItemID.hdrLighting)
		{
			Shader.SetGlobalInt("_HDRDisabled", value ? 0 : 1);
		}
		else if (id == LogicOptionItemID.vSync)
		{
			QualitySettings.vSyncCount = value ? 1 : 0;
		}
	}
	private function OnOptionChangedIntCallback(id:NamespaceID, value:Int):Void
	{
		if (id == LogicOptionItemID.targetFramerate)
		{
			Application.targetFrameRate = value;
		}
	}
	public var Main(get, never):MainManager;
	function get_Main():MainManager return main;
	private var confirmedColorFormat:Bool = false;
	private var supportedColorFormat:GraphicsFormat = GraphicsFormat.R8G8B8A8_SRGB;
	private var confirmedDepthFormat:Bool = false;
	private var supportedDepthFormat:GraphicsFormat = GraphicsFormat.D32_SFloat_S8_UInt;
	@:serializeField
	private var main:MainManager = null;
}
