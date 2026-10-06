// Ported from: Assets/Scripts/Vanilla/GameContent/Enemies/Chapter6/RollingGiantBlock.cs
package mvz2.gamecontent.enemies;

import mvz2.vanilla.entities.VanillaEntityBehaviourNames;
import mvz2.vanilla.entities.VanillaEntityExt;
import mvz2.vanilla.properties.VanillaEntityPropertyMeta;
import pvzengine.definitions.EntityBehaviourDefinition;
import pvzengine.entities.Entity;
import unity.Mathf;
using mvz2.vanilla.enemies.VanillaEnemyExt;

@:autoEntityBehaviourDefinition(VanillaEntityBehaviourNames.rollingGiantBlock)
class RollingGiantBlock extends EntityBehaviourDefinition
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
    }

    public override function Update(entity:Entity):Void
    {
        super.Update(entity);
        var rotation = GetRotation(entity);
        rotation += entity.Velocity.x;
        rotation = Mathf.Repeat(rotation, 360);
        SetRotation(entity, rotation);

        entity.SetAnimationFloat("Rotation", rotation);


        var remove = false;
        if (!entity.IsFacingLeft() && entity.IsEnemyOutsideRight())
        {
            remove = true;
        }
        else if (entity.IsFacingLeft() && entity.IsEnemyOutsideLeft())
        {
            remove = true;
        }
        if (remove)
        {
            entity.Remove();
        }
    }
    public static function GetRotation(entity:Entity):Float return entity.GetProperty(PROP_ROTATION);
    public static function SetRotation(entity:Entity, value:Float):Void entity.SetProperty(PROP_ROTATION, value);
    public static var PROP_ROTATION:VanillaEntityPropertyMeta<Float> = new VanillaEntityPropertyMeta<Float>("rotation");
}
