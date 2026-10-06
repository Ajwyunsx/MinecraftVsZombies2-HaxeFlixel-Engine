// Ported from: Assets/Scripts/MVZ2/Models/Components/Carts/CartChargeBarModel.cs
package mvz2.models;

import unity.GameObject;
import unity.Gradient;
import unity.Mathf;
import unity.SpriteRenderer;

class CartChargeBarModel extends ModelComponent {
    public function new() {
        super();
    }

    override public function UpdateFrame(deltaTime:Float):Void {
        super.UpdateFrame(deltaTime);
        var charge:Float = Mathf.Clamp01(Model.GetProperty("Charge"));
        chargeBarRoot.SetActive(charge > 0);
        circleSetter.fill = charge;
        chargeBarRenderer.color = barGradient.Evaluate(charge);
    }
    private var chargeBarRoot:GameObject = null;
    private var chargeBarRenderer:SpriteRenderer = null;
    private var circleSetter:CircleFillSpriteSetter = null;
    private var barGradient:Gradient = null;
}
