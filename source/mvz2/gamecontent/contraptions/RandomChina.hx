// Ported from: Assets/Scripts/Vanilla/GameContent/Contraptions/Prologue/RandomChina.cs
package mvz2.gamecontent.contraptions;

import mvz2.gamecontent.buffs.contraptions.NocturnalBuff;
import mvz2.gamecontent.effects.FloatingText;
import mvz2.gamecontent.effects.VanillaEffectID;
import mvz2.vanilla.definitions.VanillaDefinitionTypes;
import mvz2.vanilla.entities.VanillaEntityExt;
import mvz2.vanilla.localization.VanillaStrings;
import mvz2.vanilla.randomchina.RandomChinaEventDefinition;
import mvz2logic.Global;
import mvz2logic.entities.IDeathEffectsBehaviour;
import mvz2logic.entities.LogicEntityExt;
import mvz2logic.grids.LogicGridExt;
import pvzengine.buffs.BuffExt;
import pvzengine.damages.DeathInfo;
import pvzengine.entities.Entity;
import tools.RandomGenerator;
using mvz2.vanilla.entities.VanillaEntityExt;
using mvz2logic.blueprints.LogicSeedProps;
using mvz2logic.entities.LogicContraptionProps;
import mvz2logic.entities.LogicContraptionProps;
using tools.LinqHelper;

@:autoEntityBehaviourDefinition(VanillaContraptionNames.randomChina)
class RandomChina extends ContraptionBehaviour implements IDeathEffectsBehaviour
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
    }

    public function DeathEffects(entity:Entity, damageInfo:DeathInfo):Void
    {
        var grid = entity.GetGrid();
        if (grid == null)
            return;

        var game = Global.Game;
        var level = entity.Level;
        var rng = entity.RNG;
        entity.ClearTakenGrids();
        var unlockedContraptions = Global.Saves.GetUnlockedContraptions();
        var validContraptions = Lambda.filter(unlockedContraptions, function(id)
        {
            if (!Global.Almanac.IsContraptionInAlmanac(id))
                return false;
            var def = game.GetEntityDefinition(id);
            if (def == null || LogicContraptionProps.IsUpgradeBlueprintOfDefinition(def))
                return false;
            return grid.CanSpawnEntity(id);
        });
        if (validContraptions.length <= 0)
            return;
        var contraptionID = validContraptions.Random(rng);
        var spawned = entity.SpawnWithParams(contraptionID, entity.Position);
        if (spawned != null && spawned.HasBuff(NocturnalBuff))
        {
            spawned.RemoveBuffs(NocturnalBuff);
        }
    }

    override function OnEvoke(contraption:Entity):Void
    {
        super.OnEvoke(contraption);
        var rng = new RandomGenerator(contraption.RNG.Next());

        var allEvents = contraption.Level.Content.GetDefinitions(RandomChinaEventDefinition, VanillaDefinitionTypes.RANDOM_CHINA_EVENT);
        var def = allEvents.WeightedRandom(e -> e.Weight, rng);
        def.Run(contraption, rng);

        var name = Global.Localization.GetTextParticular(def.EventName, VanillaStrings.CONTEXT_RANDOM_CHINA_EVENT_NAME);
        var desc = Global.Localization.GetTextParticular(def.EventDescription, VanillaStrings.CONTEXT_RANDOM_CHINA_EVENT_DESCRIPTION);
        var text = Global.Localization.GetText(VanillaStrings.RANDOM_CHINA_TEXT_TEMPLATE, [name, desc]);

        SpawnText(contraption, text);
    }
    public function SpawnText(entity:Entity, text:String):Void
    {
        var param = entity.GetSpawnParams();
        param.SetProperty(FloatingText.PROP_TEXT, text);
        entity.Spawn(VanillaEffectID.floatingText, entity.GetCenter(), param);
    }
}
