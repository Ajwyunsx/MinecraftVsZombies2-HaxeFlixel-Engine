// Ported from: Assets/Scripts/Vanilla/GameContent/Commands/GotoLevel.cs
package mvz2.gamecontent.commands;

import mvz2.vanilla.localization.VanillaStrings;
import mvz2logic.Global;
import mvz2logic.commands.CommandDefinition;
import mvz2logic.localization.LogicStrings;
import pvzengine.NamespaceID;
import unity.Coroutine.CoroutineContext;

@:autoCommandDefinition(VanillaCommandNames.gotolevel)
class GotoLevel extends CommandDefinition
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
    }
    public override function Invoke(parameters:Array<String>):Void
    {
        var level = Global.Level;
        if (level.IsInLevel())
        {
            throw Global.Localization.GetTextParticular(VanillaStrings.COMMAND_CANNOT_BE_CALLED_IN_LEVEL, LogicStrings.CONTEXT_COMMAND_OUTPUT);
        }
        var stageID = NamespaceID.Parse(parameters[0], Global.BuiltinNamespace);
        var areaID = NamespaceID.Parse(parameters[1], Global.BuiltinNamespace);
        Global.Game.StartCoroutine(Coroutine(areaID, stageID));
    }
    // PORT-NOTE: C# IEnumerator 协程 → unity.Coroutine 步骤函数（PORTING.md §协程）。
    function Coroutine(areaID:NamespaceID, stageID:NamespaceID):unity.Coroutine
    {
        return unity.Coroutine.create(function(co:CoroutineContext)
        {
            var scene = Global.Scene;
            var level = Global.Level;
            co.wait(0); // yield return scene.GotoLevelCoroutine();
            level.InitLevel(areaID, stageID);
        });
    }
}
