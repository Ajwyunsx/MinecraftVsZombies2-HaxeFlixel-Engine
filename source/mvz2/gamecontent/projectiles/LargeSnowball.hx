// Ported from: Assets/Scripts/Vanilla/GameContent/Projectiles/Chapter1/LargeSnowball.cs
package mvz2.gamecontent.projectiles;

import mvz2.gamecontent.areas.VanillaAreaID;
import mvz2.gamecontent.contraptions.IHellfireIgniteBehaviour;
import mvz2.vanilla.audios.VanillaSoundID;
import mvz2.vanilla.callbacks.VanillaLevelCallbacks;
import mvz2.vanilla.callbacks.VanillaLevelCallbacks.PostTakeDamageParams;
import mvz2.vanilla.entities.VanillaEntityExt;
import mvz2.vanilla.entities.VanillaEntityProps;
import mvz2.vanilla.properties.VanillaEntityPropertyMeta;
import pvzengine.NamespaceID;
import pvzengine.callbacks.CallbackResult;
import pvzengine.definitions.EntityBehaviourDefinition;
import pvzengine.entities.Entity;
import unity.Mathf;
import unity.Vector3;
using mvz2logic.entities.LogicEntityExt;
using mvz2.vanilla.entities.VanillaEntityExt;
using mvz2.vanilla.entities.VanillaEntityProps;
using mvz2logic.entities.LogicEntityProps;

@:autoEntityBehaviourDefinition(VanillaProjectileNames.largeSnowball)
class LargeSnowball extends EntityBehaviourDefinition implements IHellfireIgniteBehaviour
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
        AddTrigger(VanillaLevelCallbacks.POST_ENTITY_TAKE_DAMAGE, PostEnemyTakeDamageCallback);
    }
    public override function Init(entity:Entity):Void
    {
        super.Init(entity);
        SetSnowballScale(entity, 1);
    }
    public override function Update(projectile:Entity):Void
    {
        super.Update(projectile);

        projectile.Velocity += projectile.Velocity.normalized / 3;
        var scale = GetSnowballScale(projectile);
        scale = Mathf.Clamp(scale + SCALE_SPEED, MIN_SCALE, MAX_SCALE);
        SetSnowballScale(projectile, scale);

        var angleSpeed = -projectile.Velocity.x * 2.5;
        projectile.RenderRotation += Vector3.forward * angleSpeed;

        var scaleVector = new Vector3(scale, scale, 1);
        projectile.SetScale(scaleVector);
        projectile.SetDisplayScale(scaleVector);
        projectile.SetShadowScale(scaleVector * 0.5);
        projectile.SetDamage(Mathf.Max(0, (scale - 1) * 300));
    }
    function PostEnemyTakeDamageCallback(param:PostTakeDamageParams, callbackResult:CallbackResult):Void
    {
        var output = param.output;
        var bodyResult = output.BodyResult;
        if (bodyResult == null)
            return;
        var entity = bodyResult.Entity;
        var source = bodyResult.Source != null ? bodyResult.Source.GetEntity(entity.Level) : null;
        if (source == null)
            return;
        if (bodyResult.Fatal && source.IsEntityOf(VanillaProjectileID.largeSnowball))
        {
            source.PlaySound(VanillaSoundID.grind);
        }
    }
    public static function GetSnowballScale(entity:Entity):Float return entity.GetBehaviourFieldNS(ID, PROP_SNOWBALL_SCALE);
    public static function SetSnowballScale(entity:Entity, scale:Float):Void entity.SetBehaviourFieldNS(ID, PROP_SNOWBALL_SCALE, scale);
    public function Ignite(entity:Entity, hellfire:Entity, cursed:Bool):Void
    {
        var scale = GetSnowballScale(entity);

        var reduceMulti = cursed ? 2 : 1;
        scale -= IGNITE_SCALE_REDUCTION * reduceMulti;
        SetSnowballScale(entity, scale);
        if (scale < 1)
        {
            var level = entity.Level;
            var param = entity.GetSpawnParams();
            param.SetProperty(VanillaEntityProps.DAMAGE, 10);
            var cobble = level.Spawn(VanillaProjectileID.cobble, entity.Position, entity.SpawnerReference != null ? entity.SpawnerReference.GetEntity(level) : null, param);
            if (cobble != null)
            {
                cobble.Velocity = entity.Velocity;
            }
            entity.Remove();
        }
    }

    static var ID:NamespaceID = VanillaAreaID.halloween;
    public static var PROP_SNOWBALL_SCALE:VanillaEntityPropertyMeta<Float> = new VanillaEntityPropertyMeta<Float>("SnowballScale");
    public static inline var IGNITE_SCALE_REDUCTION:Float = 0.2;
    public static inline var MIN_SCALE:Float = 1;
    public static inline var SCALE_SPEED:Float = 0.1;
    public static inline var MAX_SCALE:Float = 10;
}
