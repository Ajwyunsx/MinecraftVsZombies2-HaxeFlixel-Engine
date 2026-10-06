// Ported from: Assets/Scripts/Vanilla/GameContent/Artifacts/Chapter4/ManipulativeTalismans.cs
package mvz2.gamecontent.artifacts;

import mvz2.gamecontent.artifacts.VanillaArtifactID.VanillaArtifactNames;
import mvz2.vanilla.audios.VanillaSoundID;
import mvz2.vanilla.callbacks.VanillaLevelCallbacks;
import mvz2logic.artifacts.ArtifactDefinition;
import mvz2logic.artifacts.ArtifactSourceReference;
import pvzengine.callbacks.CallbackResult;
import pvzengine.callbacks.EntityCallbackParams;
using mvz2logic.entities.LogicEntityExt;
using mvz2logic.level.LogicLevelExt;
using mvz2.vanilla.entities.VanillaEntityExt;

@:autoArtifactDefinition(VanillaArtifactNames.manipulativeTalismans)
class ManipulativeTalismans extends ArtifactDefinition
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
        AddTrigger(VanillaLevelCallbacks.PRE_ENEMY_FAINT, PreEnemyFaintCallback, -100);
    }
    function PreEnemyFaintCallback(param:EntityCallbackParams, result:CallbackResult):Void
    {
        var enemy = param.entity;
        if (!enemy.IsHostileEntity())
            return;
        var level = enemy.Level;
        var artifacts = level.GetArtifacts();
        for (artifact in artifacts)
        {
            if (artifact == null || artifact.Definition != this)
                continue;
            var rng = artifact.RNG;
            if (rng.Next(100) < REVIVE_CHANCE)
            {
                enemy.Revive();
                enemy.Health = enemy.GetMaxHealth();
                // PORT-NOTE: C# 重载 new ArtifactSourceReference(artifact)，Haxe 不支持重载，改用静态工厂 FromArtifact。
                enemy.CharmPermanent(level.Option.LeftFaction, ArtifactSourceReference.FromArtifact(artifact));
                result.SetFinalValue(false);
                artifact.Highlight();
                enemy.PlaySound(VanillaSoundID.revived);
                return;
            }
        }
    }
    public static inline var REVIVE_CHANCE:Int = 10;
}
