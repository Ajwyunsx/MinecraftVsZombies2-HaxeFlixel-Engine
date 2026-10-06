// Ported from: Assets/Scripts/MVZ2/Talks/Components/TalkCharacterController.cs
package mvz2.talk;

import mvz2.managers.MainManager;
import mvz2.metas.TalkCharacterVariant;  // UNKNOWNIMPORT
import mvz2.ui.talk.TalkCharacterUI;
import pvzengine.NamespaceID;
import unity.Animator;
import unity.Mathf;
import unity.Time;
import unity.Vector2;
import unity.Vector3;
using pvzengine.entities.EngineEntityProps;  // EXTUSING

class TalkCharacterController extends unity.MonoBehaviour {
    public function new() {
        super();
    }

    // #region 公有方法
    public function SetSpeaking(value:Bool):Void {
        speaking = value;
    }
    public function SetLeaving(value:Bool):Void {
        leaving = value;
    }
    public function SetDisappear(value:Bool):Void {
        disappearing = value;
    }
    public function SetDisappearSpeed(value:Float):Void {
        disappearSpeed = value;
    }
    public function SetToTheFirstLayer():Void {
        transform.SetAsLastSibling();
    }
    public function SetToTheLastLayer():Void {
        transform.SetAsFirstSibling();
    }
    public function SetVariant(characterID:NamespaceID, variantID:NamespaceID):Void {
        var characterMeta = Main.ResourceManager.GetCharacterMeta(characterID);
        if (characterMeta == null)
            return;
        var variantMeta = variantID == null ? characterMeta.GetFirstVariant() : characterMeta.GetVariant(variantID);
        if (variantMeta == null)
            return;
        SetVariantMeta(variantMeta);
    }
    // PORT-NOTE: C# 中 SetVariant(NamespaceID, NamespaceID?) 与 SetVariant(TalkCharacterVariant) 为重载，
    // Haxe 不支持重载，第二个重载改名 SetVariantMeta。
    public function SetVariantMeta(variant:mvz2.metas.TalkCharacterVariant):Void {
        var pivot = new Vector2(variant.pivotX, variant.pivotY);
        var widthExtend = variant.widthExtend;
        var viewData = Main.TalkManager.GetPortraitViewData(variant);
        var portrait = GetOrCreatePortrait();
        portrait.ChangeVariant(viewData);
        ui.SetSprite(portrait.GetSprite());
        ui.SetPivot(pivot);
        ui.SetWidthExtend(widthExtend);
    }
    public function SetSide(side:CharacterSide, flipX:Bool):Void {
        var scale = Vector3.zero;
        switch (side) {
            case CharacterSide.Left:
                scale = new Vector3(-1, 1, 1);
            case CharacterSide.Right:
                scale = new Vector3(1, 1, 1);
            default:
        }
        ui.SetFlipX(flipX);
        ui.SetScale(scale);
    }
    public function ResetMotion():Void {
        blendValue = 0;
    }
    public function GetOrCreatePortrait():CharacterPortrait {
        if (portrait == null) {
            portrait = Main.TalkManager.CreateCharacterPortrait();
            portrait.TextureScale = textureScale;
        }
        return portrait;
    }
    public function RemovePortrait():Bool {
        if (portrait != null) {
            portrait.Dispose();
            portrait = null;
            return true;
        }
        return false;
    }
    private function OnDestroy():Void {
        RemovePortrait();
    }
    private function Update():Void {
        if (leaving) {
            blendValue = SmoothDampTo(0);
        } else if (speaking) {
            blendValue = SmoothDampTo(1);
        } else {
            blendValue = SmoothDampTo(idleBlendValue);
        }
        if (disappearing) {
            disappearBlend = Mathf.Clamp01(disappearBlend + disappearSpeed * Time.deltaTime);
        }
        _animator.SetFloat("Blend", blendValue);
        _animator.SetFloat("DisappearBlend", disappearBlend);
        if (leaving && blendValue <= 0.01 || disappearing && disappearBlend >= 1) {
            unity.UnityObject.Destroy(gameObject);
        }
    }
    // PORT-NOTE: C# 使用 Mathf.SmoothDamp(..., ref blendVelocity, ...)，
    // Haxe 以 unity.FloatRef 承接 ref 参数并回写字段。
    private function SmoothDampTo(target:Float):Float {
        var velocity:unity.FloatRef = {value: blendVelocity};
        var result = Mathf.SmoothDamp(blendValue, target, velocity, smoothTime, Math.POSITIVE_INFINITY, Time.deltaTime);
        blendVelocity = velocity.value;
        return result;
    }
    // #endregion

    // #region 属性字段
    public var Main(get, never):MainManager;
    function get_Main():MainManager return MainManager.Instance;
    private var speaking:Bool;
    private var leaving:Bool;
    private var disappearing:Bool;
    private var disappearSpeed:Float;
    private var disappearBlend:Float;
    private var blendValue:Float = 0;
    private var blendVelocity:Float;
    private var portrait:CharacterPortrait;
    private var ui:TalkCharacterUI = null;
    private var _animator:Animator = null;
    private var smoothTime:Float = 0.1;
    private var idleBlendValue:Float = 0.8;
    private var textureScale:Float = 0.7;
    // #endregion

}

enum abstract CharacterSide(Int) from Int to Int {
    var None = 0;
    var Left = 1;
    var Right = 2;
    var Self = 3;
}
