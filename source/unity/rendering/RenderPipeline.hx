// Ported from: Assets/Scripts/View/Rendering/RenderPipeline.cs（最小 shim，供 ModelManager 使用）
package unity.rendering;

import unity.Camera;
import unity.RenderTexture;

// PORT-NOTE: Unity 6 的 RenderPipeline.StandardRequest 在 Haxe 侧仅保留数据与空实现，
// 实际渲染由 Flixel/lime 渲染层接管。
class RenderPipeline {
    public static var request:StandardRequest = new StandardRequest();

    public static function SupportsRenderRequest(camera:Camera, request:StandardRequest):Bool {
        return false;
    }
    public static function SubmitRenderRequest(camera:Camera, request:StandardRequest):Void {
        camera.Render();
    }
}

class StandardRequest {
    public var destination:RenderTexture;

    public function new() {}
}
