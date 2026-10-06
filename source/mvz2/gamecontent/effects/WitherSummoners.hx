// Ported from: Assets/Scripts/Vanilla/GameContent/Effects/Chapter3/WitherSummoners.cs
package mvz2.gamecontent.effects;

import mvz2.gamecontent.bosses.VanillaBossID;
import mvz2.gamecontent.bosses.Wither;
import mvz2.vanilla.audios.VanillaSoundID;
import mvz2.vanilla.bosses.VanillaBossExt;
import pvzengine.entities.Entity;
import mvz2.gamecontent.effects.VanillaEffectID.VanillaEffectNames;
using mvz2logic.entities.LogicEntityExt;

@:autoEntityBehaviourDefinition(VanillaEffectNames.witherSummoners)
class WitherSummoners extends EffectBehaviour
{
    // #region 公有方法
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
    }
    public override function Init(entity:Entity):Void
    {
        super.Init(entity);
        entity.PlaySound(VanillaSoundID.reverseVampire);
        entity.PlaySound(VanillaSoundID.odd);
    }
    public override function Update(entity:Entity):Void
    {
        super.Update(entity);
        if (entity.Timeout <= 0)
        {
            var wither = entity.Spawn(VanillaBossID.wither, entity.Position);
            // C#: ...?.Let(e => {...})
            if (wither != null)
            {
                Wither.Appear(wither);
                VanillaBossExt.ApplyBuffForBossRevenge(wither, 1);
            }
        }
    }
    // #endregion
}
