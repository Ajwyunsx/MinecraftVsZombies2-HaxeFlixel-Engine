// Ported from: Assets/Scripts/MVZ2/Models/Components/Effects/FragmentColorSetter.cs
package mvz2.models;

import mvz2.managers.MainManager;
import unity.ParticleSystemGradientMode;  // UNKNOWNIMPORT
import unity.Gradient.GradientColorKey;  // SUBIMPORT
import unity.Gradient.GradientMode;  // SUBIMPORT
import unity.ParticleSystem.MinMaxGradient;  // SUBIMPORT
import pvzengine.NamespaceID;
import unity.Color;
import unity.Gradient;
import unity.ParticleSystem;

class FragmentColorSetter extends ModelComponent {
    public function new() {
        super();
    }

    override public function UpdateFrame(deltaTime:Float):Void {
        super.UpdateFrame(deltaTime);
        var fragID:NamespaceID = Model.GetProperty("FragmentID");
        if (lastID != fragID) {
            lastID = fragID;
            var main = particles.Particles.main;
            var gradient = defaultGradient;
            if (fragID != null) {
                var resourceManager = MainManager.Instance.ResourceManager;
                var fragGradient = resourceManager.GetFragmentGradient(fragID);
                gradient = fragGradient != null ? fragGradient : defaultGradient;
            }
            var minMax = new MinMaxGradient();
            minMax.mode = ParticleSystemGradientMode.RandomColor;
            minMax.gradient = gradient;
            main.startColor = minMax;
        }
    }
    public static var defaultGradient:Gradient = createDefaultGradient();

    static function createDefaultGradient():Gradient {
        var gradient = new Gradient();
        gradient.mode = GradientMode.Fixed;
        gradient.colorKeys = [
            new GradientColorKey(unity.Color.magenta, 0.5),
            new GradientColorKey(unity.Color.black, 1)
        ];
        return gradient;
    }
    private var particles:ParticlePlayer = null;
    private var lastID:NamespaceID;
}
