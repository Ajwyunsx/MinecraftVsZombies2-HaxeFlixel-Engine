// Ported from: Assets/Scripts/Vanilla/GameContent/Buffs/SeedPacks/Chapter2/SlenderManMindSwapBuff.cs
package mvz2.gamecontent.buffs.seedpacks;

import mvz2.gamecontent.buffs.VanillaBuffNames;
import mvz2.gamecontent.models.VanillaModelID;
import mvz2.vanilla.models.VanillaModelKeys;
import mvz2.vanilla.properties.VanillaBuffPropertyMeta;
import mvz2logic.blueprints.LogicSeedProps;
import mvz2logic.level.LogicLevelExt;
import mvz2logic.models.LogicModelHelper;
import pvzengine.NamespaceID;
import pvzengine.buffs.Buff;
import pvzengine.definitions.BuffDefinition;
using pvzengine.buffs.BuffTargetExt;
import pvzengine.seedpacks.EngineSeedProps;

@:autoBuffDefinition(VanillaBuffNames.SeedPack_slendermanMindSwap)
class SlenderManMindSwapBuff extends BuffDefinition
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
        AddModelInsertion(LogicModelHelper.ANCHOR_CENTER, VanillaModelKeys.mindSwap, VanillaModelID.mindSwap);
    }
    public override function PostAdd(buff:Buff):Void
    {
        super.PostAdd(buff);
        buff.SetProperty(PROP_TIMEOUT, 30);
    }
    public override function PostUpdate(buff:Buff):Void
    {
        super.PostUpdate(buff);
        var timeout = buff.GetProperty(PROP_TIMEOUT);
        timeout--;
        buff.SetProperty(PROP_TIMEOUT, timeout);

        if (timeout == 15)
        {
            TransformBlueprint(buff);
        }
        if (timeout <= 0)
        {
            buff.Remove();
        }
    }
    function TransformBlueprint(buff:Buff):Void
    {
        var seedPack = buff.GetSeedPack();
        if (seedPack == null)
            return;
        var targetID = buff.GetProperty(PROP_TARGET_ID);
        if (!NamespaceID.IsValid(targetID))
            return;
        var targetDefinition = buff.Level.Content.GetSeedDefinition(targetID);
        if (targetDefinition == null)
            return;
        seedPack.ChangeDefinition(targetDefinition);
        var drawn = EngineSeedProps.GetDrawnConveyorSeed(seedPack);
        if (NamespaceID.IsValid(drawn))
        {
            buff.Level.PutSeedToConveyorDiscardPile(drawn);
            EngineSeedProps.SetDrawnConveyorSeed(seedPack, null);
        }
        if (LogicLevelExt.IsHoldingBlueprint(buff.Level, seedPack))
        {
            LogicLevelExt.ResetHeldItem(buff.Level);
        }
    }
    public static var PROP_TIMEOUT:VanillaBuffPropertyMeta<Int> = new VanillaBuffPropertyMeta<Int>("Timeout");
    public static var PROP_TARGET_ID:VanillaBuffPropertyMeta<NamespaceID> = new VanillaBuffPropertyMeta<NamespaceID>("TargetID");
}
