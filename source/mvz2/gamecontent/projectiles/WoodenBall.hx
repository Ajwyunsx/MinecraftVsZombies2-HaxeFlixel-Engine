// Ported from: Assets/Scripts/Vanilla/GameContent/Projectiles/Chapter3/WoodenBall.cs
package mvz2.gamecontent.projectiles;

import mvz2.gamecontent.buffs.projectiles.HellfireIgnitedBuff;
import mvz2.gamecontent.contraptions.IHellfireIgniteBehaviour;
import mvz2.vanilla.entities.VanillaEntityExt;
import pvzengine.buffs.Buff;
import pvzengine.buffs.BuffExt;
import pvzengine.definitions.EntityBehaviourDefinition;
import pvzengine.entities.Entity;
using mvz2.vanilla.entities.VanillaEntityExt;

@:autoEntityBehaviourDefinition(VanillaProjectileNames.woodenBall)
class WoodenBall extends EntityBehaviourDefinition implements IHellfireIgniteBehaviour
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
    }
    public override function Update(projectile:Entity):Void
    {
        super.Update(projectile);
        UpdateIgnited(projectile);
    }
    public function Ignite(entity:Entity, hellfire:Entity, cursed:Bool):Void
    {
        var igniteBuff = entity.GetFirstBuff(HellfireIgnitedBuff);
        if (igniteBuff == null)
        {
            igniteBuff = entity.AddBuff(HellfireIgnitedBuff);
        }
        if (!HellfireIgnitedBuff.GetCursed(igniteBuff) && cursed)
        {
            HellfireIgnitedBuff.Curse(igniteBuff);
        }
    }
    function UpdateIgnited(projectile:Entity):Void
    {
        ignitedBuffBuffer = [];
        projectile.GetBuffsNonAlloc(HellfireIgnitedBuff, ignitedBuffBuffer);

        // 在水中移除普通火焰。
        if (projectile.IsInWater())
        {
            var i = ignitedBuffBuffer.length - 1;
            while (i >= 0)
            {
                var buff = ignitedBuffBuffer[i];
                if (!HellfireIgnitedBuff.GetCursed(buff))
                {
                    projectile.RemoveBuff(buff);
                    ignitedBuffBuffer.splice(i, 1);
                }
                i--;
            }
        }

        // 更新模型。
        var igniteState = 0;
        if (ignitedBuffBuffer.length > 0)
        {
            if (Lambda.exists(ignitedBuffBuffer, b -> HellfireIgnitedBuff.GetCursed(b)))
            {
                igniteState = 2;
            }
            else
            {
                igniteState = 1;
            }
        }
        projectile.SetModelProperty("IgniteState", igniteState);
    }
    var ignitedBuffBuffer:Array<Buff> = [];
}
