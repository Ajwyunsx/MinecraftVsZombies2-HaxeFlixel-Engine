// Ported from: Assets/Scripts/Vanilla/GameContent/Carts/Ballista.cs
package mvz2.gamecontent.carts;

import mvz2.gamecontent.carts.VanillaCartID.VanillaCartNames;
import mvz2.vanilla.carts.VanillaCartExt;
import mvz2.vanilla.projectiles.VanillaProjectileExt;
import mvz2.vanilla.properties.VanillaEntityPropertyMeta;
import pvzengine.entities.Entity;

@:autoEntityBehaviourDefinition(VanillaCartNames.ballista)
class Ballista extends CartBehaviour
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
    }
    public override function Update(entity:Entity):Void
    {
        super.Update(entity);
        var loaded = !VanillaCartExt.IsCartTriggered(entity);
        var blend = GetStringBlend(entity);
        var targetBlend:Float = loaded ? 1 : 0;
        blend = blend * 0.8 + targetBlend * 0.2;
        SetStringBlend(entity, blend);

        entity.SetAnimationBool("Loaded", loaded);
        entity.SetAnimationFloat("StringBlend", blend);
    }
    public override function PostTrigger(entity:Entity):Void
    {
        super.PostTrigger(entity);
        VanillaProjectileExt.ShootProjectile(entity);
    }
    public static function GetStringBlend(entity:Entity):Float
    {
        return entity.GetBehaviourField(PROP_STRING_BLEND);
    }
    public static function SetStringBlend(entity:Entity, value:Float):Void
    {
        entity.SetBehaviourField(PROP_STRING_BLEND, value);
    }
    public static var PROP_STRING_BLEND:VanillaEntityPropertyMeta<Float> = new VanillaEntityPropertyMeta<Float>("StringBlend");
}
