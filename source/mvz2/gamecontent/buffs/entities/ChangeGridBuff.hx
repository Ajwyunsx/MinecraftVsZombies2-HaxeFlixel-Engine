// Ported from: Assets/Scripts/Vanilla/GameContent/Buffs/Entity/Core/ChangeGridBuff.cs
package mvz2.gamecontent.buffs.entities;

import mvz2.gamecontent.buffs.VanillaBuffNames;
import mvz2.vanilla.entities.VanillaEntityExt;
import mvz2.vanilla.properties.VanillaBuffPropertyMeta;
import mvz2logic.entities.LogicEntityProps;
import pvzengine.buffs.Buff;
import pvzengine.definitions.BuffDefinition;

@:autoBuffDefinition(VanillaBuffNames.Entity_changeGrid)
class ChangeGridBuff extends BuffDefinition
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
    }
    public override function PostUpdate(buff:Buff):Void
    {
        super.PostUpdate(buff);
        var entity = buff.GetEntity();
        if (entity == null)
            return;
        var targetColumn = GetTargetColumn(buff);
        var targetLane = GetTargetLane(buff);
        if (targetColumn < 0 || targetColumn >= entity.Level.GetMaxColumnCount() || targetLane < 0 || targetLane >= entity.Level.GetMaxLaneCount())
        {
            buff.Remove();
            return;
        }

        var factor = GetChangeSpeedFactor(buff);
        // TODO-PORT: C# `entity.GetGridPivotOffset()`（引擎扩展方法）在当前 Haxe 工程中尚未提供，
        // 已确认存在的是 entityDef.GetGridPivotOffset()（mvz2logic.grids.LogicGridExt 中的调用点）。
        var gridPivotOffset = entity.GetGridPivotOffset();
        var revFactor = 1 - factor;
        var targetX = entity.Level.GetEntityColumnX(targetColumn) - gridPivotOffset.x;
        var targetZ = entity.Level.GetEntityLaneZ(targetLane) - gridPivotOffset.z;
        var pos = entity.Position;
        pos.x = pos.x * revFactor + targetX * factor;
        pos.z = pos.z * revFactor + targetZ * factor;
        var xDiff = pos.x - targetX;
        var zDiff = pos.z - targetZ;
        var sqrDistance = xDiff * xDiff + zDiff * zDiff;
        if (sqrDistance <= 1)
        {
            pos.x = targetX;
            pos.z = targetZ;
            Stop(buff);
        }
        entity.Position = pos;
    }
    public static function Start(buff:Buff, column:Int, lane:Int, speedFactor:Float = 0.5):Void
    {
        var level = buff.Level;
        SetTargetColumn(buff, column);
        SetTargetLane(buff, lane);
        SetChangeSpeedFactor(buff, speedFactor);
    }
    public static function Stop(buff:Buff):Void
    {
        var entity = buff.GetEntity();
        if (entity != null && LogicEntityProps.GetGridLayersToTake(entity) != null)
        {
            VanillaEntityExt.DestroyConflictGridEntities(entity);
        }
        buff.Remove();
    }
    public static function GetTargetLane(buff:Buff):Int return buff.GetProperty(PROP_TARGET_LANE);
    public static function SetTargetLane(buff:Buff, value:Int):Void buff.SetProperty(PROP_TARGET_LANE, value);
    public static function GetTargetColumn(buff:Buff):Int return buff.GetProperty(PROP_TARGET_COLUMN);
    public static function SetTargetColumn(buff:Buff, value:Int):Void buff.SetProperty(PROP_TARGET_COLUMN, value);
    public static function GetChangeSpeedFactor(buff:Buff):Float return buff.GetProperty(PROP_CHANGE_SPEED_FACTOR);
    public static function SetChangeSpeedFactor(buff:Buff, value:Float):Void buff.SetProperty(PROP_CHANGE_SPEED_FACTOR, value);
    public static var PROP_TARGET_COLUMN:VanillaBuffPropertyMeta<Int> = new VanillaBuffPropertyMeta<Int>("target_column");
    public static var PROP_TARGET_LANE:VanillaBuffPropertyMeta<Int> = new VanillaBuffPropertyMeta<Int>("target_lane");
    public static var PROP_CHANGE_SPEED_FACTOR:VanillaBuffPropertyMeta<Float> = new VanillaBuffPropertyMeta<Float>("change_speed_factor", 0.5);
}
