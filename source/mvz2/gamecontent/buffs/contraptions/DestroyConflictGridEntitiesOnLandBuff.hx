// Ported from: Assets/Scripts/Vanilla/GameContent/Buffs/Entity/Core/DestroyConflictGridEntitiesOnLandBuff.cs
// PORT-NOTE: 该 C# 文件的 namespace 为 MVZ2.GameContent.Buffs.Contraptions（与所在目录 Entity/Core 不一致），
//           按 PORTING.md「包名由 namespace 决定」的规则写入 mvz2.gamecontent.buffs.contraptions。
package mvz2.gamecontent.buffs.contraptions;

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
            VanillaEntityExt.DestroyConflictGridEntitiesOnLand(entity);
            buff.Remove();
        }
    }
}
