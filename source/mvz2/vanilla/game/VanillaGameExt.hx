// Ported from: Assets/Scripts/Vanilla/GameContent/Game/VanillaGameExt.cs
package mvz2.vanilla.game;

import mvz2logic.games.IGlobalSaveData;

class VanillaGameExt
{
    public static function IsRandomChina(saves:IGlobalSaveData):Bool
    {
        var userName = saves.GetCurrentUserName();
        return IsRandomChinaUserName(saves, userName);
    }
    public static function IsRandomChinaUserName(saves:IGlobalSaveData, name:Null<String>):Bool
    {
        if (name == null || name == "")
            return false;
        return Lambda.exists(randomChinaNames, n -> n.toLowerCase() == name.toLowerCase());
    }
    public static var randomChinaNames:Array<String> = [
        "RandomChina",
        "RandmChina",
    ];
}
