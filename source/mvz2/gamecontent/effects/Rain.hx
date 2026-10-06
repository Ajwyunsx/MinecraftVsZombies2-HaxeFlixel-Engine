// Ported from: Assets/Scripts/Vanilla/GameContent/Effects/Chapter1/Rain.cs
package mvz2.gamecontent.effects;

import mvz2.vanilla.audios.VanillaSoundID;
import mvz2logic.level.LogicLevelExt;
import pvzengine.entities.Entity;
import mvz2.gamecontent.effects.VanillaEffectID.VanillaEffectNames;

@:autoEntityBehaviourDefinition(VanillaEffectNames.rain)
class Rain extends EffectBehaviour
{
    // #region 公有方法
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
    }
    public override function Init(entity:Entity):Void
    {
        super.Init(entity);
        entity.Level.AddLoopSoundEntity(VanillaSoundID.rain, entity.ID);
    }
    // #endregion
}
