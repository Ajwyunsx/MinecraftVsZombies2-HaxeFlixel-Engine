// Ported from: Assets/Scripts/Vanilla/GameContent/Buffs/Projectiles/Chapter1/ProjectileWaitBuff.cs
package mvz2.gamecontent.buffs.projectiles;

import mvz2.gamecontent.buffs.VanillaBuffNames;
import mvz2.vanilla.modifiers.VanillaModifierPriorities;
import mvz2.vanilla.properties.VanillaBuffPropertyMeta;
import pvzengine.buffs.Buff;
import pvzengine.definitions.BuffDefinition;
import pvzengine.entities.EngineEntityProps;
import pvzengine.modifiers.NumberOperator;
import pvzengine.modifiers.Vector3Modifier;
import unity.Vector3;

@:autoBuffDefinition(VanillaBuffNames.Projectile_projectileWait)
class ProjectileWaitBuff extends BuffDefinition
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
        AddModifier(new Vector3Modifier(EngineEntityProps.VELOCITY_DAMPEN, NumberOperator.Set, Vector3.one, VanillaModifierPriorities.FORCE));
    }
    public override function PostUpdate(buff:Buff):Void
    {
        super.PostUpdate(buff);
        var timeout = buff.GetProperty(PROP_TIMEOUT);
        if (timeout <= 0)
        {
            buff.Remove();
            return;
        }
        timeout--;
        buff.SetProperty(PROP_TIMEOUT, timeout);
    }
    public static var PROP_TIMEOUT:VanillaBuffPropertyMeta<Int> = new VanillaBuffPropertyMeta<Int>("Timeout");
}
