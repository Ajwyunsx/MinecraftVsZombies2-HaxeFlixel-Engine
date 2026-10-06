// Ported from: Assets/Scripts/Vanilla/GameContent/Projectiles/Chapter1/Snowball.cs
package mvz2.gamecontent.projectiles;

import mvz2.gamecontent.contraptions.IHellfireIgniteBehaviour;
import pvzengine.definitions.EntityBehaviourDefinition;
import pvzengine.entities.Entity;

@:autoEntityBehaviourDefinition(VanillaProjectileNames.snowball)
class Snowball extends EntityBehaviourDefinition implements IHellfireIgniteBehaviour
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
    }
    public function Ignite(entity:Entity, hellfire:Entity, cursed:Bool):Void
    {
        entity.SetModelProperty("Melted", true);
    }
}
