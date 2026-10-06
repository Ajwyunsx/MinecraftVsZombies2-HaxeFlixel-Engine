// Ported from: Assets/Scripts/Logic/IZombie/IIZombieMap.cs
package mvz2logic.izombie;

import pvzengine.NamespaceID;
import pvzengine.level.LevelEngine;
import unity.Vector2Int;

interface IIZombieMap
{
	function InsertEntity(column:Int, lane:Int, entity:NamespaceID):Void;
	function CanInsert(column:Int, lane:Int, entity:NamespaceID):Bool;
	// TODO-PORT: C# 接口还有一个带默认实现的重载 CanInsert(Vector2Int position, NamespaceID entity)，
	// Haxe 接口不支持默认方法与重载，调用处请改用 CanInsert(position.x, position.y, entity)。
	function GetAllGridPositions():Array<Vector2Int>;
	public var Level(get, never):LevelEngine;
	public var Rounds(get, never):Int;
	public var Columns(get, never):Int;
	public var Lanes(get, never):Int;
}
