// Ported from: Assets/Scripts/MVZ2/Models/Components/Boss/SlendermanTentacle.cs
package mvz2.models;

import unity.Animator;

class SlendermanTentacle extends ModelComponent {
    public function new() {
        super();
    }

    override public function Init():Void {
        super.Init();
        var rng = Model.GetRNG();
        tentacleAnimator.SetFloat("Speed", rng.Next(0.8, 1.25));
    }
    private var tentacleAnimator:Animator = null;
}
