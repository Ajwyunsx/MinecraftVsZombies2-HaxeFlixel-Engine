// Ported from: Assets/Scripts/Vanilla/GameContent/Contraptions/Chapter5/ElasticCloud/ElasticCloud_Evocation.cs
package mvz2.gamecontent.contraptions;

import mvz2.gamecontent.buffs.VanillaBuffID;
import mvz2.vanilla.entities.VanillaEntityBehaviourNames;
import mvz2.vanilla.entities.VanillaEntityExt;
import pvzengine.buffs.BuffExt;
import pvzengine.entities.Entity;
import unity.Vector3;

@:autoEntityBehaviourDefinition(VanillaEntityBehaviourNames.elasticCloud_Evocation)
class ElasticCloud_Evocation extends ContraptionEvokeBehaviour
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
    }
    public override function CanEvoke(entity:Entity):Bool
    {
        if (entity.HasBuff(VanillaBuffID.Contraption.elasticCloudEvocation))
            return false;
        return super.CanEvoke(entity);
    }
    public override function Evoke(entity:Entity):Void
    {
        super.Evoke(entity);
        entity.Velocity += Vector3.up * 30;
        entity.AddBuff(VanillaBuffID.Contraption.elasticCloudEvocation);
    }
}
