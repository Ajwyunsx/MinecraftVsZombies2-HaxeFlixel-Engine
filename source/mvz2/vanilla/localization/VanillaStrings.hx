// Ported from: Assets/Scripts/Vanilla/Frameworks/Localization/VanillaStrings.cs
package mvz2.vanilla.localization;

import mvz2logic.localization.LogicStrings;

class VanillaStrings
{
    @:translateMsg("教程无法使用提示")
    public static inline var TOOLTIP_DISABLE_MESSAGE:String = "无法使用";
    @:translateMsg("教程无法使用提示")
    public static inline var TOOLTIP_DECREPIFY:String = "受到衰老诅咒！";

    @:translateMsg("梦魇战斗提示", LogicStrings.CONTEXT_ADVICE)
    public static inline var ADVICE_CLICK_TO_DRAG_CRUSHING_WALLS:String = "点击屏幕阻止碾压墙！";
    @:translateMsg("红龙战斗提示", LogicStrings.CONTEXT_ADVICE)
    public static inline var ADVICE_CLICK_TO_EXTINGUISH_FIRE:String = "点击火焰来灭火！";
    @:translateMsg("获得新制品提示", LogicStrings.CONTEXT_ADVICE)
    public static inline var ADVICE_YOU_FOUND_A_NEW_ARTIFACT:String = "你找到了新制品！";
    @:translateMsg("剩余内容正在开发提示", LogicStrings.CONTEXT_ADVICE)
    public static inline var ADVICE_DEVELOPING:String = "剩余内容正在开发中，敬请期待！";
    @:translateMsg("无尽模式的提示", LogicStrings.CONTEXT_ADVICE)
    public static inline var ADVICE_ENDLESS_HINT:String = "你能存活多少轮？";
    @:translateMsg("无尽模式的提示", LogicStrings.CONTEXT_ADVICE)
    public static inline var ADVICE_MORE_ENEMIES_APPROACHING:String = "更多的怪物要来了！";
    @:translateMsg("欲望壶技能的提示，{0}为受到的总伤害", LogicStrings.CONTEXT_ADVICE, null, null, true)
    public static inline var ADVICE_NO_CARDS_DRAWN:String = "没有抽到牌！受到{0}点疲劳伤害！";
    @:translateMsg("欲望壶技能的提示", LogicStrings.CONTEXT_ADVICE)
    public static inline var ADVICE_NO_CARDS_DRAWN_CONVEYOR:String = "没有抽到牌！但那又怎样呢？";
    @:translateMsg("我是僵尸模式的提示，{0}为剩余轮数", LogicStrings.CONTEXT_ADVICE, null, null, true)
    public static inline var ADVICE_IZ_ROUNDS_LEFT:String = "干得好！还剩{0}轮！";
    @:translateMsg("我是僵尸模式的提示，{0}为目前连胜", LogicStrings.CONTEXT_ADVICE, null, null, true)
    public static inline var ADVICE_IZ_STREAK:String = "干得好！目前连胜：{0}！";
    @:translateMsg("重装兵器小游戏的提示", LogicStrings.CONTEXT_ADVICE)
    public static inline var ADVICE_HEAVY_WEAPON_TIP_MOUSE:String = "移动鼠标来移动，按住左键来射击！";
    @:translateMsg("重装兵器小游戏的提示", LogicStrings.CONTEXT_ADVICE)
    public static inline var ADVICE_HEAVY_WEAPON_TIP_TOUCH:String = "触摸屏幕来移动并射击！";

    @:translateMsg
    public static inline var UI_PURCHASE:String = "购买";
    @:translateMsg
    public static inline var UI_CONFIRM_BUY_7TH_SLOT:String = "购买第七个器械槽位？";
    @:translateMsg
    public static inline var UI_CONFIRM_TUTORIAL:String = "是否进行新手教程？";
    @:translateMsg
    public static inline var UI_TUTORIAL:String = "新手教程";
    @:translateMsg
    public static inline var UI_GAME_CLEARED:String = "通关";
    @:translateMsg
    public static inline var UI_COMING_SOON:String = "恭喜通关！\n接下来的内容还在开发中，敬请期待！";
    @:translateMsg("随机瓷器消息模板，{0}为事件名，{1}为事件描述")
    public static inline var RANDOM_CHINA_TEXT_TEMPLATE:String = "<color=#824400>{0}</color>\n{1}";

    @:translateMsg("充能时间", LogicStrings.CONTEXT_RECHARGE_TIME)
    public static inline var RECHARGE_NONE:String = "无";
    @:translateMsg("充能时间", LogicStrings.CONTEXT_RECHARGE_TIME)
    public static inline var RECHARGE_SHORT:String = "短";
    @:translateMsg("充能时间", LogicStrings.CONTEXT_RECHARGE_TIME)
    public static inline var RECHARGE_LONG:String = "长";
    @:translateMsg("充能时间", LogicStrings.CONTEXT_RECHARGE_TIME)
    public static inline var RECHARGE_VERY_LONG:String = "很长";

    @:translateMsg("对话档案对话框内容", LogicStrings.CONTEXT_ARCHIVE)
    public static inline var ARCHIVE_WHETHER_HAS_ENOUGH_MONEY:String = "是否拥有足够的金钱？";

    @:translateMsg("死亡信息-梦魇碾压墙", LogicStrings.CONTEXT_DEATH_MESSAGE)
    public static inline var DEATH_MESSAGE_CRUSHING_WALLS:String = "<color=red>来到我们之中吧</color>";
    @:translateMsg("死亡信息-我是僵尸", LogicStrings.CONTEXT_DEATH_MESSAGE)
    public static inline var DEATH_MESSAGE_IZ_LOSE_ALL_ENEMIES:String = "你失去了所有能量！";
    @:translateMsg("死亡信息-重装兵器", LogicStrings.CONTEXT_DEATH_MESSAGE)
    public static inline var DEATH_MESSAGE_SNIPENSER_LOST:String = "你失去了狙击发射器！";

    @:translateMsg("命令输出", LogicStrings.CONTEXT_COMMAND_OUTPUT)
    public static inline var COMMAND_CANNOT_BE_CALLED_IN_LEVEL:String = "该命令不能在关卡中调用";
    @:translateMsg("命令输出-help，{0}为命令名，{1}为命令描述", LogicStrings.CONTEXT_COMMAND_OUTPUT)
    public static inline var COMMAND_HELP_COMMAND_LIST_TEMPLATE:String = "/{0} - {1}";
    @:translateMsg("命令输出-help", LogicStrings.CONTEXT_COMMAND_OUTPUT)
    public static inline var COMMAND_HELP_DETAILS:String = "有关某个命令的详细信息，请输入\"/help <命令名>\"";
    @:translateMsg("命令输出-help，{0}为参数名，{1}为参数类型，{2}为参数描述", LogicStrings.CONTEXT_COMMAND_OUTPUT)
    public static inline var COMMAND_HELP_PARAMETER_TEMPLATE:String = "{0}: [{1}] {2}";
    @:translateMsg("命令输出-blueprint，{0}为参数", LogicStrings.CONTEXT_COMMAND_OUTPUT)
    public static inline var COMMAND_BLUEPRINT_SLOT_OUT_OF_RANGE:String = "蓝图槽位参数{0}超出范围";
    @:translateMsg("命令输出-cheat，{0}为参数", LogicStrings.CONTEXT_COMMAND_OUTPUT)
    public static inline var COMMAND_CHEAT_NOT_FOUND:String = "未找到作弊命令{0}";
    @:translateMsg("命令输出-cheat，{0}为作弊命令名", LogicStrings.CONTEXT_COMMAND_OUTPUT)
    public static inline var COMMAND_CHEAT_ENABLED:String = "已启用{0}";
    @:translateMsg("命令输出-cheat，{0}为作弊命令名", LogicStrings.CONTEXT_COMMAND_OUTPUT)
    public static inline var COMMAND_CHEAT_DISABLED:String = "已禁用{0}";
    @:translateMsg("命令输出-save", LogicStrings.CONTEXT_COMMAND_OUTPUT)
    public static inline var COMMAND_SAVE_SUCCESS:String = "已保存关卡状态";
    @:translateMsg("命令输出-unlock，{0}为游戏状态名", LogicStrings.CONTEXT_COMMAND_OUTPUT)
    public static inline var COMMAND_UNLOCK_ADD_SUCCESS:String = "已解锁游戏状态{0}";
    @:translateMsg("命令输出-unlock，{0}为游戏状态名", LogicStrings.CONTEXT_COMMAND_OUTPUT)
    public static inline var COMMAND_UNLOCK_ADD_FAILED_ALREADY_UNLOCKED:String = "无法解锁游戏状态{0}：该状态已被解锁";
    @:translateMsg("命令输出-unlock，{0}为游戏状态名", LogicStrings.CONTEXT_COMMAND_OUTPUT)
    public static inline var COMMAND_UNLOCK_REMOVE_SUCCESS:String = "已重新锁定游戏状态{0}";
    @:translateMsg("命令输出-unlock，{0}为游戏状态名", LogicStrings.CONTEXT_COMMAND_OUTPUT)
    public static inline var COMMAND_UNLOCK_REMOVE_FAILED_NOT_UNLOCKED:String = "无法重新锁定游戏状态{0}：该状态未被解锁";
    @:translateMsg("命令输出-unlock，{0}为游戏状态名列表", LogicStrings.CONTEXT_COMMAND_OUTPUT)
    public static inline var COMMAND_UNLOCK_ALL_SUCCESS:String = "已解锁游戏状态：\n{0}";
    @:translateMsg("命令输出-unlock", LogicStrings.CONTEXT_COMMAND_OUTPUT)
    public static inline var COMMAND_UNLOCK_ALL_FAILED_NOTHING_LOCKED:String = "无法解锁所有游戏状态：无游戏状态可解锁";
    @:translateMsg("命令输出-unlock，{0}为游戏状态名列表", LogicStrings.CONTEXT_COMMAND_OUTPUT)
    public static inline var COMMAND_UNLOCK_NONE_SUCCESS:String = "已重新锁定游戏状态：\n{0}";
    @:translateMsg("命令输出-unlock", LogicStrings.CONTEXT_COMMAND_OUTPUT)
    public static inline var COMMAND_UNLOCK_NONE_FAILED_NOTHING_UNLOCKED:String = "无法重新锁定游戏状态：无游戏状态可重新锁定";
    @:translateMsg("命令输出-izombie", LogicStrings.CONTEXT_COMMAND_OUTPUT)
    public static inline var COMMAND_NOT_IN_I_ZOMBIE_LEVEL:String = "当前关卡不是“我是僵尸”模式";

    @:translateMsg("作弊命令名称", CONTEXT_COMMAND_CHEAT_NAME)
    public static inline var CHEAT_NAME_GODMODE:String = "上帝模式";
    @:translateMsg("作弊命令名称", CONTEXT_COMMAND_CHEAT_NAME)
    public static inline var CHEAT_NAME_ENERGY:String = "无限能量";
    @:translateMsg("作弊命令名称", CONTEXT_COMMAND_CHEAT_NAME)
    public static inline var CHEAT_NAME_RECHARGE:String = "立即充能";
    @:translateMsg("作弊命令名称", CONTEXT_COMMAND_CHEAT_NAME)
    public static inline var CHEAT_NAME_STARSHARD:String = "无限星之碎片";

    public static inline var CONTEXT_COMMAND_CHEAT_NAME:String = "command.cheat_name";
    public static inline var CONTEXT_RANDOM_CHINA_EVENT_NAME:String = "random_china.event_name";
    public static inline var CONTEXT_RANDOM_CHINA_EVENT_DESCRIPTION:String = "random_china.event_description";

    @:translateMsg("上锁的箱子信息标题", CONTEXT_LOCKED_CHEST_MESSAGE)
    public static inline var LOCKED_CHEST_MESSAGE_TITLE:String = "勒索弹窗";
    @:translateMsg("上锁的箱子信息描述，{0}为需求1，{1}为需求2，{2}为招式名称", CONTEXT_LOCKED_CHEST_MESSAGE)
    public static inline var LOCKED_CHEST_MESSAGE_DESCRIPTION:String = "立刻给我{0}或{1}，否则我就要发动我的终极绝招“{2}”了！";

    @:translateMsg("上锁的箱子信息标题", CONTEXT_LOCKED_CHEST_MESSAGE)
    public static inline var LOCKED_CHEST_MESSAGE_SORRY:String = "哦不好意思";
    @:translateMsg("上锁的箱子信息描述", CONTEXT_LOCKED_CHEST_MESSAGE)
    public static inline var LOCKED_CHEST_MESSAGE_YOU_CHOOSE_NOTHING:String = "我忘说了，你选什么都没用。";

    @:translateMsg("上锁的箱子需求，{0}为花费的宝石量", CONTEXT_LOCKED_CHEST_MESSAGE, null, null, true)
    public static inline var LOCKED_CHEST_REQUIREMENT_MONEY:String = "{0}宝石";
    @:translateMsg("上锁的箱子需求，{0}为花费的星之碎片量", CONTEXT_LOCKED_CHEST_MESSAGE, null, null, true)
    public static inline var LOCKED_CHEST_REQUIREMENT_STARSHARD:String = "{0}星之碎片";

    @:translateMsg("上锁的箱子选项名", CONTEXT_LOCKED_CHEST_MESSAGE)
    public static inline var LOCKED_CHEST_OPTION_PAY:String = "支付{0}";
    @:translateMsg("上锁的箱子选项名", CONTEXT_LOCKED_CHEST_MESSAGE)
    public static inline var LOCKED_CHEST_OPTION_REJECT:String = "拒绝";
    @:translateMsg("上锁的箱子选项名", CONTEXT_LOCKED_CHEST_MESSAGE)
    public static inline var LOCKED_CHEST_OPTION_QUESTION:String = "？";

    @:translateMsg("上锁的箱子招式名", CONTEXT_LOCKED_CHEST_MESSAGE)
    public static inline var LOCKED_CHEST_ACTION_FIVE_SMASHES:String = "终极重压";
    @:translateMsg("上锁的箱子招式名", CONTEXT_LOCKED_CHEST_MESSAGE)
    public static inline var LOCKED_CHEST_ACTION_HYPERBEAM:String = "超能光束";
    @:translateMsg("上锁的箱子招式名", CONTEXT_LOCKED_CHEST_MESSAGE)
    public static inline var LOCKED_CHEST_ACTION_FOUR_SOULS:String = "爆破四魂";

    public static inline var CONTEXT_LOCKED_CHEST_MESSAGE:String = "locked_chest_message";

    @:translateMsg("上锁的箱子文本", CONTEXT_LOCKED_CHEST_TEXT)
    public static inline var LOCKED_CHEST_TEXT_BOMBS_ON_THE_WAY:String = "炸弹来咯！";
    @:translateMsg("上锁的箱子文本", CONTEXT_LOCKED_CHEST_TEXT)
    public static inline var LOCKED_CHEST_TEXT_IM_THE_BOMB:String = "我才是炸弹！";
    @:translateMsg("上锁的箱子文本", CONTEXT_LOCKED_CHEST_TEXT)
    public static inline var LOCKED_CHEST_TEXT_STOP:String = "你有完没完？";

    public static inline var CONTEXT_LOCKED_CHEST_TEXT:String = "locked_chest_text";
}
