// Ported from: Assets/Scripts/Vanilla/GameContent/Pickups/ClearPickup/CollectBehaviour_Clear.cs
package mvz2.gamecontent.pickups;

import mvz2.gamecontent.effects.GemEffect;
import mvz2.gamecontent.effects.VanillaEffectID;
import mvz2.vanilla.audios.VanillaSoundID;
import mvz2.vanilla.entities.VanillaEntityBehaviourNames;
import mvz2.vanilla.pickups.VanillaPickupProps;
import mvz2logic.difficulties.LogicDifficultyProps;
import mvz2logic.level.LogicLevelExt;
import pvzengine.entities.Entity;
import unity.Vector3;
using mvz2.vanilla.pickups.VanillaPickupProps;
using mvz2logic.difficulties.LogicDifficultyProps;

@:autoEntityBehaviourDefinition(VanillaEntityBehaviourNames.pickupCollectClear)
class CollectBehaviour_Clear extends CollectBehaviour
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
    }
    public override function CanCollect(pickup:Entity):Bool
    {
        return true;
    }
    public override function PostCollect(pickup:Entity):Void
    {
        super.PostCollect(pickup);
        pickup.Velocity = Vector3.zero;
        var level = pickup.Level;

        var difficultyDef = level.Content.GetDifficultyDefinition(level.Difficulty);
        var money = 0;
        if (level.IsRerun)
        {
            money = 250;
            if (difficultyDef != null)
            {
                money = difficultyDef.GetRerunClearMoney();
            }
        }
        else
        {
            if (difficultyDef != null)
            {
                if (level.DropsTrophy())
                {
                    money = difficultyDef.GetPuzzleMoney();
                }
                else
                {
                    money = difficultyDef.GetClearMoney();
                }
            }
        }
        GemEffect.SpawnGemEffects(level, money, pickup.Position, pickup, false);

        level.Clear();
        level.ResetHeldItem();
        level.StopMusic();
        level.PlaySoundIfNotNull(pickup.GetCollectSound());
        var clearSound = pickup.Level.GetClearSound();
        level.PlaySound(clearSound != null ? clearSound : VanillaSoundID.winMusic);
        level.Spawn(VanillaEffectID.starParticles, pickup.Position, pickup);
    }
}
