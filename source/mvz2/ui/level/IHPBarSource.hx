// Ported from: Assets/Scripts/View/Level/HPBar/IHPBarSource.cs
package mvz2.ui.level;

import unity.Vector3;

interface IHPBarSource
{
	function IsActive():Bool;
	function UpdateHPBarList(list:HPBarList):Void;
	function GetPosition():Vector3;
}
