// Ported from: Assets/Scripts/Vanilla/GameContent/Effects/Chapter5/WaterStainBlownBehaviour.cs
// PORT-NOTE: 原文件位于 Effects/Chapter5 下，但 C# 命名空间是 MVZ2.Vanilla.Entities，
// 按 PORTING.md 的「命名空间 → 包名」规则放在 mvz2.vanilla.entities 包。
package mvz2.vanilla.entities;

import mvz2.gamecontent.effects.WaterStain;
import pvzengine.definitions.EntityBehaviourDefinition;
import pvzengine.entities.Entity;

@:autoEntityBehaviourDefinition(VanillaEntityBehaviourNames.waterStainBlown)
class WaterStainBlownBehaviour extends EntityBehaviourDefinition implements IBeBlownBehaviour
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
    }

    public function BeBlown(entity:Entity, source:Entity):Void
    {
        if (WaterStain.IsStainFrozen(entity))
            return;
        WaterStain.Disappear(entity);
    }
}
