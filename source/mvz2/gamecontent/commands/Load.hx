// Ported from: Assets/Scripts/Vanilla/GameContent/Commands/Load.cs
package mvz2.gamecontent.commands;

import mvz2logic.Global;
import mvz2logic.commands.CommandDefinition;
import mvz2logic.level.LogicLevelExt;

@:autoCommandDefinition(VanillaCommandNames.load)
class Load extends CommandDefinition
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
    }
    // PORT-NOTE: C# `async void Invoke` + `await level.ReloadLevel()` → Haxe 同步调用（Haxe 无 async/await）。
    public override function Invoke(parameters:Array<String>):Void
    {
        var level = Global.Level.GetLevel();
        if (level == null)
            return;
        LogicLevelExt.ReloadLevel(level);
    }
}
