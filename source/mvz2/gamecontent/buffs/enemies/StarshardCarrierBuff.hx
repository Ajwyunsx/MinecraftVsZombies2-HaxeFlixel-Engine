// Ported from: Assets/Scripts/Vanilla/GameContent/Buffs/Enemies/Chapter1/StarshardCarrierBuff.cs
package mvz2.gamecontent.buffs.enemies;

import mvz2.gamecontent.buffs.VanillaBuffNames;
import mvz2.gamecontent.contraptions.VanillaContraptionID;
import mvz2.gamecontent.effects.VanillaEffectID;
import mvz2.gamecontent.pickups.VanillaPickupID;
import mvz2.vanilla.audios.VanillaSoundID;
import mvz2.vanilla.callbacks.VanillaLevelCallbacks;
import mvz2.vanilla.entities.VanillaEntityExt;
import mvz2.vanilla.properties.VanillaBuffPropertyMeta;
import mvz2logic.entities.LogicEntityExt;
import pvzengine.buffs.Buff;
import pvzengine.callbacks.CallbackResult;
import pvzengine.callbacks.EntityCallbackParams;
import pvzengine.definitions.BuffDefinition;
import pvzengine.entities.EngineEntityProps;
import pvzengine.entities.Entity;
import pvzengine.modifiers.ColorModifier;
import unity.Color;
import unity.Mathf;

@:autoBuffDefinition(VanillaBuffNames.Enemy_starshardCarrier)
class StarshardCarrierBuff extends BuffDefinition
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
        AddModifier(new ColorModifier(EngineEntityProps.COLOR_OFFSET, PROP_COLOR_OFFSET));
        AddTrigger(VanillaLevelCallbacks.ENEMY_DROP_REWARDS, PostEnemyDropRewardsCallback);
    }

    public override function PostAdd(buff:Buff):Void
    {
        super.PostAdd(buff);
        UpdateColorOffset(buff);
        UpdateDesirePot(buff);
    }
    public override function PostUpdate(buff:Buff):Void
    {
        super.PostUpdate(buff);
        UpdateColorOffset(buff);
    }
    private function UpdateDesirePot(buff:Buff):Void
    {
        var entity = buff.GetEntity();
        if (entity == null || !LogicEntityExt.IsVulnerableEntity(entity))
            return;

        var desirePotBuffer:Array<Entity> = [];
        entity.Level.FindEntitiesNonAlloc(function(e) return e.IsEntityOf(VanillaContraptionID.desirePot), desirePotBuffer);
        for (pot in desirePotBuffer)
        {
            // C#: pot.Spawn(...)?.Let(e => { e.SetParent(pot); pot.PlaySound(...); });
            var lump = pot.Spawn(VanillaEffectID.desireLump, entity.GetCenter());
            if (lump != null)
            {
                lump.SetParent(pot);
                LogicEntityExt.PlaySound(pot, VanillaSoundID.shadowCast);
            }
        }
    }
    private function UpdateColorOffset(buff:Buff):Void
    {
        var time = buff.GetProperty(PROP_TIME);
        time++;
        time %= MAX_TIME;
        var alpha = 1 - (Mathf.Cos(time / MAX_TIME * 360 * Mathf.Deg2Rad) + 1) / 2;
        alpha *= 0.8;
        buff.SetProperty(PROP_COLOR_OFFSET, new Color(0, 1, 0, alpha));
        buff.SetProperty(PROP_TIME, time);
    }
    private function PostEnemyDropRewardsCallback(param:EntityCallbackParams, result:CallbackResult):Void
    {
        var enemy = param.entity;
        var buffs = enemy.GetBuffs(StarshardCarrierBuff);
        for (buff in buffs)
        {
            enemy.Level.Spawn(VanillaPickupID.starshard, enemy.Position, enemy);
            buff.Remove();
        }
    }
    public static inline var MAX_TIME:Int = 60;
    public static var PROP_TIME:VanillaBuffPropertyMeta<Int> = new VanillaBuffPropertyMeta<Int>("Time");
    public static var PROP_COLOR_OFFSET:VanillaBuffPropertyMeta<Color> = new VanillaBuffPropertyMeta<Color>("ColorOffset");
}
