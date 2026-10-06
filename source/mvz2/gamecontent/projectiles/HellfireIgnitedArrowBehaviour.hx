// Ported from: Assets/Scripts/Vanilla/GameContent/Projectiles/Chapter4/HellfireIgniteArrowBehaviour.cs
package mvz2.gamecontent.projectiles;

import mvz2.gamecontent.buffs.projectiles.HellfireIgnitedBuff;
import mvz2.gamecontent.contraptions.IHellfireIgniteBehaviour;
import mvz2.vanilla.entities.VanillaEntityBehaviourNames;
import pvzengine.buffs.Buff;
import pvzengine.buffs.BuffExt;
import pvzengine.definitions.EntityBehaviourDefinition;
import pvzengine.entities.Entity;

// PORT-NOTE: C# 扩展方法（Entity 的 GetBuffs/RemoveBuff/GetFirstBuff/AddBuff、IsInWater、SetAnimationInt）
// 在 Haxe 侧以静态方法 + `using` 提供（PORTING.md §扩展方法）。
using mvz2.vanilla.entities.VanillaEntityExt;
using pvzengine.buffs.BuffTargetExt;
using pvzengine.models.HasModelExt;

@:autoEntityBehaviourDefinition(VanillaEntityBehaviourNames.hellfireIgnitedArrow)
class HellfireIgnitedArrowBehaviour extends EntityBehaviourDefinition implements IHellfireIgniteBehaviour
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
    }
    public override function Update(projectile:Entity):Void
    {
        super.Update(projectile);
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
        var ignited = 0;
        if (ignitedBuffBuffer.length > 0)
        {
            if (Lambda.exists(ignitedBuffBuffer, b -> HellfireIgnitedBuff.GetCursed(b)))
            {
                ignited = 2;
            }
            else
            {
                ignited = 1;
            }
        }
        projectile.SetAnimationInt("Ignited", ignited);
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
    var ignitedBuffBuffer:Array<Buff> = [];
}
