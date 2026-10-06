// Ported from: Assets/Scripts/Vanilla/GameContent/Contraptions/Chapter2/LilyPad.cs
package mvz2.gamecontent.contraptions;

import mvz2.gamecontent.buffs.contraptions.LilyPadEvocationBuff;
import mvz2.vanilla.audios.VanillaSoundID;
import mvz2.vanilla.entities.VanillaEntityExt;
import mvz2logic.grids.LogicGridExt;
import mvz2logic.level.LogicLevelExt;
import pvzengine.buffs.BuffExt;
import pvzengine.entities.Entity;
using mvz2.vanilla.entities.VanillaEntityExt;

@:autoEntityBehaviourDefinition(VanillaContraptionNames.lilyPad)
class LilyPad extends ContraptionBehaviour
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
    }
    override function OnEvoke(entity:Entity):Void
    {
        super.OnEvoke(entity);
        var level = entity.Level;
        var column = entity.GetColumn();
        var lane = entity.GetLane();
        for (x in (column - 1)...(column + 2))
        {
            for (y in (lane - 1)...(lane + 2))
            {
                var grid = level.GetGrid(x, y);
                if (grid == null || !grid.IsWater() || !grid.IsEmpty() || grid.IsDisabled())
                    continue;
                // C#: level.Spawn(...)?.Let(e => { ... })
                var lily = level.Spawn(VanillaContraptionID.lilyPad, grid.GetEntityPosition(), entity);
                if (lily != null)
                {
                    lily.AddBuff(LilyPadEvocationBuff);
                    lily.PlaySplashEffect();
                }
            }
        }
        level.PlaySound(VanillaSoundID.water);
    }
}
