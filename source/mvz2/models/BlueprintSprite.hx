// Ported from: Assets/Scripts/MVZ2/Models/Components/Pickup/BlueprintSprite.cs
package mvz2.models;

import mvz2.ui.Blueprint.BlueprintViewData;
import tmpro.TextMeshPro;
import unity.GameObject;
import unity.Mathf;
import unity.Sprite;
import unity.SpriteRenderer;
import unity.Transform;
import unity.Vector2;
import unity.Vector3;

class BlueprintSprite extends unity.MonoBehaviour {
    public function new() {
        super();
    }

    public function UpdateView(viewData:BlueprintViewData):Void {
        costText.text = viewData.cost;
        triggerCostRoot.SetActive(viewData.triggerActive);

        // Styles
        if (standaloneBackground != null) standaloneBackground.sprite = viewData.standaloneBackground;
        if (mobileBackground != null) mobileBackground.sprite = viewData.mobileBackground;
        if (mobileFrameTop != null) mobileFrameTop.sprite = viewData.mobileFrameTop;
        if (mobileFrameBottom != null) mobileFrameBottom.sprite = viewData.mobileFrameBottom;

        var icon = viewData.icon;
        iconRenderer.enabled = icon != null && !viewData.iconGrayscale;
        iconRenderer.sprite = icon;
        iconCommandBlockRenderer.enabled = icon != null && viewData.iconGrayscale;
        iconCommandBlockRenderer.sprite = icon;
        UpdateIcon();
    }
    private function UpdateIcon():Void {
        var iconSprite = iconRenderer.sprite;
        if (iconSprite == null)
            return;
        var spriteScale = new Vector2(iconSprite.rect.width / iconSpriteSize.x, iconSprite.rect.height / iconSpriteSize.y); // PORT-NOTE: C# 为 iconSprite.rect.width/height
        var iconScale:Vector3;
        if (lockAspect) {
            var maxScale = Mathf.Max(spriteScale.x, spriteScale.y);
            iconScale = Vector3.one * (1 / maxScale);
        } else {
            iconScale = new Vector3(1 / spriteScale.x, 1 / spriteScale.y, 1);
        }
        iconRoot.localScale = iconScale;
    }
    private var iconRoot:Transform = null;
    private var iconRenderer:SpriteRenderer = null;
    private var iconCommandBlockRenderer:SpriteRenderer = null;
    private var triggerCostRoot:GameObject = null;
    private var costText:TextMeshPro = null;

    private var iconSpriteSize:Vector2 = new Vector2(0, 0); // PORT-NOTE: C# Vector2 为 struct，默认 (0,0)；显式初始化避免 abstract-over-class 的 null 解引用

    // [Header("Styles (Standalone)")]
    private var standaloneBackground:SpriteRenderer = null;

    // [Header("Styles (Mobile)")]
    private var mobileBackground:SpriteRenderer = null;
    private var mobileFrameTop:SpriteRenderer = null;
    private var mobileFrameBottom:SpriteRenderer = null;

    private var lockAspect:Bool;
}
