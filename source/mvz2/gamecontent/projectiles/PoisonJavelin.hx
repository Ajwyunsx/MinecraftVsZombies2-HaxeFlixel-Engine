// Ported from: Assets/Scripts/Vanilla/GameContent/Projectiles/Chapter2/PoisonJavelin.cs
package mvz2.gamecontent.projectiles;

import mvz2.gamecontent.effects.VanillaEffectID;
import mvz2.vanilla.entities.VanillaEntityExt;
import mvz2.vanilla.properties.VanillaEntityPropertyMeta;
import pvzengine.NamespaceID;
import pvzengine.definitions.EntityBehaviourDefinition;
import pvzengine.entities.Entity;
using mvz2.vanilla.entities.VanillaEntityExt;

@:autoEntityBehaviourDefinition(VanillaProjectileNames.poisonJavelin)
class PoisonJavelin extends EntityBehaviourDefinition
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
    }
    public override function Update(projectile:Entity):Void
    {
        super.Update(projectile);
        var cooldown = GetGasCooldown(projectile);
        cooldown--;
        if (cooldown <= 0)
        {
            var gas = projectile.SpawnWithParams(VanillaEffectID.weaknessGas, projectile.Position);
            cooldown = MAX_COOLDOWN;
        }
        SetGasCooldown(projectile, cooldown);
    }
    public static function GetGasCooldown(entity:Entity):Int return entity.GetBehaviourFieldNS(ID, PROP_GAS_COOLDOWN);
    public static function SetGasCooldown(entity:Entity, value:Int):Void entity.SetBehaviourFieldNS(ID, PROP_GAS_COOLDOWN, value);
    static var ID:NamespaceID = VanillaProjectileID.poisonJavelin;
    public static inline var MAX_COOLDOWN:Int = 3;
    public static var PROP_GAS_COOLDOWN:VanillaEntityPropertyMeta<Int> = new VanillaEntityPropertyMeta<Int>("GasCooldown");
}
