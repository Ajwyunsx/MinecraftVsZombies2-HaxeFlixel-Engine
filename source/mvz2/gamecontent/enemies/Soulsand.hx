// Ported from: Assets/Scripts/Vanilla/GameContent/Enemies/Chapter3/Soulsand.cs
package mvz2.gamecontent.enemies;

import pvzengine.damages.DeathInfo;
import pvzengine.entities.Entity;
import unity.Mathf;
using mvz2.vanilla.effects.FragmentExt;

@:autoEntityBehaviourDefinition(VanillaEnemyNames.soulsand)
class Soulsand extends EnemyBehaviour
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
    }
    override function UpdateLogic(entity:Entity):Void
    {
        super.UpdateLogic(entity);

        if (entity.Velocity.y != 0)
        {
            entity.AddFragmentTickDamage(Mathf.Abs(entity.Velocity.y));
        }
    }
    public override function PostDeath(entity:Entity, info:DeathInfo):Void
    {
        super.PostDeath(entity, info);
        entity.Remove();
    }
}
