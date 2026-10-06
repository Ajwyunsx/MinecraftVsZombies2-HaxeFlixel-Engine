// Ported from: Assets/Scripts/Logic/Localization/LogicStrings.cs
package mvz2logic.localization;

import pvzengine.NamespaceID;

class LogicStrings
{
	// [TranslateMsg("通用的是")]
	public static inline var YES:String = "是";
	// [TranslateMsg("通用的否")]
	public static inline var NO:String = "否";
	// [TranslateMsg("通用的开")]
	public static inline var ON:String = "开";
	// [TranslateMsg("通用的关")]
	public static inline var OFF:String = "关";
	// [TranslateMsg("通用的返回")]
	public static inline var BACK:String = "返回";
	// [TranslateMsg("通用文本")]
	public static inline var RESTART:String = "重新开始";
	// [TranslateMsg("通用文本")]
	public static inline var BACK_TO_MAP:String = "返回地图";
	// [TranslateMsg("通用文本")]
	public static inline var BACK_TO_MAINMENU:String = "返回主菜单";
	// [TranslateMsg("通用文本")]
	public static inline var ERROR:String = "错误";
	// [TranslateMsg("通用文本")]
	public static inline var WARNING:String = "警告";
	// [TranslateMsg("通用文本")]
	public static inline var HINT:String = "提示";
	// [TranslateMsg("通用文本")]
	public static inline var QUIT:String = "退出";
	// [TranslateMsg("通用文本")]
	public static inline var CONTINUE:String = "继续";
	// [TranslateMsg("通用文本")]
	public static inline var CONFIRM:String = "确认";

	// [TranslateMsg("实体名称-未知", CONTEXT_ENTITY_NAME)]
	public static inline var UNKNOWN_ENTITY_NAME:String = "？？？";

	// [TranslateMsg("实体对策名称-未知", CONTEXT_ENTITY_COUNTER_NAME)]
	public static inline var UNKNOWN_ENTITY_COUNTER_NAME:String = "？？？";

	// [TranslateMsg("实体说明-未知", CONTEXT_ENTITY_TOOLTIP)]
	public static inline var UNKNOWN_ENTITY_TOOLTIP:String = "？？？";

	// [TranslateMsg("制品名称-未知", CONTEXT_ARTIFACT_NAME)]
	public static inline var UNKNOWN_ARTIFACT_NAME:String = "？？？";

	// [TranslateMsg("制品说明-未知", CONTEXT_ARTIFACT_TOOLTIP)]
	public static inline var UNKNOWN_ARTIFACT_TOOLTIP:String = "？？？";

	// [TranslateMsg("蓝图选项名称-未知", CONTEXT_OPTION_NAME)]
	public static inline var UNKNOWN_OPTION_NAME:String = "？？？";

	// [TranslateMsg("死亡信息-未知", CONTEXT_DEATH_MESSAGE)]
	public static inline var DEATH_MESSAGE_UNKNOWN:String = "你死了！";
	// [TranslateMsg("死亡信息-无尽模式模板，{0}为普通死亡信息，{1}为存活了多少轮", CONTEXT_DEATH_MESSAGE)]
	public static inline var DEATH_MESSAGE_ENDLESS_TEMPLATE:String = "{0}\n{1}";
	// [TranslateMsg("死亡信息-无尽模式，{0}为存活了多少轮", CONTEXT_DEATH_MESSAGE, selfPlural: true)]
	public static inline var DEATH_MESSAGE_ENDLESS:String = "你存活了{0}轮！";

	// [TranslateMsg("关卡难度", CONTEXT_DIFFICULTY)]
	public static inline var DIFFICULTY_UNKNOWN:String = "未知难度";

	public static inline var CONTEXT_DIFFICULTY:String = "difficulty";
	public static inline var CONTEXT_ENTITY_NAME:String = "entity.name";
	public static inline var CONTEXT_ENTITY_COUNTER_NAME:String = "entity_counter.name";
	public static inline var CONTEXT_ENTITY_TOOLTIP:String = "entity.tooltip";
	public static inline var CONTEXT_BLUEPRINT_OPTION_NAME:String = "blueprint_option.name";
	public static inline var CONTEXT_BLUEPRINT_OPTION_TOOLTIP:String = "blueprint_option.tooltip";
	public static inline var CONTEXT_ARTIFACT_NAME:String = "artifact.name";
	public static inline var CONTEXT_ARTIFACT_TOOLTIP:String = "artifact.tooltip";
	public static inline var CONTEXT_DEATH_MESSAGE:String = "death_message";
	public static inline var CONTEXT_OPTION_NAME:String = "option.name";
	public static inline var CONTEXT_OPTION_CATEGORY:String = "option.category";
	public static inline var CONTEXT_OPTION_TOOLTIP:String = "option.tooltip";


	// #region 图鉴
	// [TranslateMsg("怪物说明-还没有遇到", CONTEXT_ALMANAC)]
	public static inline var NOT_ENCOUNTERED_YET:String = "（还没有遇到）";
	// [TranslateMsg("图鉴说明-未知", CONTEXT_ALMANAC)]
	public static inline var ALMANAC_UNKNOWN:String = "？？？";
	public static function GetAlmanacNameContext(category:String):String
	{
		return '${category}.name';
	}
	public static function GetAlmanacDescriptionContext(category:String):String
	{
		return '${category}.description';
	}
	public static function GetTalkTextContext(groupID:NamespaceID):String
	{
		return 'talk-${groupID.SpaceName}:${groupID.Path}';
	}
	public static inline var CONTEXT_ALMANAC:String = "almanac";
	public static inline var CONTEXT_ALMANAC_TAG_NAME:String = "almanac_tag.name";
	public static inline var CONTEXT_ALMANAC_TAG_DESCRIPTION:String = "almanac_tag.description";
	public static inline var CONTEXT_ALMANAC_TAG_ENUM_NAME:String = "almanac_tag_enum.name";
	public static inline var CONTEXT_ALMANAC_TAG_ENUM_DESCRIPTION:String = "almanac_tag_enum.description";
	public static inline var CONTEXT_ALMANAC_GROUP_NAME:String = "almanac.group_name";
	// #endregion

	// #region 对话档案
	// [TranslateMsg("对话档案对话框标题", CONTEXT_ARCHIVE)]
	public static inline var ARCHIVE_BRANCH:String = "剧情分支";
	// [TranslateMsg("对话档案对话框标题", CONTEXT_ARCHIVE)]
	public static inline var ARCHIVE_TALK_END:String = "对话结束";
	// [TranslateMsg("对话档案对话框内容", CONTEXT_ARCHIVE)]
	public static inline var ARCHIVE_REPLAY:String = "是否重新播放？";

	public static inline var CONTEXT_ARCHIVE:String = "archive";
	public static inline var CONTEXT_ARCHIVE_TAG_NAME:String = "archive.tagname";
	// #endregion

	// #region 关卡名称
	// [TranslateMsg("关卡名称", CONTEXT_LEVEL_NAME)]
	public static inline var LEVEL_NAME_UNKNOWN:String = "未知关卡";
	// [TranslateMsg("关卡名称，{0}为关卡名，{1}为冒险模式天数", CONTEXT_LEVEL_NAME, selfPlural: true)]
	public static inline var LEVEL_NAME_DAY_TEMPLATE:String = "{0} - 第{1}天";
	// [TranslateMsg("关卡名称，{0}为关卡名，{1}为无尽模式轮数", CONTEXT_LEVEL_NAME, selfPlural: true)]
	public static inline var LEVEL_NAME_ENDLESS_FLAGS_TEMPLATE:String = "{0} - 第{1}轮";

	public static inline var CONTEXT_LEVEL_NAME:String = "levelname";
	// #endregion

	// #region 语言名称
	public static inline var CONTEXT_LANGUAGE_NAME:String = "language_name";
	// #endregion

	// #region 充能时间
	public static inline var CONTEXT_RECHARGE_TIME:String = "recharge_time";
	// #endregion

	// #region 命令
	// [TranslateMsg("命令输出", CONTEXT_COMMAND_OUTPUT)]
	public static inline var COMMAND_INCORRECT_FORMAT:String = "命令格式错误";
	// [TranslateMsg("命令输出", CONTEXT_COMMAND_OUTPUT)]
	public static inline var COMMAND_MUST_IN_LEVEL:String = "该命令只能在关卡中被调用";
	// [TranslateMsg("命令输出，{0}为参数名", CONTEXT_COMMAND_OUTPUT)]
	public static inline var COMMAND_INCORRECT_PARAMETER:String = "参数{0}格式错误";
	// [TranslateMsg("命令输出", CONTEXT_COMMAND_OUTPUT)]
	public static inline var COMMAND_INCORRECT_PARAMETER_COUNT:String = "参数数量错误";
	// [TranslateMsg("命令输出，{0}为参数名", CONTEXT_COMMAND_OUTPUT)]
	public static inline var COMMAND_MISSING_PARAMETER:String = "参数{0}丢失";
	// [TranslateMsg("命令输出，{0}为有效参数列表", CONTEXT_COMMAND_OUTPUT)]
	public static inline var COMMAND_INCORRECT_SUBNAME:String = "参数错误，有效值为{0}";
	// [TranslateMsg("命令输出，{0}为参数名", CONTEXT_COMMAND_OUTPUT)]
	public static inline var COMMAND_MISSING_SUBNAME:String = "参数丢失，有效值为{0}";
	// [TranslateMsg("命令输出，{0}为命令名", CONTEXT_COMMAND_OUTPUT)]
	public static inline var COMMAND_NOT_FOUND:String = "未找到命令{0}！";

	// [TranslateMsg("命令参数类型", CONTEXT_COMMAND_PARAMETER_TYPE)]
	public static inline var PARAMETER_TYPE_BOOLEAN:String = "真值";
	// [TranslateMsg("命令参数类型", CONTEXT_COMMAND_PARAMETER_TYPE)]
	public static inline var PARAMETER_TYPE_INT:String = "整数";
	// [TranslateMsg("命令参数类型", CONTEXT_COMMAND_PARAMETER_TYPE)]
	public static inline var PARAMETER_TYPE_FLOAT:String = "实数";
	// [TranslateMsg("命令参数类型", CONTEXT_COMMAND_PARAMETER_TYPE)]
	public static inline var PARAMETER_TYPE_ID:String = "ID";
	// [TranslateMsg("命令参数类型", CONTEXT_COMMAND_PARAMETER_TYPE)]
	public static inline var PARAMETER_TYPE_COMMAND:String = "命令";
	// [TranslateMsg("命令参数类型", CONTEXT_COMMAND_PARAMETER_TYPE)]
	public static inline var PARAMETER_TYPE_UNKNOWN:String = "未知";

	public static inline var CONTEXT_COMMAND_OUTPUT:String = "command.output";
	public static inline var CONTEXT_COMMAND_DESCRIPTION:String = "command.description";
	public static inline var CONTEXT_COMMAND_VARIANT_DESCRIPTION:String = "command_variant.description";
	public static inline var CONTEXT_COMMAND_PARAMETER_DESCRIPTION:String = "command_parameter.description";
	public static inline var CONTEXT_COMMAND_PARAMETER_TYPE:String = "command_parameter.type";
	// #endregion

	// #region 人物名称
	public static inline var CONTEXT_CHARACTER_NAME:String = "character.name";
	// #endregion

	// #region 音乐
	// [TranslateMsg("音乐名-无", CONTEXT_MUSIC_NAME)]
	public static inline var MUSIC_NAME_NONE:String = "无";

	public static inline var CONTEXT_MUSIC_NAME:String = "music.name";
	public static inline var CONTEXT_MUSIC_ORIGIN:String = "music.origin";
	public static inline var CONTEXT_MUSIC_SOURCE:String = "music.source";
	public static inline var CONTEXT_MUSIC_AUTHOR:String = "music.author";
	public static inline var CONTEXT_MUSIC_DESCRIPTION:String = "music.description";
	// #endregion

	// #region 快捷键
	public static inline var CONTEXT_HOTKEY_NAME:String = "hotkey.name";
	// #endregion

	// #region 成就
	public static inline var CONTEXT_ACHIEVEMENT:String = "achievement";
	// #endregion

	// #region 制作人员名单
	public static inline var CONTEXT_CREDITS_CATEGORY:String = "credits_category";
	public static inline var CONTEXT_STAFF_NAME:String = "staff_name";
	// #endregion

	// #region UI
	// [TranslateMsg("游戏内文本提示")]
	public static inline var TOOLTIP_DIG_CONTRAPTION:String = "挖掉器械";
	// [TranslateMsg("游戏内文本提示")]
	public static inline var TOOLTIP_TRIGGER_CONTRAPTION:String = "触发器械";
	// [TranslateMsg("固有蓝图的提示")]
	public static inline var INNATE:String = "固有";
	// [TranslateMsg("不推荐使用的提示")]
	public static inline var NOT_RECOMMONEDED_IN_LEVEL:String = "不推荐在这关使用";
	// [TranslateMsg("无法携带提示")]
	public static inline var TOOLTIP_CANNOT_IMITATE_THIS_CONTRAPTION:String = "无法模仿此器械";
	// [TranslateMsg("命令方块蓝图名，{0}为原名称")]
	public static inline var COMMAND_BLOCK_BLUEPRINT_NAME_TEMPLATE:String = "[命令方块]{0}";
	// #endregion

	// #region 用户操作
	// [TranslateMsg("输入名称对话框的错误信息")]
	public static inline var ERROR_MESSAGE_NAME_EMPTY:String = "用户名不能为空";
	// [TranslateMsg("输入名称对话框的错误信息")]
	public static inline var ERROR_MESSAGE_NAME_DUPLICATE:String = "已经存在该用户名";
	// [TranslateMsg("输入名称对话框的错误信息")]
	public static inline var ERROR_MESSAGE_CANNOT_USE_THIS_NAME:String = "无法重命名为该用户名";
	// [TranslateMsg("输入名称对话框的错误信息")]
	public static inline var ERROR_MESSAGE_CANNOT_CANCEL_NAME_INPUT:String = "第一次游戏必须输入用户名";
	// [TranslateMsg("删除用户时的警告，{0}为名称")]
	public static inline var WARNING_DELETE_USER:String = "确认删除用户{0}吗？\n该用户所有的数据都将被删除！";
	// [TranslateMsg("重命名特殊用户时的警告")]
	public static inline var ERROR_MESSAGE_CANNOT_RENAME_THIS_USER:String = "你无法重命名该用户";
	// #endregion

	// #region 错误
	public static inline var CONTEXT_ERROR:String = "error";
	// #endregion

	// #region 商店对话
	public static inline var CONTEXT_STORE_TALK:String = "store_talk";
	// #endregion

	// #region 对话
	public static inline var CONTEXT_TALK:String = "talk";
	// #endregion

	// #region 蓝图错误
	public static inline var CONTEXT_BLUEPRINT_ERROR:String = "blueprint.error";
	// #endregion

	// #region 关卡建议
	// [TranslateMsg("预览战场的提示", CONTEXT_ADVICE)]
	public static inline var ADVICE_CLICK_TO_CONTINUE:String = "点击以继续";
	public static inline var CONTEXT_ADVICE:String = "advice";
	// #endregion

	// #region 统计
	public static inline var CONTEXT_STAT_CATEGORY:String = "stat_category";
	public static inline var CONTEXT_STAT_ENTRY:String = "stat_entry";
	// #endregion

	// #region 选项
	public static inline var CONTEXT_COMMAND_BLOCK_MODE:String = "option.command_block_mode";
	public static inline var CONTEXT_FPS_MODE:String = "option.fps_mode";
	public static inline var CONTEXT_HP_BARS_AMOUNT_MODE:String = "options.hp_bars_amount_mode";
	public static inline var CONTEXT_TARGET_FRAMERATE:String = "option.target_framerate";
	public static inline var CONTEXT_SCREEN_LAYOUT:String = "option.screen_layout";
	// #endregion
}
