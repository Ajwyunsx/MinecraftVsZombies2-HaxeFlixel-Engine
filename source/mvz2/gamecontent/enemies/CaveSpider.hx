// Ported from: Assets/Scripts/Vanilla/GameContent/Enemies/Chapter2/CaveSpider.cs
package mvz2.gamecontent.enemies;

import mvz2.gamecontent.entities.AIEntityBehaviour;

@:autoEntityBehaviourDefinition(VanillaEnemyNames.caveSpider)
class CaveSpider extends AIEntityBehaviour
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
    }
}
