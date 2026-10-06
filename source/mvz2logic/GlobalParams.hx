// Ported from: Assets/Scripts/Logic/Game/Global.cs (struct GlobalParams)
package mvz2logic;

import mvz2logic.games.IGlobalAlmanac;
import mvz2logic.games.IGlobalCursors;
import mvz2logic.games.IGlobalDebug;
import mvz2logic.games.IGlobalGUI;
import mvz2logic.games.IGlobalInput;
import mvz2logic.games.IGlobalLevel;
import mvz2logic.games.IGlobalLocalization;
import mvz2logic.games.IGlobalModels;
import mvz2logic.games.IGlobalMusic;
import mvz2logic.games.IGlobalOptions;
import mvz2logic.games.IGlobalSaveData;
import mvz2logic.games.IGlobalScene;

// PORT-NOTE: C# struct 改为普通类（PORTING.md: struct → class）。
class GlobalParams
{
	public function new()
	{
	}

	public var models:IGlobalModels;
	public var almanac:IGlobalAlmanac;
	public var saveData:IGlobalSaveData;
	public var options:IGlobalOptions;
	public var input:IGlobalInput;
	public var level:IGlobalLevel;
	public var music:IGlobalMusic;
	public var gui:IGlobalGUI;
	public var scene:IGlobalScene;
	public var localization:IGlobalLocalization;
	public var debug:IGlobalDebug;
	public var cursors:IGlobalCursors;
}
