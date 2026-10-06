// Ported from: Assets/Scripts/Vanilla/GameContent/Contraptions/Upgrades/BrickCannon_Evoke.cs
package mvz2.gamecontent.contraptions;

import mvz2.vanilla.entities.VanillaEntityBehaviourNames;
import mvz2.vanilla.audios.VanillaSoundID;
import mvz2.vanilla.entities.VanillaEntityExt;
import mvz2logic.entities.LogicEntityExt;
import mvz2logic.level.LogicLevelExt;
import pvzengine.entities.Entity;

// PORT-NOTE: C# 扩展方法 entity.PlaySound(...) 在 Haxe 侧以静态方法 + `using` 提供（PORTING.md §扩展方法）。
using mvz2logic.entities.LogicEntityExt;

@:autoEntityBehaviourDefinition(VanillaEntityBehaviourNames.brickCannon_Evoke)
class Brickcannon_Evoke extends ContraptionEvokeBehaviour
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
    }
    public override function CanEvoke(entity:Entity):Bool
    {
        if (entity.State == BrickCannon.STATE_LAUNCH || BrickCannon.IsDanger(entity))
            return false;
        return super.CanEvoke(entity);
    }
    public override function Evoke(entity:Entity):Void
    {
        super.Evoke(entity);
        BrickCannon.ReloadImmediate(entity);
        BrickCannon.SetDanger(entity, true);
        entity.PlaySound(VanillaSoundID.reverseVampire);
    }
}
