package unity.tmpro;

// Minimal TMPro.TextMeshPro shim（3D/world-space 文本，继承自 TMP_Text，与 Unity 一致）。
// PORT-NOTE: 底层复用 TextMeshProUGUI 的实现，渲染差异在 Unity 侧由 Canvas/World 空间决定，此处不区分。
class TextMeshPro extends TextMeshProUGUI {
    public function new() {
        super();
    }
}
