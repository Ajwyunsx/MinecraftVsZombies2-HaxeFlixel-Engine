// Ported from: Assets/Scripts/Vanilla/GameContent/Enemies/Chapter12/Imp.cs
package mvz2.gamecontent.enemies;

import mvz2.gamecontent.buffs.enemies.IZombieImpBuff;
import mvz2.gamecontent.entities.AIEntityBehaviour;
import mvz2logic.level.LogicLevelExt;
import pvzengine.buffs.BuffExt;
import pvzengine.entities.Entity;

@:autoEntityBehaviourDefinition(VanillaEnemyNames.imp)
class Imp extends AIEntityBehaviour
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
    }
    public override function Init(entity:Entity):Void
    {
        super.Init(entity);
        if (entity.Level.IsIZombie())
        {
            entity.AddBuff(IZombieImpBuff);
        }
    }
}
