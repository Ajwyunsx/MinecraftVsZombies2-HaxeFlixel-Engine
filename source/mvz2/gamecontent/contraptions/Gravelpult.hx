// Ported from: Assets/Scripts/Vanilla/GameContent/Contraptions/Chapter6/Gravelpult.cs
package mvz2.gamecontent.contraptions;

import mvz2.gamecontent.projectiles.VanillaProjectileID;
import mvz2.vanilla.projectiles.ShootParams;
import mvz2.vanilla.projectiles.VanillaProjectileProps;
import mvz2.vanilla.properties.VanillaEntityPropertyMeta;
import pvzengine.entities.Entity;

@:autoEntityBehaviourDefinition(VanillaContraptionNames.gravelpult)
class Gravelpult extends CatapultBehaviour
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
    }

    override function UpdateAI(entity:Entity):Void
    {
        super.UpdateAI(entity);
        CatapultUpdate(entity);
    }
    override function UpdateLogic(entity:Entity):Void
    {
        super.UpdateLogic(entity);
        UpdateAnimation(entity);
        entity.SetModelProperty("ThrowsGravel", ThrowsGravel(entity));
    }
    public override function OnThrownTimeout(entity:Entity):Void
    {
        super.OnThrownTimeout(entity);
        SetThrowsGravel(entity, entity.RNG.Next(100) < GRAVEL_CHANCE_PERCENTAGE);
    }
    override function PreModifyShootParameters(entity:Entity, param:ShootParams):ShootParams
    {
        param = super.PreModifyShootParameters(entity, param);
        if (ThrowsGravel(entity))
        {
            param.damage *= 2;
            param.projectileID = VanillaProjectileID.gravel;
        }
        param.spawnParam.SetProperty(VanillaProjectileProps.IGNORE_SHIELDS, true);
        return param;
    }

    //region 属性
    public static function ThrowsGravel(entity:Entity):Bool return entity.GetProperty(PROP_THROWS_GRAVEL);
    public static function SetThrowsGravel(entity:Entity, value:Bool):Void entity.SetProperty(PROP_THROWS_GRAVEL, value);
    //endregion

    public static var PROP_THROWS_GRAVEL:VanillaEntityPropertyMeta<Bool> = new VanillaEntityPropertyMeta<Bool>("throws_gravel");
    public static inline var GRAVEL_CHANCE_PERCENTAGE:Int = 25;
}
