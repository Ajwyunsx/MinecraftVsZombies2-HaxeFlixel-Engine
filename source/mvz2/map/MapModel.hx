package mvz2.map;

import mvz2.ui.map.MapButton;
import pvzengine.NamespaceID;
import unity.Color;
import unity.MonoBehaviour;
import unity.Sprite;
import unity.Transform;
import unity.tmpro.TextMeshPro;
import flixel.util.FlxSignal.FlxTypedSignal;

// Ported from: Assets/Scripts/MVZ2/Map/MapModel.cs
class MapModel extends MonoBehaviour {
    // #region 无尽轮数
    public function SetEndlessFlagsTextActive(active:Bool):Void {
        if (endlessFlagsText == null)
            return;
        endlessFlagsText.gameObject.SetActive(active);
    }
    public function SetEndlessFlagsText(text:String):Void {
        if (endlessFlagsText == null)
            return;
        endlessFlagsText.text = text;
    }
    // #endregion

    // #region 无尽按钮
    public function GetEndlessMapButton():MapButton {
        return endlessButton;
    }
    public function SetEndlessButtonInteractable(interactable:Bool):Void {
        if (endlessButton == null)
            return;
        endlessButton.interactable = interactable;
    }
    public function SetEndlessButtonColor(color:Color):Void {
        if (endlessButton == null)
            return;
        endlessButton.SetColor(color);
    }
    public function SetEndlessButtonText(text:String):Void {
        if (endlessButton == null)
            return;
        endlessButton.SetText(text);
    }
    // #endregion

    // #region 地图按钮
    public function GetMapButtonCount():Int {
        return mapButtons.length;
    }
    public function GetMapButton(index:Int):MapButton {
        if (index < 0 || index >= mapButtons.length)
            return null;
        return mapButtons[index];
    }
    public function SetMapButtonInteractable(index:Int, interactable:Bool):Void {
        var button = GetMapButton(index);
        if (button == null)
            return;
        button.interactable = interactable;
    }
    public function SetMapButtonColor(index:Int, color:Color):Void {
        var button = GetMapButton(index);
        if (button == null)
            return;
        button.SetColor(color);
    }
    public function SetMapButtonText(index:Int, text:String):Void {
        var button = GetMapButton(index);
        if (button == null)
            return;
        button.SetText(text);
    }
    public function SetMapButtonBorder(index:Int, back:Sprite, bottom:Sprite, overlay:Sprite):Void {
        var button = GetMapButton(index);
        if (button == null)
            return;
        button.SetBorderSprite(back, bottom, overlay);
    }
    public function SetMapButtonBorderToDefault(index:Int):Void {
        var button = GetMapButton(index);
        if (button == null)
            return;
        button.SetBorderSpriteToDefault();
    }
    // #endregion


    // #region 地图元素
    public function GetMapElement(id:NamespaceID):MapElement {
        return Lambda.find(mapElements, e -> (e.definitionID != null ? e.definitionID.Get() : null) == id);
    }
    public function GetMapElements():Array<MapElement> {
        return mapElements;
    }
    // #endregion

    private function Awake():Void {
        for (button in mapButtons) {
            var index = mapButtons.indexOf(button);
            button.OnClick.add(() -> {
                if (OnMapButtonClick != null) OnMapButtonClick.dispatch(index);
            });
        }
        if (endlessButton != null) {
            endlessButton.OnClick.add(() -> {
                if (OnEndlessButtonClick != null) OnEndlessButtonClick.dispatch();
            });
        }
        mapElements = elementRoot.GetComponentsInChildren(MapElement);
    }
    public var OnMapButtonClick:FlxTypedSignal<Int->Void> = new FlxTypedSignal();
    public var OnEndlessButtonClick:FlxTypedSignal<Void->Void> = new FlxTypedSignal();
    @:serializeField
    private var endlessFlagsText:TextMeshPro = null;
    @:serializeField
    private var elementRoot:Transform = null;
    @:serializeField
    private var endlessButton:MapButton = null;
    @:serializeField
    private var mapButtons:Array<MapButton> = null;
    private var mapElements:Array<MapElement> = null;
}
