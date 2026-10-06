// Ported from: Assets/Scripts/Vanilla/GameContent/Buffs/Contraption/Chapter2/DreamSilkBuff.cs
package mvz2.gamecontent.buffs.contraptions;

import mvz2.gamecontent.buffs.VanillaBuffNames;
import mvz2.gamecontent.effects.VanillaEffectID;
import mvz2.gamecontent.models.VanillaModelID;
import mvz2.gamecontent.pickups.VanillaPickupID;
import mvz2.vanilla.audios.VanillaSoundID;
import mvz2.vanilla.entities.VanillaEntityProps;
import mvz2.vanilla.models.VanillaModelKeys;
import mvz2.vanilla.properties.VanillaBuffPropertyMeta;
import mvz2logic.models.LogicModelHelper;
import pvzengine.buffs.Buff;
import pvzengine.callbacks.CallbackResult;
import pvzengine.callbacks.LevelCallbacks;
import pvzengine.definitions.BuffDefinition;
import pvzengine.entities.EngineEntityProps;
import pvzengine.entities.EntityTypes;
import pvzengine.modifiers.BooleanModifier;
import pvzengine.modifiers.NumberOperator;
import pvzengine.modifiers.Vector3Modifier;
import tools.FrameTimer;
import tools.Transitions;
import unity.Color;
import unity.Vector3;
import pvzengine.callbacks.LevelCallbacks.EntityDeathParams;
using mvz2logic.entities.LogicEntityExt;

@:autoBuffDefinition(VanillaBuffNames.Contraption_dreamSilk)
class DreamSilkBuff extends BuffDefinition
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
        AddModelInsertion(LogicModelHelper.ANCHOR_CENTER, VanillaModelKeys.dreamAlarm, VanillaModelID.dreamAlarm);
        AddModifier(new BooleanModifier(VanillaEntityProps.AI_FROZEN, true));
        AddModifier(new Vector3Modifier(EngineEntityProps.DISPLAY_SCALE, NumberOperator.Multiply, PROP_DISPLAY_SCALE));
        AddTrigger(LevelCallbacks.POST_ENTITY_DEATH, PostEntityDeathCallback, EntityTypes.PLANT);
    }
    public override function OnCreate(buff:Buff):Void
    {
        super.OnCreate(buff);
        buff.SetProperty(PROP_TIMER, new FrameTimer(MAX_TIMEOUT));
        buff.SetProperty(PROP_DISPLAY_SCALE, Vector3.one);
    }
    public override function PostUpdate(buff:Buff):Void
    {
        super.PostUpdate(buff);
        var contraption = buff.GetEntity();
        if (contraption == null)
            return;
        // Dream.
        var timer = buff.GetProperty(PROP_TIMER);
        if (timer == null)
        {
            buff.Remove();
            return;
        }
        timer.Run();
        if (timer.PassedFrame(RING_DURATION))
        {
            contraption.PlaySound(VanillaSoundID.dreamAlarm);
            contraption.PlaySound(VanillaSoundID.wakeup);
        }
        if (timer.Frame <= RING_DURATION)
        {
            var scale = Vector3.one;
            var t = 1 - timer.Frame / RING_DURATION;
            scale.y = GetDisplayScaleY(t * 2);
            buff.SetProperty(PROP_DISPLAY_SCALE, scale);
        }
        if (timer.Expired)
        {
            var level = buff.Level;
            var position = contraption.GetCenter();
            level.Spawn(VanillaPickupID.starshard, position, contraption);
            // C#: level.Spawn(VanillaEffectID.smokeCluster, position, contraption)?.Let(e => { e.SetTint(new Color(1, 0.8f, 1, 1)); });
            var smoke = level.Spawn(VanillaEffectID.smokeCluster, position, contraption);
            if (smoke != null)
            {
                smoke.SetTint(new Color(1, 0.8, 1, 1));
            }
            buff.Remove();
        }

        var model = buff.GetInsertedModel(VanillaModelKeys.dreamAlarm);
        if (model != null)
        {
            model.SetAnimationBool("Awake", timer.Frame <= RING_DURATION);
            model.SetAnimationFloat("Time", (timer.Frame - RING_DURATION) / (MAX_TIMEOUT - RING_DURATION));
        }
    }
    static function GetDisplayScaleY(percentage:Float):Float
    {
        if (percentage <= 0.25)
        {
            return 1 - 0.2 * Transitions.EaseInAndOut(percentage / 0.25);
        }
        else if (percentage <= 0.75)
        {
            return 0.8 + 0.45 * Transitions.EaseInAndOut((percentage - 0.25) / 0.5);
        }
        else if (percentage <= 1)
        {
            return 1.25 - 0.25 * Transitions.EaseInAndOut((percentage - 0.75) / 0.25);
        }
        return 1;
    }
    function PostEntityDeathCallback(param:EntityDeathParams, result:CallbackResult):Void
    {
        var entity = param.entity;
        var info = param.deathInfo;
        entity.RemoveBuffs(DreamSilkBuff);
    }
    public static var PROP_TIMER:VanillaBuffPropertyMeta<FrameTimer> = new VanillaBuffPropertyMeta<FrameTimer>("Timer");
    public static var PROP_DISPLAY_SCALE:VanillaBuffPropertyMeta<Vector3> = new VanillaBuffPropertyMeta<Vector3>("DisplayScale");
    public static inline var MAX_TIMEOUT:Int = 1500;
    static inline var RING_DURATION:Int = 36;
}
