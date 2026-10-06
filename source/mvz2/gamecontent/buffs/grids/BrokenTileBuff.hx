// Ported from: Assets/Scripts/Vanilla/GameContent/Buffs/Grids/Chapter6/BrokenTileBuff.cs
package mvz2.gamecontent.buffs.grids;

import mvz2.gamecontent.buffs.VanillaBuffNames;
import mvz2.gamecontent.models.VanillaModelID;
import mvz2.vanilla.grids.VanillaGridExt;
import mvz2.vanilla.models.VanillaModelKeys;
import mvz2.vanilla.properties.VanillaBuffPropertyMeta;
import mvz2logic.grids.LogicGridProps;
import mvz2logic.models.LogicModelHelper;
import pvzengine.NamespaceID;
import pvzengine.buffs.Buff;
import pvzengine.definitions.BuffDefinition;
import pvzengine.grids.LawnGrid;
import pvzengine.modifiers.BooleanModifier;
import tools.FrameTimer;
import tools.TimerHelper;

@:autoBuffDefinition(VanillaBuffNames.Grid_brokenTile)
class BrokenTileBuff extends BuffDefinition
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
        AddModifier(new BooleanModifier(LogicGridProps.DISABLED, true));
        AddModelInsertion(LogicModelHelper.ANCHOR_CENTER, MODEL_KEY, VanillaModelID.brokenTile);
    }
    public override function OnCreate(buff:Buff):Void
    {
        super.OnCreate(buff);
        buff.SetProperty(PROP_TIMEOUT_TIMER, TimerHelper.NewSecondTimer(MAX_TIMEOUT_SECONDS));
    }
    public override function PostAdd(buff:Buff):Void
    {
        super.PostAdd(buff);
        UpdateModel(buff);
    }
    public override function PostUpdate(buff:Buff):Void
    {
        super.PostUpdate(buff);
        var timeoutTimer = buff.GetProperty(PROP_TIMEOUT_TIMER);
        // C#: timeoutTimer.RunToExpiredOrNull()（FrameTimer 的扩展方法，计时器为 null 时也返回 true）
        if (timeoutTimer == null || timeoutTimer.RunToExpired())
        {
            buff.Remove();
        }
        UpdateModel(buff);
    }
    public function UpdateModel(buff:Buff):Void
    {
        var grid = Std.downcast(buff.Target, LawnGrid);
        if (grid == null)
            return;
        var model = buff.GetInsertedModel(MODEL_KEY);
        if (model != null)
        {
            var timeoutTimer = buff.GetProperty(PROP_TIMEOUT_TIMER);
            var decayed = (timeoutTimer != null ? timeoutTimer.GetPassedPercentage() : 0) >= 0.5;

            model.SetModelProperty("GridType", VanillaGridExt.GetGridModelType(grid));
            model.SetModelProperty("Decayed", decayed);
            model.SortingOrder = 100;
        }
    }
    public static function Break(grid:LawnGrid):Void
    {
        var buff = grid.GetFirstBuff(BrokenTileBuff);
        if (buff == null)
        {
            grid.AddBuff(BrokenTileBuff);
        }
        else
        {
            var timeoutTimer = buff.GetProperty(PROP_TIMEOUT_TIMER);
            if (timeoutTimer != null)
                timeoutTimer.Reset();
        }
    }
    public static inline var MAX_TIMEOUT_SECONDS:Float = 180;
    public static var MODEL_KEY:NamespaceID = VanillaModelKeys.brokenTile;
    public static var PROP_TIMEOUT_TIMER:VanillaBuffPropertyMeta<FrameTimer> = new VanillaBuffPropertyMeta<FrameTimer>("timeout_timer");
}
