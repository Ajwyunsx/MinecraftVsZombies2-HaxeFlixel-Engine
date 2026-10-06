// Ported from: Assets/Scripts/Vanilla/GameContent/Enemies/Common/DamageByGoldBehaviour.cs
package mvz2.gamecontent.enemies;

import mvz2.gamecontent.buffs.VanillaBuffID;
import mvz2.gamecontent.damages.VanillaDamageEffects;
import mvz2.vanilla.entities.VanillaEntityBehaviourNames;
import mvz2.vanilla.entities.VanillaEntityExt;
import pvzengine.buffs.BuffExt;
import pvzengine.callbacks.CallbackResult;
import pvzengine.damages.DamageEffectList;
import pvzengine.damages.DamageInput;
import pvzengine.definitions.EntityBehaviourDefinition;
import pvzengine.entities.Entity;
import pvzengine.grids.GridSourceReference;
using mvz2.vanilla.entities.VanillaEntityExt;

@:autoEntityBehaviourDefinition(VanillaEntityBehaviourNames.damageByGold)
class DamageByGoldBehaviour extends EntityBehaviourDefinition
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
    }
    public override function Update(entity:Entity):Void
    {
        super.Update(entity);
        DamageByGoldenGrid(entity);
    }
    public override function PreTakeDamage(input:DamageInput, result:CallbackResult):Void
    {
        super.PreTakeDamage(input, result);
        if (input.Effects.HasEffect(VanillaDamageEffects.GOLD))
        {
            input.Multiply(3);
        }
    }
    function DamageByGoldenGrid(entity:Entity):Void
    {
        if (!entity.IsOnGround)
            return;
        var grid = entity.GetGrid();
        if (grid == null || !grid.HasBuff(VanillaBuffID.Grid.goldenGrid))
            return;
        var effects = new DamageEffectList([VanillaDamageEffects.GOLD, VanillaDamageEffects.MUTE]);
        entity.TakeDamageSourced(GOLDEN_GRID_DAMAGE, effects, new GridSourceReference(grid));
    }
    public static inline var GOLDEN_GRID_DAMAGE:Float = 1;
}
