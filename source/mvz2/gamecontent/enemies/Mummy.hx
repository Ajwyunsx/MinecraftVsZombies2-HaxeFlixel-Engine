// Ported from: Assets/Scripts/Vanilla/GameContent/Enemies/Chapter1/Mummy.cs
package mvz2.gamecontent.enemies;

import mvz2.gamecontent.effects.VanillaEffectID;
import mvz2.gamecontent.entities.AIEntityBehaviour;
import mvz2.vanilla.audios.VanillaSoundID;
import mvz2.vanilla.entities.VanillaEntityExt;
import mvz2logic.entities.IDeathEffectsBehaviour;
import pvzengine.EngineEntityProps;
import pvzengine.damages.DeathInfo;
import pvzengine.entities.Entity;
using mvz2.vanilla.entities.VanillaEntityExt;
using mvz2logic.entities.LogicEntityExt;

@:autoEntityBehaviourDefinition(VanillaEnemyNames.mummy)
class Mummy extends AIEntityBehaviour implements IDeathEffectsBehaviour
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
    }
    public function DeathEffects(entity:Entity, info:DeathInfo):Void
    {
        var param = entity.GetSpawnParams();
        param.SetProperty(EngineEntityProps.SCALE, entity.GetScale());
        var gas = entity.Spawn(VanillaEffectID.mummyGas, entity.Position, param);
        entity.PlaySound(VanillaSoundID.poisonCast);
    }
}
