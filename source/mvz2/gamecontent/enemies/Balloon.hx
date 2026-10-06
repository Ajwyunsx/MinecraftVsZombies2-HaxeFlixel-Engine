// Ported from: Assets/Scripts/Vanilla/GameContent/Enemies/Chapter6/Balloon.cs
package mvz2.gamecontent.enemies;

import mvz2.gamecontent.bosses.LockedChest;
import mvz2.gamecontent.bosses.VanillaBossID;
import mvz2.gamecontent.buffs.VanillaBuffID;
import mvz2.gamecontent.buffs.enemies.FlyBuff;
import mvz2.vanilla.entities.VanillaEntityBehaviourNames;
import mvz2.vanilla.entities.VanillaEntityExt;
import pvzengine.auras.AuraEffect;
import pvzengine.auras.AuraEffectDefinition;
import pvzengine.auras.IBuffTarget;
import pvzengine.buffs.BuffExt;
import pvzengine.damages.DeathInfo;
import pvzengine.definitions.EntityBehaviourDefinition;
import pvzengine.entities.Entity;
import unity.Vector3;
import mvz2.gamecontent.artifacts.CenserOfForgotten;

@:autoEntityBehaviourDefinition(VanillaEntityBehaviourNames.balloon)
class Balloon extends EntityBehaviourDefinition
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
        AddAura(new BalloonDragAura());
    }

    public override function Init(entity:Entity):Void
    {
        super.Init(entity);
        var buff = entity.AddBuff(FlyBuff);
        buff.SetProperty(FlyBuff.PROP_TARGET_HEIGHT, 120);
    }
    public override function Update(entity:Entity):Void
    {
        super.Update(entity);
        if (entity.Parent != null)
        {
            DragParent(entity, entity.Parent);
        }
    }
    public override function PostDeath(entity:Entity, deathInfo:DeathInfo):Void
    {
        super.PostDeath(entity, deathInfo);
        var parent = entity.Parent;
        if (parent != null && parent.IsEntityOf(VanillaBossID.lockedChest))
        {
            LockedChest.Stun(parent, 10);
        }
    }
    public static function DragParent(entity:Entity, parent:Entity):Void
    {
        parent.SetCenter(entity.Position + Vector3.back * 3);
    }
}

// PORT-NOTE: C# 的嵌套类 Balloon.DragAura 提升为模块级类 BalloonDragAura（Haxe 不支持嵌套类）。
class BalloonDragAura extends AuraEffectDefinition
{
    public function new()
    {
        super(VanillaBuffID.Entity.draggedByBalloon, 1);
    }

    public override function GetAuraTargets(auraEffect:AuraEffect, results:Array<IBuffTarget>):Void
    {
        var source = auraEffect.Source.GetEntity();
        if (source == null)
            return;
        if (source.Parent != null)
        {
            results.push(source.Parent);
        }
    }
}
