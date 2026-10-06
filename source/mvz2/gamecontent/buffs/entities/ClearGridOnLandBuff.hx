// Ported from: Assets/Scripts/Vanilla/GameContent/Buffs/Entity/Chapter5/ClearGridOnLandBuff.cs
package mvz2.gamecontent.buffs.entities;

import mvz2.gamecontent.buffs.VanillaBuffNames;
import mvz2.vanilla.entities.VanillaEntityExt;
import pvzengine.buffs.Buff;
import pvzengine.definitions.BuffDefinition;

@:autoBuffDefinition(VanillaBuffNames.Entity_clearGridOnLand)
class ClearGridOnLandBuff extends BuffDefinition
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
            return;
        if (entity.IsOnGround)
        {
            VanillaEntityExt.DestroyConflictGridEntities(entity);
            buff.Remove();
        }
    }
}
