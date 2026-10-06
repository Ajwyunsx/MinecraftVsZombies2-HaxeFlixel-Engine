// Ported from: Assets/Scripts/Vanilla/GameContent/Buffs/Grids/Chapter5/GoldenGridBuff.cs
package mvz2.gamecontent.buffs.grids;

import mvz2.gamecontent.buffs.VanillaBuffNames;
import mvz2.gamecontent.models.VanillaModelID;
import mvz2.vanilla.grids.VanillaGridExt;
import mvz2.vanilla.models.VanillaModelKeys;
import mvz2.vanilla.properties.VanillaBuffPropertyMeta;
import mvz2logic.grids.LogicGridProps;
import mvz2logic.models.LogicModelHelper;
import mvz2logic.models.SortingLayers.ShaderProperties;
import pvzengine.NamespaceID;
import pvzengine.buffs.Buff;
import pvzengine.definitions.BuffDefinition;
import pvzengine.grids.LawnGrid;
import pvzengine.modifiers.BooleanModifier;
import tools.FrameTimer;
import tools.TimerHelper;
import unity.Color;

@:autoBuffDefinition(VanillaBuffNames.Grid_goldenGrid)
class GoldenGridBuff extends BuffDefinition
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
        AddModifier(new BooleanModifier(LogicGridProps.IS_WATER, false));
        AddModifier(new BooleanModifier(LogicGridProps.DISABLED, true));
        AddModelInsertion(LogicModelHelper.ANCHOR_CENTER, MODEL_KEY, VanillaModelID.goldenGrid);
    }
    public override function OnCreate(buff:Buff):Void
    {
        super.OnCreate(buff);
        buff.SetProperty(PROP_FLASH_TIMER, TimerHelper.NewSecondTimer(FLASH_SECONDS));
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
        var flashTimer = buff.GetProperty(PROP_FLASH_TIMER);
        if (flashTimer != null)
            flashTimer.Run();
        var timeoutTimer = buff.GetProperty(PROP_TIMEOUT_TIMER);
        if (timeoutTimer != null)
            timeoutTimer.Run();
        var passedHalf = (timeoutTimer != null ? timeoutTimer.GetPassedPercentage() : 0) >= 0.5;
        var targetDisappearValue = passedHalf ? 0.2 : 0;
        var disappearValue = buff.GetProperty(PROP_DISAPPEAR_VALUE);
        disappearValue = disappearValue * 0.5 + targetDisappearValue * 0.5;
        buff.SetProperty(PROP_DISAPPEAR_VALUE, disappearValue);
        UpdateModel(buff);
        if (timeoutTimer == null || timeoutTimer.Expired)
        {
            buff.Remove();
        }
    }
    public function UpdateModel(buff:Buff):Void
    {
        var grid = Std.downcast(buff.Target, LawnGrid);
        if (grid == null)
            return;
        var model = buff.GetInsertedModel(MODEL_KEY);
        if (model != null)
        {
            var flashTimer = buff.GetProperty(PROP_FLASH_TIMER);
            var c = flashTimer != null ? flashTimer.GetTimeoutPercentage() : 0;
            var colorOffset = new Color(c, c, c, 1);

            var timeoutTimer = buff.GetProperty(PROP_TIMEOUT_TIMER);

            model.SetModelProperty("GridType", VanillaGridExt.GetGridModelType(grid));
            model.SetShaderFloat(ShaderProperties.BURN_VALUE, buff.GetProperty(PROP_DISAPPEAR_VALUE));
            model.SetShaderColor(ShaderProperties.COLOR_OFFSET, colorOffset);
            model.ApplyShaderProperties();
        }
    }
    public static inline var FLASH_SECONDS:Float = 1;
    public static inline var MAX_TIMEOUT_SECONDS:Float = 120;
    public static var MODEL_KEY:NamespaceID = VanillaModelKeys.goldenGrid;
    public static var PROP_DISAPPEAR_VALUE:VanillaBuffPropertyMeta<Float> = new VanillaBuffPropertyMeta<Float>("disappear_value");
    public static var PROP_FLASH_TIMER:VanillaBuffPropertyMeta<FrameTimer> = new VanillaBuffPropertyMeta<FrameTimer>("flash_timer");
    public static var PROP_TIMEOUT_TIMER:VanillaBuffPropertyMeta<FrameTimer> = new VanillaBuffPropertyMeta<FrameTimer>("timeout_timer");
}
