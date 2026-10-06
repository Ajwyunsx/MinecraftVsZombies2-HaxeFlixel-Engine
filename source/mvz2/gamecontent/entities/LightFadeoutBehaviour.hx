// Ported from: Assets/Scripts/Vanilla/GameContent/Entities/Behaviours/LightFadeoutBehaviour.cs
package mvz2.gamecontent.entities;

import mvz2.gamecontent.buffs.entities.LightFadeoutBuff;
import mvz2.vanilla.entities.VanillaEntityBehaviourNames;
import pvzengine.definitions.EntityBehaviourDefinition;
import pvzengine.entities.Entity;

@:autoEntityBehaviourDefinition(VanillaEntityBehaviourNames.lightFadeout)
class LightFadeoutBehaviour extends EntityBehaviourDefinition
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
    }
    public override function Init(entity:Entity):Void
    {
        super.Init(entity);
        entity.AddBuff(LightFadeoutBuff);
    }
}
