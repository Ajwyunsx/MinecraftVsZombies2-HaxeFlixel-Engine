// Ported from: Assets/Scripts/Vanilla/GameContent/Enemies/Chapter5/CannonballZombie.cs
package mvz2.gamecontent.enemies;

import mvz2.gamecontent.buffs.enemies.FlyBuff;
import mvz2.gamecontent.entities.AIEntityBehaviour;
import mvz2.vanilla.entities.VanillaEntityExt;
import pvzengine.buffs.BuffExt;
import pvzengine.entities.Entity;
using mvz2logic.entities.LogicEntityProps;

@:autoEntityBehaviourDefinition(VanillaEnemyNames.cannonballZombie)
class CannonballZombie extends AIEntityBehaviour
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
    }
    public override function Init(entity:Entity):Void
    {
        super.Init(entity);
        var buff = entity.AddBuff(FlyBuff);
        buff.SetProperty(FlyBuff.PROP_TARGET_HEIGHT, 20);
    }
    override function UpdateLogic(entity:Entity):Void
    {
        super.UpdateLogic(entity);
        entity.SetShadowHidden(entity.IsDead);
    }
}
