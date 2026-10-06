// Ported from: Assets/Scripts/Vanilla/GameContent/Enemies/Chapter1/BoneWall.cs
package mvz2.gamecontent.enemies;

import mvz2.gamecontent.effects.VanillaEffectID;
import mvz2.gamecontent.entities.AIEntityBehaviour;
import mvz2.vanilla.audios.VanillaSoundID;
import mvz2.vanilla.entities.VanillaEntityExt;
import mvz2logic.entities.LogicEntityExt;
import mvz2logic.level.LogicLevelExt;
import pvzengine.damages.DeathInfo;
import pvzengine.entities.Entity;
using mvz2.vanilla.entities.VanillaEntityExt;
using mvz2logic.entities.LogicEntityExt;

@:autoEntityBehaviourDefinition(VanillaEnemyNames.boneWall)
class BoneWall extends AIEntityBehaviour
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
    }
    public override function Init(entity:Entity):Void
    {
        super.Init(entity);
        entity.PlaySound(VanillaSoundID.boneWallBuild);
    }
    public override function PostDeath(entity:Entity, info:DeathInfo):Void
    {
        super.PostDeath(entity, info);
        if (entity.WillRemoveOnDeath(info))
            return;
        entity.Level.Spawn(VanillaEffectID.boneParticles, entity.GetCenter(), entity);
        entity.Remove();
    }
}
