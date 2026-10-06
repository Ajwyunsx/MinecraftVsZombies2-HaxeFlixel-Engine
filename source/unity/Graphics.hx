package unity;

// Minimal UnityEngine.Graphics shim.
class Graphics {
    public static function Blit(source:Texture, dest:RenderTexture):Void {
        // TODO-PORT: 需要 lime 的 RenderTexture 绘制管线支持。
    }
    public static function BlitWithMaterial(source:Texture, dest:RenderTexture, mat:Material):Void {
        // TODO-PORT: 需要 lime 的 RenderTexture 绘制管线支持。
    }
    public static function DrawMesh(mesh:Dynamic, position:Vector3, rotation:Quaternion):Void {}
    public static function DrawTexture(rect:Rect, texture:Texture):Void {}
}
