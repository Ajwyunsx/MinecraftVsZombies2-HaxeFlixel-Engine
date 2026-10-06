// Ported from: Assets/Scripts/Vanilla/GameContent/Contraptions/Chapter4/DesirePot.cs
package mvz2.gamecontent.contraptions;

import mvz2.gamecontent.buffs.entities.WhiteFlashBuff;
import mvz2.gamecontent.damages.VanillaDamageEffects;
import mvz2.gamecontent.pickups.BlueprintPickup;
import mvz2.gamecontent.pickups.VanillaPickupID;
import mvz2.vanilla.audios.VanillaSoundID;
import mvz2.vanilla.contraptions.VanillaContraptionStates;
import mvz2.vanilla.entities.VanillaEntityExt;
import mvz2.vanilla.localization.VanillaStrings;
import mvz2.vanilla.pickups.VanillaPickupProps;
import mvz2.vanilla.properties.VanillaEntityPropertyMeta;
import mvz2.vanilla.properties.VanillaLevelPropertyMeta;
import mvz2.vanilla.unlocks.VanillaUnlockID;
import mvz2logic.Global;
import mvz2logic.blueprints.LogicBlueprintID;
import mvz2logic.entities.LogicEntityExt;
import mvz2logic.entities.LogicEntityProps;
import mvz2logic.level.LogicLevelExt;
import mvz2logic.localization.LogicStrings;
import pvzengine.NamespaceID;
import pvzengine.damages.DamageEffectList;
import pvzengine.entities.Entity;
import pvzengine.level.LevelEngine;
import pvzengine.seedpacks.ClassicSeedPack;
import pvzengine.seedpacks.SeedPack;
import tools.FrameTimer;
import unity.Mathf;
import unity.Vector3;
using mvz2.vanilla.entities.VanillaEntityExt;
using mvz2logic.entities.LogicEntityExt;
import mvz2logic.blueprints.LogicSeedProps;

@:autoEntityBehaviourDefinition(VanillaContraptionNames.desirePot)
class DesirePot extends ContraptionBehaviour
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
    }
    public override function Init(entity:Entity):Void
    {
        super.Init(entity);
        SetEvocationTimer(entity, new FrameTimer(EVOCATION_COOLDOWN));
    }
    override function UpdateAI(entity:Entity):Void
    {
        super.UpdateAI(entity);
        if (entity.State == STATE_EVOKED)
        {
            EvokedUpdate(entity);
        }
    }
    override function UpdateLogic(entity:Entity):Void
    {
        super.UpdateLogic(entity);
        entity.SetModelProperty("Evoked", entity.State == STATE_EVOKED);
        entity.SetModelProperty("DuplicatedCount", GetDuplicatedCount(entity));
    }

    override function OnEvoke(entity:Entity):Void
    {
        super.OnEvoke(entity);

        var level = entity.Level;
        var selected = GetBlueprintsToCopy(entity);
        SpawnBlueprintPickups(entity, selected);

        var evocationTimer = GetEvocationTimer(entity);
        if (evocationTimer != null)
            evocationTimer.Reset();
        entity.State = STATE_EVOKED;
        WhiteFlashBuff.AddToEntity(entity, 30);
        entity.PlaySound(VanillaSoundID.arcaneIntellect);
        entity.PlaySound(VanillaSoundID.desirePotEvocation);
    }
    function EvokedUpdate(entity:Entity):Void
    {
        var evocationTimer = GetEvocationTimer(entity);
        if (evocationTimer.RunToExpiredAndNotNull())
        {
            WhiteFlashBuff.AddToEntity(entity, 30);
            entity.State = STATE_IDLE;
        }
    }
    function SpawnBlueprintPickups(entity:Entity, selected:Array<SeedPack>):Void
    {
        var selectedCount = selected.length;
        var minXSpeed = -3;
        var maxXSpeed = 3;

        var level = entity.Level;
        var drawnDesirePots = 0;
        var missDrawCount = 0;
        for (i in 0...selectedCount)
        {
            var seed = selected[i];
            if (seed == null)
            {
                missDrawCount++;
                continue;
            }
            var blueprintID = seed.GetDefinitionID();
            if (!NamespaceID.IsValid(blueprintID))
            {
                missDrawCount++;
                continue;
            }
            var spawnParams = entity.GetSpawnParams();
            spawnParams.SetProperty(VanillaPickupProps.CONTENT_ID, blueprintID);
            spawnParams.SetProperty(BlueprintPickup.PROP_COMMAND_BLOCK, LogicSeedProps.IsCommandBlockOfPack(seed));
            // C#: entity.Spawn(...)?.Let(e => { ... })
            var e = entity.Spawn(VanillaPickupID.blueprintPickup, entity.GetCenter(), spawnParams);
            if (e != null)
            {
                var xSpeed = 0.0;
                if (selectedCount > 1)
                {
                    xSpeed = minXSpeed + i / (selectedCount - 1) * (maxXSpeed - minXSpeed);
                }
                var vel = new Vector3(xSpeed, 7, 0);
                e.Velocity = vel;
            }


            if (Std.isOfType(seed, ClassicSeedPack))
            {
                seed.SetStartRecharge(false);
                seed.ResetRecharge();
            }


            if (blueprintID == LogicBlueprintID.FromEntity(VanillaContraptionID.desirePot))
            {
                drawnDesirePots++;
            }
        }


        if (missDrawCount > 0)
        {
            if (level.IsConveyorMode())
            {
                level.ShowAdvice(LogicStrings.CONTEXT_ADVICE, VanillaStrings.ADVICE_NO_CARDS_DRAWN_CONVEYOR, 0, 150, []);
            }
            else
            {
                var fatigueDamageSum = 0.0;
                for (i in 0...missDrawCount)
                {
                    fatigueDamageSum += Fatigue(entity);
                }
                level.ShakeScreen(10, 0, 15);
                var sum = Mathf.FloorToInt(fatigueDamageSum);
                LogicLevelExt.ShowAdvicePluralUsingKey(level, LogicStrings.CONTEXT_ADVICE, VanillaStrings.ADVICE_NO_CARDS_DRAWN, sum, 0, 150, [Std.string(sum)]);
                entity.PlaySound(VanillaSoundID.fatigue);
            }
        }

        if (drawnDesirePots >= 2)
        {
            Global.Saves.Unlock(VanillaUnlockID.overdraw);
            Global.Saves.SaveToFile(); // 完成成就后保存游戏。
        }
    }
    function GetBlueprintsToCopy(entity:Entity):Array<SeedPack>
    {
        var level = entity.Level;
        var heldBlueprints:Array<SeedPack>;
        if (level.IsConveyorMode())
        {
            heldBlueprints = [for (s in level.GetAllConveyorSeedPacks()) (s : SeedPack)];
        }
        else
        {
            // C#: level.GetAllSeedPacks().OfType<SeedPack>().Where(e => e.IsCharged())
            heldBlueprints = [for (s in level.GetAllSeedPacks()) if (s.IsCharged()) (s : SeedPack)];
        }
        // C#: heldBlueprints.TakeLast(EVOCATION_CARD_COUNT)
        var sourceBlueprints = heldBlueprints.slice(Std.int(Math.max(0, heldBlueprints.length - EVOCATION_CARD_COUNT)));

        var pile:Array<SeedPack> = [for (i in 0...EVOCATION_CARD_COUNT) null];
        var count = sourceBlueprints.length;
        for (i in 0...pile.length)
        {
            if (i >= count)
                continue;
            pile[i] = sourceBlueprints[i];
        }
        return pile;
    }
    function Fatigue(entity:Entity):Float
    {
        var level = entity.Level;
        var damage = GetFatigueDamage(level);
        damage += FATIGUE_INCREAMENT;
        SetFatigueDamage(level, damage);
        entity.Level.AddEnergy(-damage);
        return damage;
    }

    public static function DuplicateStarshard(pot:Entity):Void
    {
        pot.Spawn(VanillaPickupID.starshard, pot.GetCenter());
        var count = GetDuplicatedCount(pot);
        count++;
        SetDuplicatedCount(pot, count);
        if (count >= MAX_DUPLICATED_COUNT)
        {
            var effects = new DamageEffectList([VanillaDamageEffects.SELF_DAMAGE]);
            pot.Die(effects, pot);
        }
    }

    public static function GetEvocationTimer(entity:Entity):Null<FrameTimer> return entity.GetBehaviourField(PROP_EVOCATION_TIMER);
    public static function SetEvocationTimer(entity:Entity, timer:FrameTimer):Void entity.SetBehaviourField(PROP_EVOCATION_TIMER, timer);

    public static function GetDuplicatedCount(entity:Entity):Int return entity.GetBehaviourField(PROP_DUPLICATED_COUNT);
    public static function SetDuplicatedCount(entity:Entity, value:Int):Void entity.SetBehaviourField(PROP_DUPLICATED_COUNT, value);

    public static function GetFatigueDamage(level:LevelEngine):Float return level.GetProperty(PROP_FATIGUE_DAMAGE);
    public static function SetFatigueDamage(level:LevelEngine, value:Float):Void level.SetProperty(PROP_FATIGUE_DAMAGE, value);



    public static inline var EVOCATION_COOLDOWN:Int = 90;
    public static inline var EVOCATION_CARD_COUNT:Int = 2;
    public static inline var FATIGUE_INCREAMENT:Int = 25;
    public static inline var DETECT_INTERVAL:Int = 10;
    public static inline var MAX_DUPLICATED_COUNT:Int = 3;
    public static inline var STATE_IDLE:Int = VanillaContraptionStates.IDLE;
    public static inline var STATE_EVOKED:Int = VanillaContraptionStates.DESIRE_POT_EVOKED;
    public static inline var PROP_REGION:String = VanillaContraptionNames.desirePot;
    @:levelPropertyRegistry(PROP_REGION)
    static var PROP_FATIGUE_DAMAGE:VanillaLevelPropertyMeta<Float> = new VanillaLevelPropertyMeta<Float>("FatigueDamage");
    static var PROP_DUPLICATED_COUNT:VanillaEntityPropertyMeta<Int> = new VanillaEntityPropertyMeta<Int>("duplicated_count");
    static var PROP_EVOCATION_TIMER:VanillaEntityPropertyMeta<FrameTimer> = new VanillaEntityPropertyMeta<FrameTimer>("EvocationTimer");
}
