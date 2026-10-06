// Ported from: Assets/Scripts/Vanilla/GameContent/Unlocks/VanillaUnlockID.cs
package mvz2.vanilla.unlocks;

import mvz2.gamecontent.stages.VanillaStageID.VanillaStageNames;
import mvz2.vanilla.VanillaMod;
import mvz2logic.unlocks.LogicUnlockNames;
import pvzengine.NamespaceID;

class VanillaUnlockNames
{
    public static inline var infectenser:String = "contraption.infectenser";
    public static inline var forcePad:String = "contraption.force_pad";

    public static inline var money:String = "money";
    public static inline var starshard:String = "starshard";
    public static inline var trigger:String = "trigger";

    public static inline var enteredDream:String = "entered_dream";
    public static inline var enteredGensokyo:String = "entered_gensokyo";

    public static inline var dreamIsNightmare:String = "dream_is_nightmare";
    public static inline var obsidianFirstAid:String = "obsidian_first_aid";

    public static inline var ghostBuster:String = "achievement.ghost_buster";
    public static inline var doubleTrouble:String = "achievement.double_trouble";
    public static inline var rickrollDrown:String = "achievement.rickroll_drown";
    public static inline var returnToSender:String = "achievement.return_to_sender";
    public static inline var mesmerisedMatchup:String = "achievement.mesmerised_matchup";
    public static inline var bonebreaker:String = "achievement.bonebreaker";
    public static inline var reforged:String = "achievement.reforged";
    public static inline var overdraw:String = "achievement.overdraw";
    public static inline var railgun:String = "achievement.railgun";
    public static inline var midasTouchdown:String = "achievement.midas_touchdown";
    public static inline var sculptingStrike:String = "achievement.sculpting_strike";
    public static inline var letThemEatCake:String = "achievement.let_them_eat_cake";

    public static inline var brokenLantern:String = "artifact.broken_lantern";
    public static inline var bottledBlackhole:String = "artifact.bottled_blackhole";
    public static inline var magmaStone:String = "artifact.magma_stone";
}

class VanillaUnlockID
{
    public static var halloween5:NamespaceID = GetStage(VanillaStageNames.halloween5);
    public static var halloween11:NamespaceID = GetStage(VanillaStageNames.halloween11);
    public static var dream5:NamespaceID = GetStage(VanillaStageNames.dream5);
    public static var dream7:NamespaceID = GetStage(VanillaStageNames.dream7);
    public static var dream11:NamespaceID = GetStage(VanillaStageNames.dream11);
    public static var castle1:NamespaceID = GetStage(VanillaStageNames.castle1);
    public static var castle5:NamespaceID = GetStage(VanillaStageNames.castle5);
    public static var mausoleum6:NamespaceID = GetStage(VanillaStageNames.mausoleum6);
    public static var trigger:NamespaceID = Get(VanillaUnlockNames.trigger);
    public static var starshard:NamespaceID = Get(VanillaUnlockNames.starshard);
    public static var money:NamespaceID = Get(VanillaUnlockNames.money);
    public static var enteredDream:NamespaceID = Get(VanillaUnlockNames.enteredDream);
    public static var enteredGensokyo:NamespaceID = Get(VanillaUnlockNames.enteredGensokyo);
    public static var dreamIsNightmare:NamespaceID = Get(VanillaUnlockNames.dreamIsNightmare);
    public static var obsidianFirstAid:NamespaceID = Get(VanillaUnlockNames.obsidianFirstAid);

    public static var ghostBuster:NamespaceID = Get(VanillaUnlockNames.ghostBuster);
    public static var doubleTrouble:NamespaceID = Get(VanillaUnlockNames.doubleTrouble);
    public static var rickrollDrown:NamespaceID = Get(VanillaUnlockNames.rickrollDrown);
    public static var returnToSender:NamespaceID = Get(VanillaUnlockNames.returnToSender);
    public static var mesmerisedMatchup:NamespaceID = Get(VanillaUnlockNames.mesmerisedMatchup);
    public static var bonebreaker:NamespaceID = Get(VanillaUnlockNames.bonebreaker);
    public static var reforged:NamespaceID = Get(VanillaUnlockNames.reforged);
    public static var overdraw:NamespaceID = Get(VanillaUnlockNames.overdraw);
    public static var railgun:NamespaceID = Get(VanillaUnlockNames.railgun);
    public static var midasTouchdown:NamespaceID = Get(VanillaUnlockNames.midasTouchdown);
    public static var sculptingStrike:NamespaceID = Get(VanillaUnlockNames.sculptingStrike);
    public static var letThemEatCake:NamespaceID = Get(VanillaUnlockNames.letThemEatCake);


    public static var brokenLantern:NamespaceID = Get(VanillaUnlockNames.brokenLantern);
    public static var bottledBlackhole:NamespaceID = Get(VanillaUnlockNames.bottledBlackhole);
    public static var magmaStone:NamespaceID = Get(VanillaUnlockNames.magmaStone);

    public static var blueprintSlot1:NamespaceID = Get(LogicUnlockNames.blueprintSlot1);
    static function Get(name:String):NamespaceID
    {
        return new NamespaceID(VanillaMod.spaceName, name);
    }
    static function GetStage(name:String):NamespaceID
    {
        return Get(LogicUnlockNames.GetLevelClearUnlock(name));
    }
}
