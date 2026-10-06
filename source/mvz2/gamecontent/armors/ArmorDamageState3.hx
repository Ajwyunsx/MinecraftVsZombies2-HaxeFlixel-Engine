// Ported from: Assets/Scripts/Vanilla/GameContent/Armors/ArmorDamageState3.cs
package mvz2.gamecontent.armors;

import mvz2.gamecontent.armors.VanillaArmorBehaviourID.VanillaArmorBehaviourNames;
import mvz2.vanilla.armors.VanillaArmorExt;
import pvzengine.armors.Armor;
import pvzengine.definitions.ArmorBehaviourDefinition;

@:autoArmorBehaviourDefinition(VanillaArmorBehaviourNames.damageState3)
class ArmorDamageState3 extends ArmorBehaviourDefinition
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
    }
    public override function PostUpdate(armor:Armor):Void
    {
        super.PostUpdate(armor);
        VanillaArmorExt.SetModelDamagePercent(armor);
    }
}
