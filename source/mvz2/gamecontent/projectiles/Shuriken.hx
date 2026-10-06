// Ported from: Assets/Scripts/Vanilla/GameContent/Projectiles/Chapter1/Shuriken.cs
package mvz2.gamecontent.projectiles;

import pvzengine.definitions.EntityBehaviourDefinition;
import pvzengine.entities.Entity;
import unity.Vector3;

@:autoEntityBehaviourDefinition(VanillaProjectileNames.shuriken)
class Shuriken extends EntityBehaviourDefinition
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
    }
    public override function Update(entity:Entity):Void
    {
        super.Update(entity);
        entity.RenderRotation += Vector3.back * 30;
    }
}
