// Ported from: Assets/Scripts/Vanilla/GameContent/Contraptions/Upgrades/ErrorBlock.cs
package mvz2.gamecontent.contraptions;

import pvzengine.entities.Entity;

@:autoEntityBehaviourDefinition(VanillaContraptionNames.errorBlock)
class ErrorBlock extends ContraptionBehaviour
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
    }
    public override function CanEvoke(entity:Entity):Bool
    {
        return false;
    }
}
