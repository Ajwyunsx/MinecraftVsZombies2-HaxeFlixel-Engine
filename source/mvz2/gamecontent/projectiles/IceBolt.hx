// Ported from: Assets/Scripts/Vanilla/GameContent/Projectiles/Chapter4/IceBolt.cs
package mvz2.gamecontent.projectiles;

import mvz2.gamecontent.contraptions.IHellfireIgniteBehaviour;
import mvz2.gamecontent.effects.VanillaEffectID;
import mvz2.vanilla.audios.VanillaSoundID;
import mvz2.vanilla.entities.VanillaEntityExt;
import pvzengine.EngineEntityProps;
import pvzengine.definitions.EntityBehaviourDefinition;
import pvzengine.entities.Entity;
using mvz2.vanilla.entities.VanillaEntityExt;
using mvz2logic.entities.LogicEntityExt;

@:autoEntityBehaviourDefinition(VanillaProjectileNames.iceBolt)
class IceBolt extends EntityBehaviourDefinition implements IHellfireIgniteBehaviour
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
    }
    public function Ignite(entity:Entity, hellfire:Entity, cursed:Bool):Void
    {
        var param = entity.GetSpawnParams();
        param.SetProperty(EngineEntityProps.SIZE, entity.GetScaledSize());
        entity.Spawn(VanillaEffectID.smoke, entity.Position, param);
        entity.Die();
        entity.PlaySound(VanillaSoundID.fizz);
    }
}
