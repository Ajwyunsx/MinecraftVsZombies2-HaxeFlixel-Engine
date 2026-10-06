// Ported from: Assets/Scripts/Vanilla/GameContent/Buffs/SeedPacks/Chapter6/BlueprintLockBuff.cs
package mvz2.gamecontent.buffs.seedpacks;

import mvz2.gamecontent.buffs.VanillaBuffNames;
import mvz2.gamecontent.models.VanillaModelID;
import mvz2.gamecontent.seeds.VanillaBlueprintErrors;
import mvz2.vanilla.models.VanillaModelKeys;
import mvz2.vanilla.properties.VanillaBuffPropertyMeta;
import mvz2logic.models.LogicModelHelper;
import pvzengine.buffs.Buff;
import pvzengine.definitions.BuffDefinition;
import pvzengine.level.EngineSeedProps;
import pvzengine.modifiers.NamespaceIDModifier;
import pvzengine.modifiers.SetOperator;
import tools.FrameTimer;
import tools.TimerHelper;

@:autoBuffDefinition(VanillaBuffNames.SeedPack_blueprintLock)
class BlueprintLockBuff extends BuffDefinition
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
        AddModelInsertion(LogicModelHelper.ANCHOR_CENTER, VanillaModelKeys.blueprintLock, VanillaModelID.blueprintLock);
        AddModifier(new NamespaceIDModifier(EngineSeedProps.DISABLE_ID, SetOperator.Set, VanillaBlueprintErrors.locked));
    }
    public override function OnCreate(buff:Buff):Void
    {
        super.OnCreate(buff);
        SetTimer(buff, TimerHelper.NewSecondTimer(LOCK_TIME_SECONDS));
    }
    public override function PostUpdate(buff:Buff):Void
    {
        super.PostUpdate(buff);
        var timer = GetTimer(buff);
        // C#: timer.RunToExpiredOrNull()（FrameTimer 的扩展方法，计时器为 null 时也返回 true）
        if (timer == null || timer.RunToExpired())
        {
            buff.Remove();
        }
    }
    public static function GetTimer(buff:Buff):Null<FrameTimer> return buff.GetProperty(PROP_TIMER);
    public static function SetTimer(buff:Buff, value:Null<FrameTimer>):Void buff.SetProperty(PROP_TIMER, value);
    public static inline var LOCK_TIME_SECONDS:Float = 30;
    public static var PROP_TIMER:VanillaBuffPropertyMeta<FrameTimer> = new VanillaBuffPropertyMeta<FrameTimer>("timer");
}
