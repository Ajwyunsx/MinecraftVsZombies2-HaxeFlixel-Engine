// Ported from: Assets/Scripts/Vanilla/GameContent/Artifacts/Chapter6/CenserOfForgotten.cs
package mvz2.gamecontent.artifacts;

import mvz2.gamecontent.artifacts.VanillaArtifactID.VanillaArtifactNames;
import mvz2.vanilla.audios.VanillaSoundID;
import mvz2logic.artifacts.Artifact;
import mvz2logic.artifacts.ArtifactDefinition;
import pvzengine.entities.EntityTypes;
import pvzengine.level.LevelEngine;
import tools.Ticks;
import tools.TimerHelper;
using mvz2logic.artifacts.LogicArtifactProps;
using mvz2logic.entities.LogicEntityExt;
using mvz2logic.level.LogicLevelExt;
using mvz2logic.level.LogicLevelProps;
using mvz2.vanilla.entities.VanillaEntityExt;
using mvz2.vanilla.entities.VanillaEntityProps;

@:autoArtifactDefinition(VanillaArtifactNames.censerOfForgotten)
class CenserOfForgotten extends ArtifactDefinition
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
    }
    public override function PostAdd(artifact:Artifact):Void
    {
        super.PostAdd(artifact);
        artifact.SetNumber(MAX_COOLDOWN_SECONDS);
        artifact.SetSecondTimer(TimerHelper.NewSecondTimer(1));
    }
    public override function PostUpdate(artifact:Artifact):Void
    {
        super.PostUpdate(artifact);
        if (artifact.Level.IsAllEnemiesCleared() || artifact.Level.IsCleared)
            return;

        var secondTimer = artifact.GetSecondTimer();
        if (secondTimer == null)
        {
            secondTimer = TimerHelper.NewSecondTimer(1);
            artifact.SetSecondTimer(secondTimer);
        }

        if (secondTimer.RunToExpired())
        {
            var number = artifact.GetNumber();
            number--;
            if (number <= 0)
            {
                number = MAX_COOLDOWN_SECONDS;
                Stun(artifact.Level);
                artifact.Highlight();
            }
            artifact.SetNumber(number);
            secondTimer.Reset();
        }
    }
    public static function Stun(level:LevelEngine):Void
    {
        var stunned = false;
        for (enemy in level.FindEntities(e -> e.IsHostileEntity() && e.Type == EntityTypes.ENEMY && e.CanDeactive()))
        {
            enemy.Stun(Ticks.FromSeconds(STUN_SECONDS));
            stunned = true;
        }
        if (stunned)
        {
            level.PlaySound(VanillaSoundID.stunned);
        }
    }
    public static inline var MAX_COOLDOWN_SECONDS:Int = 60;
    public static inline var STUN_SECONDS:Float = 10;
}
