// Ported from: Assets/Scripts/Vanilla/GameContent/Contraptions/Upgrades/CommandBlock.cs
package mvz2.gamecontent.contraptions;

import mvz2.gamecontent.buffs.contraptions.ImitatedBuff;
import mvz2.gamecontent.buffs.entities.WhiteFlashBuff;
import mvz2.gamecontent.effects.VanillaEffectID;
import mvz2.vanilla.audios.VanillaSoundID;
import mvz2.vanilla.callbacks.VanillaLevelCallbacks;
import mvz2.vanilla.contraptions.VanillaContraptionExt;
import mvz2.vanilla.contraptions.VanillaContraptionStates;
import mvz2.vanilla.entities.VanillaEntityExt;
import mvz2.vanilla.entities.VanillaEntityProps;
import mvz2.vanilla.properties.VanillaEntityPropertyMeta;
import mvz2logic.Global;
import mvz2logic.entities.LogicEntityExt;
import mvz2logic.entities.LogicEntityProps;
import mvz2logic.grids.LogicGridExt;
import mvz2logic.level.LogicLevelExt;
import pvzengine.NamespaceID;
import pvzengine.buffs.BuffExt;
import pvzengine.callbacks.CallbackResult;
import pvzengine.definitions.EntityDefinition;
import pvzengine.entities.Entity;
import pvzengine.entities.SpawnParams;
import tools.FrameTimer;
using mvz2.vanilla.contraptions.VanillaContraptionExt;
using mvz2.vanilla.entities.VanillaEntityExt;
using mvz2.vanilla.entities.VanillaEntityProps;
using mvz2logic.entities.LogicContraptionProps;
using mvz2logic.entities.LogicEntityExt;
using mvz2logic.entities.LogicEntityProps;

@:autoEntityBehaviourDefinition(VanillaContraptionNames.commandBlock)
class CommandBlock extends ContraptionBehaviour
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
        AddTrigger(VanillaLevelCallbacks.CAN_CONTRAPTION_SACRIFICE, CanContraptionSacrificeCallback, VanillaContraptionID.commandBlock);
    }
    public override function Init(entity:Entity):Void
    {
        super.Init(entity);
        SetStateTimer(entity, new FrameTimer(IDLE_TIME));
    }
    override function UpdateAI(entity:Entity):Void
    {
        super.UpdateAI(entity);
        var stateTimer = GetStateTimer(entity);
        if (stateTimer == null)
        {
            TransformBlock(entity);
            return;
        }
        stateTimer.Run();
        if (stateTimer.Expired)
        {
            if (entity.State == STATE_IDLE)
            {
                stateTimer.ResetTime(WORK_TIME);
                entity.State = STATE_WORKING;
                entity.PlaySound(VanillaSoundID.dataStream);
            }
            else if (entity.State == STATE_WORKING)
            {
                TransformBlock(entity);
            }
        }
    }
    override function UpdateLogic(entity:Entity):Void
    {
        super.UpdateLogic(entity);
        var frozen = entity.IsAIFrozen();
        entity.SetAnimationBool("Working", !frozen && entity.State == STATE_WORKING);
    }
    public override function CanTrigger(entity:Entity):Bool
    {
        if (IsTriggered(entity))
            return false;
        var targetDef = GetEntityDefinitionToTransform(entity);
        if (targetDef != null && targetDef.CanInstantTrigger())
            return true;
        return super.CanTrigger(entity);
    }
    public override function CanEvoke(entity:Entity):Bool
    {
        var targetDef = GetEntityDefinitionToTransform(entity);
        if (targetDef == null)
            return false;
        if (!targetDef.WillInstantEvoke(entity.Level))
            return false;
        return super.CanEvoke(entity);
    }
    override function OnEvoke(entity:Entity):Void
    {
        super.OnEvoke(entity);
        entity.SetEvoked(true);
    }
    public override function Trigger(entity:Entity):Void
    {
        super.Trigger(entity);
        SetTriggered(entity, true);
        entity.PlaySound(VanillaSoundID.wakeup);
        WhiteFlashBuff.AddToEntity(entity, 15);
    }
    public static function TransformBlock(entity:Entity):Void
    {
        var targetID = GetEntityDefinitionToTransform(entity);
        if (targetID == null)
        {
            entity.Spawn(VanillaContraptionID.errorBlock, entity.Position);
            entity.PlaySound(VanillaSoundID.errorXP);
            entity.Remove();
            return;
        }
        var grid = entity.GetGrid();
        if (grid != null)
        {
            var spawnParams = entity.GetSpawnParams();
            spawnParams.SetProperty(LogicEntityProps.VARIANT, entity.GetVariant());
            var spawned = grid.SpawnPlacedEntity(targetID.GetID(), spawnParams);
            if (spawned != null)
            {
                spawned.AddBuff(ImitatedBuff);
                if (IsTriggered(entity) && spawned.CanTrigger())
                {
                    spawned.Trigger();
                }
                if (entity.IsEvoked() && spawned.CanEvoke())
                {
                    spawned.Evoke();
                }
            }
        }
        entity.Spawn(VanillaEffectID.binaryParticles, entity.GetCenter());

        entity.Remove();
    }
    static function GetEntityDefinitionToTransform(entity:Entity):Null<EntityDefinition>
    {
        var targetEntity = GetTargetEntity(entity);
        if (targetEntity == null)
            return null;
        var targetDef = entity.Level.Content.GetEntityDefinition(targetEntity);
        if (targetDef == null)
            return null;
        return targetDef;
    }
    public static function GetImitateSpawnParams(target:NamespaceID):SpawnParams
    {
        var spawnParam = new SpawnParams();
        spawnParam.SetProperty(PROP_TARGET_ENTITY, target);
        var definition = Global.Game.GetEntityDefinition(target);
        if (definition != null)
        {
            spawnParam.SetProperty(VanillaEntityProps.WATER_INTERACTION, VanillaEntityProps.GetWaterInteractionOfDefinition(definition));
            spawnParam.SetProperty(VanillaEntityProps.AIR_INTERACTION, VanillaEntityProps.GetAirInteractionOfDefinition(definition));
            spawnParam.SetProperty(LogicEntityProps.GRID_LAYERS, LogicEntityProps.GetGridLayersToTakeOfDefinition(definition));
        }
        return spawnParam;
    }
    function CanContraptionSacrificeCallback(param:ContraptionSacrificeValueParams, result:CallbackResult):Void
    {
        result.SetFinalValue(false);
    }
    public static function IsTriggered(entity:Entity):Bool return entity.GetBehaviourField(PROP_TRIGGERED);
    public static function SetTriggered(entity:Entity, timer:Bool):Void entity.SetBehaviourField(PROP_TRIGGERED, timer);
    public static function GetStateTimer(entity:Entity):Null<FrameTimer> return entity.GetBehaviourField(PROP_PRODUCTION_TIMER);
    public static function SetStateTimer(entity:Entity, timer:FrameTimer):Void entity.SetBehaviourField(PROP_PRODUCTION_TIMER, timer);
    public static function GetTargetEntity(entity:Entity):Null<NamespaceID> return entity.GetBehaviourField(PROP_TARGET_ENTITY);
    public static function SetTargetEntity(entity:Entity, value:NamespaceID):Void entity.SetBehaviourField(PROP_TARGET_ENTITY, value);
    public static inline var IDLE_TIME:Int = 69;
    public static inline var WORK_TIME:Int = 27;
    public static inline var STATE_IDLE:Int = VanillaContraptionStates.IDLE;
    public static inline var STATE_WORKING:Int = VanillaContraptionStates.COMMAND_BLOCK_WORKING;

    static var PROP_TRIGGERED:VanillaEntityPropertyMeta<Bool> = new VanillaEntityPropertyMeta<Bool>("triggered");
    static var PROP_PRODUCTION_TIMER:VanillaEntityPropertyMeta<FrameTimer> = new VanillaEntityPropertyMeta<FrameTimer>("ProductionTimer");
    static var PROP_TARGET_ENTITY:VanillaEntityPropertyMeta<NamespaceID> = new VanillaEntityPropertyMeta<NamespaceID>("TargetEntity");
}
