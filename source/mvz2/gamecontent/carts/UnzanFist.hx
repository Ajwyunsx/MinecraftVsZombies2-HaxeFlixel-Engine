// Ported from: Assets/Scripts/Vanilla/GameContent/Carts/UnzanFist.cs
package mvz2.gamecontent.carts;

import mvz2.gamecontent.carts.VanillaCartID.VanillaCartNames;
import mvz2.vanilla.audios.VanillaSoundID;
import mvz2.vanilla.entities.VanillaEntityExt;
import mvz2logic.entities.LogicEntityExt;
import pvzengine.entities.Entity;
import unity.Vector3;

@:autoEntityBehaviourDefinition(VanillaCartNames.unzanFist)
class UnzanFist extends CartBehaviour
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
    }
    public override function PostCrush(entity:Entity, other:Entity):Void
    {
        super.PostCrush(entity, other);
        LogicEntityExt.PlaySound(entity, VanillaSoundID.punch);
        other.Velocity += VanillaEntityExt.GetFacingDirection(entity) * 40.0 + Vector3.up * 20.0;
    }
}
