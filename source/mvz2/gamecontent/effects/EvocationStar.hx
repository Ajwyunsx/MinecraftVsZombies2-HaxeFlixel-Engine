// Ported from: Assets/Scripts/Vanilla/GameContent/Effects/Chapter1/EvocationStar.cs
package mvz2.gamecontent.effects;

import mvz2.vanilla.audios.VanillaSoundID;
import mvz2logic.level.LogicLevelExt;
import pvzengine.entities.Entity;
import unity.Vector3;
import mvz2.gamecontent.effects.VanillaEffectID.VanillaEffectNames;

@:autoEntityBehaviourDefinition(VanillaEffectNames.evocationStar)
class EvocationStar extends EffectBehaviour
{
    // #region 公有方法
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
    }
    public override function Init(entity:Entity):Void
    {
        super.Init(entity);
        entity.Level.PlaySound(VanillaSoundID.evocation);
    }
    public override function Update(entity:Entity):Void
    {
        super.Update(entity);
        var scale = entity.RNG.Next(0.98, 1.12);
        entity.SetDisplayScale(Vector3.one * scale);
    }
    // #endregion
}
