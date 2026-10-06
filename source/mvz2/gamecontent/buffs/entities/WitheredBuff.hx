// Ported from: Assets/Scripts/Vanilla/GameContent/Buffs/Entity/Chapter3/WitheredBuff.cs
package mvz2.gamecontent.buffs.entities;

import mvz2.gamecontent.buffs.VanillaBuffNames;
import mvz2.gamecontent.damages.VanillaDamageEffects;
import mvz2.gamecontent.models.VanillaModelID;
import mvz2.vanilla.models.VanillaModelKeys;
import mvz2.vanilla.properties.VanillaBuffPropertyMeta;
import mvz2logic.models.LogicModelHelper;
import pvzengine.buffs.Buff;
import pvzengine.damages.DamageEffectList;
import pvzengine.definitions.BuffDefinition;
using mvz2.vanilla.entities.VanillaEntityExt;

@:autoBuffDefinition(VanillaBuffNames.Entity_withered)
class WitheredBuff extends BuffDefinition
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
        AddModelInsertion(LogicModelHelper.ANCHOR_CENTER, VanillaModelKeys.witherParticles, VanillaModelID.witherParticles);
    }
    public override function PostUpdate(buff:Buff):Void
    {
        super.PostUpdate(buff);

        var entity = buff.GetEntity();
        if (entity != null)
        {
            entity.TakeDamage(WITHER_DAMAGE, new DamageEffectList([VanillaDamageEffects.IGNORE_ARMOR, VanillaDamageEffects.MUTE]), entity);
        }

        var timeout = buff.GetProperty(PROP_TIMEOUT);
        timeout--;
        buff.SetProperty(PROP_TIMEOUT, timeout);
        if (timeout <= 0)
        {
            buff.Remove();
        }
    }
    public static var PROP_TIMEOUT:VanillaBuffPropertyMeta<Int> = new VanillaBuffPropertyMeta<Int>("Timeout");
    public static inline var WITHER_DAMAGE:Float = 1 / 3;
}
