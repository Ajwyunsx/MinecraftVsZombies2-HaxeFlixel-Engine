// Ported from: Assets/Scripts/Vanilla/GameContent/Contraptions/Chapter6/CoolingCell.cs
package mvz2.gamecontent.contraptions;

import mvz2.gamecontent.effects.VanillaEffectID;
import mvz2.vanilla.audios.VanillaSoundID;
import mvz2.vanilla.grids.VanillaGridLayers;
import mvz2logic.entities.LogicEntityExt;
import mvz2logic.grids.LogicGridExt;
import mvz2logic.level.LogicLevelExt;
import pvzengine.definitions.EntityBehaviourDefinition;
import pvzengine.entities.Entity;
import pvzengine.entities.EntityTypes;
import pvzengine.seedpacks.ClassicSeedPack;
import pvzengine.seedpacks.SeedPack;
import unity.Mathf;
using mvz2logic.entities.LogicEntityExt;

@:autoEntityBehaviourDefinition(VanillaContraptionNames.coolingCell)
class CoolingCell extends EntityBehaviourDefinition
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
    }
    public override function Init(contraption:Entity):Void
    {
        super.Init(contraption);
        contraption.Spawn(VanillaEffectID.smokeCluster, contraption.GetCenter());
        contraption.PlaySound(VanillaSoundID.fizz);
        var grid = contraption.GetGrid();
        if (grid != null)
        {
            var layers = grid.GetLayers();
            var orderedLayers = VanillaGridLayers.coolingCellLayers;
            var cooled = false;
            for (layer in orderedLayers)
            {
                var entity = grid.GetLayerEntity(layer);
                if (entity == null || !CanCool(entity))
                    continue;
                if (entity.HasBehaviour(Hellfire) && !Hellfire.IsCursed(entity))
                {
                    Hellfire.Extinguish(entity);
                }

                if (cooled)
                    continue;
                var targetSeedPack = GetCoolTargetBlueprint(entity);
                if (targetSeedPack == null)
                    continue;
                var recharge = targetSeedPack.GetRecharge();
                recharge = Mathf.Min(targetSeedPack.GetMaxRecharge(), recharge + RECHARGE_VALUE);
                targetSeedPack.SetRecharge(recharge);
                cooled = true;
            }
        }
    }
    public static function CanCool(entity:Entity):Bool
    {
        if (!entity.ExistsAndAlive())
            return false;
        if (entity.Type != EntityTypes.PLANT)
            return false;
        return true;
    }
    public static function GetCoolTargetBlueprint(target:Entity):Null<ClassicSeedPack>
    {
        var level = target.Level;
        var seedSlotCount = level.GetSeedSlotCount();
        var targetID = target.GetDefinitionID();
        if (targetID == VanillaContraptionID.commandBlock)
        {
            targetID = CommandBlock.GetTargetEntity(target);
        }
        // PORT-NOTE: LINQ 的 OfType/Where/OrderBy/FirstOrDefault 改为 Lambda + sort + 取首元素。
        var candidates = Lambda.filter(level.GetAllSeedPacks(), s -> Std.isOfType(s, ClassicSeedPack) && s.GetDefinitionID() == targetID && !s.IsCharged());
        candidates.sort((a, b) -> Reflect.compare(a.GetRecharge(), b.GetRecharge()));
        return candidates.length > 0 ? cast(candidates[0], ClassicSeedPack) : null;
    }
    public static inline var RECHARGE_VALUE:Float = 900;
}
