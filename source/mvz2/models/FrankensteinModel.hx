// Ported from: Assets/Scripts/MVZ2/Models/Components/Boss/FrankensteinModel.cs
package mvz2.models;

import mvz2.audios.SoundPlayer;
import unity.GameObject;

class FrankensteinModel extends ModelComponent {
    public function new() {
        super();
    }

    override public function Init():Void {
        super.Init();
        shellCaseParticle.OnParticleCollisionEvent.add(OnParticleCollisionCallback);
    }
    override public function OnTrigger(name:String):Void {
        super.OnTrigger(name);
        if (name == "GunFire") {
            shellCaseParticle.Emit(1);
        }
    }
    private function OnParticleCollisionCallback(player:ParticlePlayer, other:GameObject):Void {
        shellCaseSoundPlayer.Play2D();
    }
    private var shellCaseParticle:ParticlePlayer = null;
    private var shellCaseSoundPlayer:SoundPlayer = null;
}
