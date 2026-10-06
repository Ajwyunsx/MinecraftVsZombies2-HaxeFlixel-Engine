// Ported from: Assets/Scripts/Vanilla/GameContent/GlobalCallbacks/DifficultyGlobalCallbacks.cs
package mvz2.gamecontent.globalcallbacks;

import mvz2.vanilla.properties.VanillaLevelPropertyMeta;
import mvz2logic.callbacks.LogicLevelCallbacks;
import mvz2logic.difficulties.LogicDifficultyProps;
import mvz2logic.level.LogicLevelExt;
import mvz2logic.modding.Mod;
import pvzengine.buffs.Buff;
import pvzengine.buffs.BuffDefinition;
import pvzengine.buffs.BuffReference;
import pvzengine.callbacks.CallbackResult;
import pvzengine.callbacks.LevelCallbackParams;
import pvzengine.callbacks.LevelCallbacks;
import pvzengine.level.LevelEngine;
import mvz2logic.level.LogicStageProps;

@:modGlobalCallbacks
class DifficultyGlobalCallbacks extends VanillaGlobalCallbacks
{
    public override function Apply(mod:Mod):Void
    {
        mod.AddTrigger(LogicLevelCallbacks.PRE_BATTLE, PreBattleCallback);
        mod.AddTrigger(LevelCallbacks.POST_LEVEL_START, PostLevelStartCallback);
    }
    public function PreBattleCallback(param:LevelCallbackParams, result:CallbackResult):Void
    {
        var level = param.level;
        EvaluateDifficultyBuff(level);
    }
    public function PostLevelStartCallback(param:LevelCallbackParams, result:CallbackResult):Void
    {
        var level = param.level;
        EvaluateDifficultyBuff(level);
    }
    function EvaluateDifficultyBuff(level:LevelEngine):Void
    {
        var difficulty = level.Difficulty;
        var difficultyDef = level.Content.GetDifficultyDefinition(difficulty);
        // PORT-NOTE: C# 中 buffDef 由后续赋值推断为 BuffDefinition?；Haxe 的 `var x = null` 会被推断成 Void
        //（报 “Variables of type Void are not allowed”），必须显式标注可空类型。
        var buffDef:Null<BuffDefinition> = null;
        if (difficultyDef != null)
        {
            var buffId = LogicDifficultyProps.GetBuffID(difficultyDef);
            if (LogicStageProps.IsIZombie(level))
            {
                buffId = LogicDifficultyProps.GetIZombieBuffID(difficultyDef);
            }
            // PORT-NOTE: C# 是 Content.GetBuffDefinition(buffId)（ContentProviderHelper 扩展，按 NamespaceID 取）；
            // Haxe 侧按类型取的泛型版本改名成了 GetBuffDefinitionByType(Class<T>)，按 ID 的仍是 GetBuffDefinition。
            buffDef = buffId != null ? level.Content.GetBuffDefinition(buffId) : null;
        }


        var buffRef = GetDifficultyBuff(level);
        var buff = buffRef != null ? buffRef.GetBuff(level) : null;
        if (buff != null)
        {
            if (buff.Definition == buffDef)
            {
                return;
            }
            level.RemoveBuff(buff);
        }
        if (buffDef != null)
        {
            buff = level.AddBuff(buffDef);
            SetDifficultyBuff(level, level.GetBuffReference(buff));
        }
    }
    public static function GetDifficultyBuff(level:LevelEngine):Null<BuffReference>
    {
        return level.GetProperty(PROP_DIFFICULTY_BUFF);
    }
    public static function SetDifficultyBuff(level:LevelEngine, value:BuffReference):Void
    {
        level.SetProperty(PROP_DIFFICULTY_BUFF, value);
    }
    static inline var PROP_REGION:String = "difficulty";
    @:levelPropertyRegistry("difficulty")
    public static var PROP_DIFFICULTY_BUFF:VanillaLevelPropertyMeta<BuffReference> = new VanillaLevelPropertyMeta<BuffReference>("DifficultyBuff");
}
