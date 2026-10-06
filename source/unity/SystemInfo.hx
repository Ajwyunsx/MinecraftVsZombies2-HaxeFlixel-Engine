package unity;

import unity.TextureFormat;

// Minimal UnityEngine.SystemInfo shim.
// PORT-NOTE: 引擎不会提供真实的设备信息，这里返回一组稳定的伪值，仅用于日志输出；
// 图形格式相关查询按“全部支持”处理，保证 GraphicsManager 走正常分支。
// 说明：DeviceType / OperatingSystemFamily / GraphicsDeviceType / CopyTextureSupport /
// RenderingThreadingMode / NPOTSupport 在 Unity 中是 UnityEngine 顶层枚举，
// 本移植层只被 SystemInfo 使用，故作为本模块的次类型实现。
class SystemInfo {
	public static var deviceModel:String = "HaxeFlixel Device";
	public static var deviceType:DeviceType = DeviceType.Desktop;
	public static var operatingSystem:String = "Windows";
	public static var operatingSystemFamily:OperatingSystemFamily = OperatingSystemFamily.Windows;
	public static var processorCount:Int = 4;
	public static var processorFrequency:Int = 2400;
	public static var processorType:String = "Generic CPU";
	public static var supportsAccelerometer:Bool = false;
	public static var supportsAudio:Bool = true;
	public static var supportsGyroscope:Bool = false;
	public static var supportsLocationService:Bool = false;
	public static var supportsVibration:Bool = false;
	public static var systemMemorySize:Int = 4096;

	public static var graphicsDeviceID:Int = 0;
	public static var graphicsDeviceName:String = "HaxeFlixel Renderer";
	public static var graphicsDeviceType:GraphicsDeviceType = GraphicsDeviceType.OpenGL;
	public static var graphicsDeviceVendor:String = "HaxeFlixel";
	public static var graphicsDeviceVendorID:Int = 0;
	public static var graphicsDeviceVersion:String = "OpenGL 3.0";
	public static var graphicsMemorySize:Int = 2048;
	public static var graphicsMultiThreaded:Bool = false;
	public static var graphicsShaderLevel:Int = 50;
	public static var graphicsUVStartsAtTop:Bool = false;
	public static var maxGraphicsBufferSize:Int = 0;
	public static var supportsGraphicsFence:Bool = false;
	public static var renderingThreadingMode:RenderingThreadingMode = RenderingThreadingMode.SingleThreaded;
	public static var hasHiddenSurfaceRemovalOnGPU:Bool = false;
	public static var hasDynamicUniformArrayIndexingInFragmentShaders:Bool = true;
	public static var supportsShadows:Bool = false;
	public static var supportsRawShadowDepthSampling:Bool = false;
	public static var supportsMotionVectors:Bool = false;
	public static var supports3DTextures:Bool = true;
	public static var supports2DArrayTextures:Bool = true;
	public static var supports3DRenderTextures:Bool = false;
	public static var supportsCubemapArrayTextures:Bool = false;
	public static var copyTextureSupport:CopyTextureSupport = CopyTextureSupport.None;
	public static var supportsComputeShaders:Bool = false;
	public static var supportsGeometryShaders:Bool = false;
	public static var supportsTessellationShaders:Bool = false;
	public static var supportsInstancing:Bool = false;
	public static var supportsHardwareQuadTopology:Bool = false;
	public static var supports32bitsIndexBuffer:Bool = false;
	public static var supportsSparseTextures:Bool = false;
	public static var supportedRenderTargetCount:Int = 1;
	public static var supportsSeparatedRenderTargetsBlend:Bool = false;
	public static var supportedRandomWriteTargetCount:Int = 0;
	public static var supportsMultisampledTextures:Bool = false;
	public static var supportsMultisampleAutoResolve:Bool = false;
	public static var supportsTextureWrapMirrorOnce:Bool = false;
	public static var usesReversedZBuffer:Bool = false;
	public static var npotSupport:NPOTSupport = NPOTSupport.Full;
	public static var maxTextureSize:Int = 8192;
	public static var maxCubemapSize:Int = 8192;
	public static var maxComputeBufferInputsVertex:Int = 0;
	public static var maxComputeBufferInputsFragment:Int = 0;
	public static var maxComputeBufferInputsGeometry:Int = 0;
	public static var maxComputeBufferInputsDomain:Int = 0;
	public static var maxComputeBufferInputsHull:Int = 0;
	public static var maxComputeBufferInputsCompute:Int = 0;
	public static var maxComputeWorkGroupSize:Int = 0;
	public static var maxComputeWorkGroupSizeX:Int = 0;
	public static var maxComputeWorkGroupSizeY:Int = 0;
	public static var maxComputeWorkGroupSizeZ:Int = 0;
	public static var supportsAsyncCompute:Bool = false;
	public static var supportsAsyncGPUReadback:Bool = false;
	public static var supportsRayTracing:Bool = false;
	public static var supportsSetConstantBuffer:Bool = false;
	public static var constantBufferOffsetAlignment:Int = 0;
	public static var hasMipMaxLevel:Bool = false;
	public static var supportsMipStreaming:Bool = false;
	public static var usesLoadStoreActions:Bool = false;

	public static function GetGraphicsFormat(format:DefaultFormat):GraphicsFormat {
		return format == DefaultFormat.DepthStencil ? GraphicsFormat.D32_SFloat_S8_UInt : GraphicsFormat.R8G8B8A8_SRGB;
	}
	public static function IsFormatSupported(format:GraphicsFormat, usage:FormatUsage):Bool {
		return format != GraphicsFormat.None;
	}
	public static function SupportsTextureFormat(format:TextureFormat):Bool {
		return true;
	}
	public static function SupportsRenderTextureFormat(format:RenderTextureFormat):Bool {
		return true;
	}
}

enum abstract DeviceType(Int) {
	var Unknown = 0;
	var Handheld = 1;
	var Console = 2;
	var Desktop = 3;
}

enum abstract OperatingSystemFamily(Int) {
	var Other = 0;
	var MacOSX = 1;
	var Windows = 2;
	var Linux = 3;
}

enum abstract GraphicsDeviceType(Int) {
	var OpenGL = 0;
	var Direct3D11 = 1;
	var Direct3D12 = 2;
	var Vulkan = 3;
	var Metal = 4;
	var Null = 5;
}

enum abstract CopyTextureSupport(Int) {
	var None = 0;
	var Basic = 1;
	var Copy3D = 2;
	var DifferentTypes = 4;
	var TextureToRT = 8;
	var RTToTexture = 16;
}

enum abstract RenderingThreadingMode(Int) {
	var Direct = 0;
	var SingleThreaded = 1;
	var MultiThreaded = 2;
	var LegacyJobSystem = 3;
	var NativeJobSystem = 4;
}

enum abstract NPOTSupport(Int) {
	var None = 0;
	var Restricted = 1;
	var Full = 2;
}
