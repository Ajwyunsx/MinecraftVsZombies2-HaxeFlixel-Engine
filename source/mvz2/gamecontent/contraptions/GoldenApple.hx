// Ported from: Assets/Scripts/Vanilla/GameContent/Contraptions/Chapter3/GoldenApple.cs
package mvz2.gamecontent.contraptions;

import mvz2.gamecontent.effects.VanillaEffectID;
import mvz2.gamecontent.enemies.VanillaEnemyID;
import mvz2.vanilla.audios.VanillaSoundID;
import mvz2.vanilla.callbacks.VanillaLevelCallbacks;
import mvz2.vanilla.entities.VanillaEntityExt;
import mvz2logic.entities.LogicEntityExt;
import pvzengine.NamespaceID;
import pvzengine.callbacks.CallbackResult;
import pvzengine.entities.Entity;
import pvzengine.entities.EntitySourceReference;
import pvzengine.entities.EntityTypes;
using mvz2.vanilla.enemies.VanillaEnemyExt;
using mvz2.vanilla.entities.VanillaEntityExt;
using mvz2.vanilla.entities.VanillaEntityProps;
using mvz2logic.entities.LogicContraptionProps;
using mvz2logic.entities.LogicEntityExt;

@:autoEntityBehaviourDefinition(VanillaContraptionNames.goldenApple)
class GoldenApple extends ContraptionBehaviour
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
        AddTrigger(VanillaLevelCallbacks.POST_ENEMY_MELEE_ATTACK, PostEnemyMeleeAttackCallback);
    }
    override function UpdateLogic(entity:Entity):Void
    {
        super.UpdateLogic(entity);
        entity.SetModelProperty("Evoked", entity.IsEvoked());
    }
    override function OnEvoke(entity:Entity):Void
    {
        super.OnEvoke(entity);
        entity.SetEvoked(true);
        entity.PlaySound(VanillaSoundID.sparkle);
    }

    function PostEnemyMeleeAttackCallback(param:EnemyMeleeAttackParams, result:CallbackResult):Void
    {
        var enemy = param.enemy;
        var target = param.target;
        if (!target.IsEntityOf(VanillaContraptionID.goldenApple))
            return;
        if (!target.IsHostile(enemy))
            return;
        if (target.IsAIFrozen())
            return;
        if (target.IsEvoked())
        {
            enemy.Neutralize();
            // C#: target.Spawn(...)?.Let(e => { e.CharmPermanent(...); })
            var mutant = target.Spawn(VanillaEnemyID.mutantZombie, enemy.Position);
            if (mutant != null)
            {
                mutant.CharmPermanent(target.GetFaction(), new EntitySourceReference(target));
            }
            enemy.Spawn(VanillaEffectID.mindControlLines, enemy.GetCenter());
            enemy.Remove();
            enemy.PlaySound(VanillaSoundID.charmed);
            enemy.PlaySound(VanillaSoundID.odd);
        }
        else
        {
            enemy.Neutralize();
            enemy.CharmPermanent(target.GetFaction(), new EntitySourceReference(target));
            enemy.Spawn(VanillaEffectID.mindControlLines, enemy.GetCenter());
            enemy.PlaySound(VanillaSoundID.charmed);
            enemy.PlaySound(VanillaSoundID.floop);
        }
        target.Remove();
    }
    static var ID:NamespaceID = VanillaContraptionID.goldenApple;
}
