// Ported from: Assets/Scripts/MVZ2/Models/Components/Projectiles/SeijaBulletModel.cs
package mvz2.models;

import unity.GameObject;

class SeijaBulletModel extends ModelComponent {
    public function new() {
        super();
    }

    override public function UpdateFrame(deltaTime:Float):Void {
        super.UpdateFrame(deltaTime);
        var dark:Bool = Model.GetProperty("Dark");
        if (dark != isDark) {
            isDark = dark;
            normalObject.SetActive(!isDark);
            darkObject.SetActive(isDark);
        }
    }
    private var normalObject:GameObject = null;
    private var darkObject:GameObject = null;
    private var isDark:Bool = false;
}
