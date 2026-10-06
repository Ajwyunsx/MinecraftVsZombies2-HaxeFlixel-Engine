// Ported from: Assets/Scripts/MVZ2/Models/Components/Effects/CrushingWalls/CrushingWallsModel.cs
package mvz2.models;

import mvz2.managers.MainManager;

class CrushingWallsModel extends ModelComponent {
    public function new() {
        super();
    }

    override public function Init():Void {
        super.Init();
        var isMobile = MainManager.Instance.UseMobileLayout();
        standalone.gameObject.SetActive(!isMobile);
        mobile.gameObject.SetActive(isMobile);
    }
    override public function UpdateFrame(deltaTime:Float):Void {
        super.UpdateFrame(deltaTime);
        var isMobile = MainManager.Instance.UseMobileLayout();
        var platform = isMobile ? mobile : standalone;
        var camera = Model.GetCamera();
        if (camera == null)
            return;
        var progress:Float = Model.GetProperty("Progress");
        var shake:unity.Vector3 = Lawn2TransScale(Model.GetProperty("Shake"));
        platform.SetLeftPosition(camera, progress, shake);
        platform.SetRightPosition(camera, progress, shake);
    }
    private var standalone:CrushingWallsModelPlatform = null;
    private var mobile:CrushingWallsModelPlatform = null;
}
