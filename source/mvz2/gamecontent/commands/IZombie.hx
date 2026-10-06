// Ported from: Assets/Scripts/Vanilla/GameContent/Commands/IZombie.cs
package mvz2.gamecontent.commands;

import mvz2.gamecontent.stages.IZombieBehaviour;
import mvz2.vanilla.level.VanillaLevelExt;
import mvz2.vanilla.localization.VanillaStrings;
import mvz2logic.Global;
import mvz2logic.ParseHelper;
import mvz2logic.commands.CommandDefinition;
import mvz2logic.commands.CommandUtility;
import mvz2logic.level.LogicLevelExt;
import mvz2logic.level.LogicLevelProps;
import mvz2logic.localization.LogicStrings;
import pvzengine.NamespaceID;

@:autoCommandDefinition(VanillaCommandNames.izombie)
class IZombie extends CommandDefinition
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
    }
    public override function Invoke(parameters:Array<String>):Void
    {
        var game = Global.Game;
        var level = Global.Level.GetLevel();
        if (level == null)
            return;

        if (parameters[0] == "layout")
        {
            // PORT-NOTE: C# 是泛型方法 level.GetStageBehaviour<IZombieBehaviour>()；Haxe 无法写类型实参，
            // 按工程约定改为显式传入类型对象。
            var behaviour = VanillaLevelExt.GetStageBehaviour(level, IZombieBehaviour);
            if (behaviour == null)
            {
                var msg = Global.Localization.GetTextParticular(VanillaStrings.COMMAND_NOT_IN_I_ZOMBIE_LEVEL, LogicStrings.CONTEXT_COMMAND_OUTPUT);
                throw msg;
            }
            var layoutID:Null<NamespaceID> = null;
            if (parameters.length > 1)
            {
                layoutID = CommandUtility.ParseOptionalNamespaceID(parameters[1], Global.BuiltinNamespace, null);
            }
            if (layoutID == null)
            {
                behaviour.NextRound(level);
            }
            else
            {

                behaviour.NextRoundWithLayout(level, layoutID);
            }
            LogicLevelExt.UpdateLevelName(level);
        }
        else if (parameters[0] == "pickaxe")
        {
            var value = ParseHelper.ParseInt(parameters[1]);
            LogicLevelProps.SetPickaxeRemainCount(level, value);
        }
    }
}
