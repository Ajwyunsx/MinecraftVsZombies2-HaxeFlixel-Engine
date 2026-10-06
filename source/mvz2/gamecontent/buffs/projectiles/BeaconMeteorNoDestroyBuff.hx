// Ported from: Assets/Scripts/Vanilla/GameContent/Buffs/Projectiles/Chapter5/BeaconMeteorNoDestroyBuff.cs
package mvz2.gamecontent.buffs.projectiles;

import mvz2.gamecontent.buffs.VanillaBuffNames;
import mvz2.vanilla.projectiles.VanillaProjectileProps;
import pvzengine.buffs.Buff;
import pvzengine.definitions.BuffDefinition;
import pvzengine.modifiers.BooleanModifier;

@:autoBuffDefinition(VanillaBuffNames.Projectile_beaconMeteorNoDestroy)
class BeaconMeteorNoDestroyBuff extends BuffDefinition
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
        AddModifier(new BooleanModifier(VanillaProjectileProps.NO_DESTROY_OUTSIDE_LAWN, true));
    }
    public override function PostUpdate(buff:Buff):Void
    {
        super.PostUpdate(buff);
        var entity = buff.GetEntity();
        if (entity == null)
            return;
        if (entity.GetRelativeY() <= 80)
        {
            buff.Remove();
        }
    }
}
