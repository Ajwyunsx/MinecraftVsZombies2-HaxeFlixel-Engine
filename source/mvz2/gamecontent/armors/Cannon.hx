// Ported from: Assets/Scripts/Vanilla/GameContent/Armors/Cannon.cs
package mvz2.gamecontent.armors;

import mvz2.gamecontent.armors.VanillaArmorBehaviourID.VanillaArmorBehaviourNames;
import mvz2.gamecontent.buffs.VanillaBuffID;
import mvz2.gamecontent.enemies.VanillaEnemyID;
import mvz2.gamecontent.fragments.VanillaFragmentID;
import mvz2.vanilla.audios.VanillaSoundID;
import mvz2.vanilla.effects.FragmentExt;
import mvz2.vanilla.entities.VanillaEntityExt;
import mvz2.vanilla.entities.VanillaEntityProps;
import mvz2.vanilla.properties.VanillaArmorPropertyMeta;
import mvz2logic.entities.LogicEnemyStates;
import mvz2logic.entities.LogicEntityExt;
import mvz2logic.entities.LogicEntityProps;
import pvzengine.armors.Armor;
import pvzengine.auras.AuraEffect;
import pvzengine.auras.AuraEffectDefinition;
import pvzengine.buffs.IBuffTarget;
import pvzengine.callbacks.CallbackResult;
import pvzengine.callbacks.LevelCallbacks;
import pvzengine.definitions.ArmorBehaviourDefinition;
import tools.FrameTimer;
import unity.Vector3;

@:autoArmorBehaviourDefinition(VanillaArmorBehaviourNames.cannon)
class Cannon extends ArmorBehaviourDefinition
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
        AddTrigger(LevelCallbacks.POST_DESTROY_ARMOR, PostArmorDestroyCallback);
        AddAura(new HeavyAura());
    }
    public override function PostUpdate(armor:Armor):Void
    {
        super.PostUpdate(armor);
        var owner = armor.Owner;
        if (!owner.ExistsAndAlive() || VanillaEntityProps.IsAIFrozen(owner))
            return;
        if (owner.State == STATE_IDLE || owner.State == STATE_MELEE_ATTACK)
        {
            return;
        }
        var timer = GetTimer(armor);
        if (timer == null)
        {
            timer = new FrameTimer(SHOOT_INTERVAL);
            SetTimer(armor, timer);
        }
        timer.Run();
        if (timer.Expired)
        {
            timer.Reset();

            var pos = owner.Position + LogicEntityExt.GetArmorOffset(owner, armor.Slot, armor.Definition.GetID()) + VanillaEntityExt.GetFacingDirection(owner) * 20 + new Vector3(0, -12, 0);
            VanillaEntityExt.SpawnWithParams(owner, VanillaEnemyID.cannonballZombie, pos);
            var multiplier = VanillaEntityProps.GetWeakKnockbackMultiplier(owner);
            owner.Velocity -= VanillaEntityExt.GetFacingDirection(owner) * (5 * multiplier);
            LogicEntityExt.PlaySound(owner, VanillaSoundID.smallExplosion);
        }
    }
    function PostArmorDestroyCallback(param:PostArmorDestroyParams, result:CallbackResult):Void
    {
        var entity = param.entity;
        var armor = param.armor;
        var info = param.info;
        if (!armor.Definition.HasBehaviour(this))
            return;
        var pos = entity.Position + new Vector3(VanillaEntityExt.GetFacingX(entity) * 20, 40, 0);
        // PORT-NOTE: C# 是带 position 的重载 CreateFragmentAndPlay(pos, id, emitSpeed)；Haxe 侧改名为 CreateFragmentAndPlayAt。
        FragmentExt.CreateFragmentAndPlayAt(entity, pos, VanillaFragmentID.cannon, 500);
    }
    public static function GetTimer(armor:Armor):Null<FrameTimer> return armor.GetProperty(PROP_TIMER);
    public static function SetTimer(armor:Armor, value:FrameTimer):Void armor.SetProperty(PROP_TIMER, value);
    public static inline var SHOOT_INTERVAL:Int = 240;
    public static inline var STATE_IDLE:Int = LogicEnemyStates.IDLE;
    public static inline var STATE_MELEE_ATTACK:Int = LogicEnemyStates.MELEE_ATTACK;

    public static var PROP_TIMER:VanillaArmorPropertyMeta<FrameTimer> = new VanillaArmorPropertyMeta<FrameTimer>("timer");
}

// PORT-NOTE: C# 嵌套类 Cannon.HeavyAura → Haxe 模块子类型，访问路径一致。
class HeavyAura extends AuraEffectDefinition
{
    public function new()
    {
        super(VanillaBuffID.Enemy.heavyCannon, 4);
    }

    public override function GetAuraTargets(auraEffect:AuraEffect, results:Array<IBuffTarget>):Void
    {
        var armor = Std.isOfType(auraEffect.Source, Armor) ? (cast auraEffect.Source : Armor) : null;
        if (armor == null)
            return;
        results.push(armor.Owner);
    }
}
