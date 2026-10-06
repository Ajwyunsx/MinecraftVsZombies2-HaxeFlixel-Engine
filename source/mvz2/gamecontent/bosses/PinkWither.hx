// Ported from: Assets/Scripts/Vanilla/GameContent/Bosses/PinkWither/PinkWither.cs
package mvz2.gamecontent.bosses;

import mvz2.vanilla.audios.VanillaSoundID;
import mvz2logic.entities.LogicEntityExt;
import pvzengine.entities.Entity;
import unity.Vector3;
using mvz2logic.entities.LogicEntityExt;

@:autoEntityBehaviourDefinition(VanillaBossNames.pinkWither)
class PinkWither extends BossBehaviour
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
    }

    override public function UpdateAI(entity:Entity):Void
    {
        super.UpdateAI(entity);

        if (entity.IsDead)
            return;

        if (entity.IsTimeInterval(CRY_INTERVAL))
        {
            entity.PlaySound(VanillaSoundID.witherCry, 2);
        }
        entity.Velocity += Vector3.up * 0.1;
        if (entity.Position.y > 800)
        {
            entity.Remove();
        }
    }
    public static inline var CRY_INTERVAL:Int = 100;
}
