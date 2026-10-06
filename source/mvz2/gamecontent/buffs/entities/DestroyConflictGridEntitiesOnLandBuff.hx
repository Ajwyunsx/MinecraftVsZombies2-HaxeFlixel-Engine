// Ported from: Assets/Scripts/Vanilla/GameContent/Buffs/Contraption/Chapter5/DestroyConflictGridEntitiesOnLandBuff.cs
// PORT-NOTE: 原 C# 文件位于 Contraption/Chapter5 目录下，但命名空间是 MVZ2.GameContent.Buffs.Entities，
// 故按 PORTING.md 的命名空间映射放入 mvz2.gamecontent.buffs.entities。
package mvz2.gamecontent.buffs.entities;

import mvz2.gamecontent.buffs.VanillaBuffNames;
import mvz2.vanilla.entities.VanillaEntityExt;
import pvzengine.buffs.Buff;
import pvzengine.definitions.BuffDefinition;

@:autoBuffDefinition(VanillaBuffNames.Entity_destroyConflictGridEntitiesOnLand)
class DestroyConflictGridEntitiesOnLandBuff extends BuffDefinition
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
    }
    public override function PostUpdate(buff:Buff):Void
    {
        super.PostUpdate(buff);
        var entity = buff.GetEntity();
        if (entity == null)
        {
            buff.Remove();
            return;
        }
        if (entity.IsOnGround)
        {
            VanillaEntityExt.DestroyConflictGridEntities(entity);
            buff.Remove();
        }
    }
}
