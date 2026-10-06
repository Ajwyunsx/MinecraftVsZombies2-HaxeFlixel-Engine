// Ported from: Assets/Scripts/MVZ2/Talks/TalkManager.cs
package mvz2.managers;

import mvz2.metas.TalkCharacterVariant;
import mvz2.talk.CharacterPortrait;
import mvz2.talk.CharacterPortraitComponent;
// PORT-NOTE: CharacterPortraitLayerViewData 属于 CharacterPortraitComponentLayer 模块（次类型）。
import mvz2.talk.CharacterPortraitComponentLayer.CharacterPortraitLayerViewData;
import mvz2.talk.CharacterPortraitComponent.CharacterPortraitViewData;
import unity.Transform;
import unity.Vector2;
import unity.MonoBehaviour;
import unity.UnityObject;
import Main;

class TalkManager extends unity.MonoBehaviour {
    public function new() {
        super();
    }

    public function GetPortraitViewData(variant:TalkCharacterVariant):CharacterPortraitViewData {
        var layers = new Array<CharacterPortraitLayerViewData>();
        layers.resize(variant.layers.length);

        for (i in 0...layers.length) {
            var layer = variant.layers[i];
            var sprite = Main.GetFinalSpriteFromRef(layer.sprite);
            var layerData = new CharacterPortraitLayerViewData();
            layerData.position = new Vector2(layer.positionX, variant.height - layer.positionY);
            layerData.sprite = sprite;
            layers[i] = layerData;
        }
        var viewData = new CharacterPortraitViewData();
        viewData.width = variant.width;
        viewData.height = variant.height;
        viewData.layers = layers;
        return viewData;
    }
    public function CreateCharacterPortrait():CharacterPortrait {
        var component = CreateComponent();
        return new CharacterPortrait(component);
    }
    // PORT-NOTE: C# 中 CreateCharacterPortrait() 与 CreateCharacterPortrait(TalkCharacterVariant) 为重载，
    // Haxe 不支持重载，带参数版本改名 CreateCharacterPortraitWithVariant。
    public function CreateCharacterPortraitWithVariant(variant:TalkCharacterVariant):CharacterPortrait {
        var portrait = CreateCharacterPortrait();
        portrait.ChangeVariant(GetPortraitViewData(variant));
        return portrait;
    }
    public function CreateComponent():CharacterPortraitComponent {
        // PORT-NOTE: 原 C# 为 Instantiate(portraitPrefab, portraitRoot)；unity 的 Instantiate
        // shim 只支持位置/旋转，故实例化后显式设置父节点。
        var comp:CharacterPortraitComponent = cast unity.UnityObject.Instantiate(portraitPrefab);
        comp.transform.SetParent(portraitRoot, false);
        comp.gameObject.SetActive(true);
        return comp;
    }
    public var Main(get, never):MainManager;
    function get_Main():MainManager return MainManager.Instance;
    public var portraitRoot:Transform = null;
    public var portraitPrefab:CharacterPortraitComponent = null;
}
