// Ported from: Assets/Scripts/MVZ2/Models/Components/Pickup/BlueprintPickupSetter.cs
package mvz2.models;

import mvz2.managers.MainManager;
import pvzengine.NamespaceID;
import unity.GameObject;

class BlueprintPickupSetter extends ModelComponent {
    public function new() {
        super();
    }

    override public function Init():Void {
        super.Init();
        UpdateBlueprint();
    }
    override public function UpdateFrame(deltaTime:Float):Void {
        super.UpdateFrame(deltaTime);
        UpdateBlueprint();
    }
    private function UpdateBlueprint():Void {
        var main = MainManager.Instance;
        var resourceManager = main.ResourceManager;
        var isMobile = main.UseMobileLayout();
        var blueprintID:NamespaceID = Model.GetProperty("ContentID");
        var commandBlock:Bool = Model.GetProperty("CommandBlock");
        if (lastID != blueprintID || lastCommandBlock != commandBlock) {
            lastID = blueprintID;
            lastCommandBlock = commandBlock;
            // PORT-NOTE: 按 ID 取视图数据的重载在移植层改名为 GetBlueprintViewDataFromID。
            var viewData = resourceManager.GetBlueprintViewDataFromID(blueprintID, false, commandBlock);
            var blueprintSprite = isMobile ? blueprintSpriteMobile : blueprintSpriteStandalone;
            blueprintSprite.UpdateView(viewData);
        }
        blueprintSpriteStandalone.gameObject.SetActive(!isMobile);
        blueprintSpriteMobile.gameObject.SetActive(isMobile);
        colliderStandalone.SetActive(!isMobile);
        colliderMobile.SetActive(isMobile);
    }
    private var colliderStandalone:GameObject = null;
    private var colliderMobile:GameObject = null;
    private var blueprintSpriteStandalone:BlueprintSprite = null;
    private var blueprintSpriteMobile:BlueprintSprite = null;
    private var lastID:NamespaceID;
    private var lastCommandBlock:Bool;
}
