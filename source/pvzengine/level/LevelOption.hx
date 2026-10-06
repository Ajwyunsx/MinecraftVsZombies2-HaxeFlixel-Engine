// Ported from: Assets/Scripts/Engine/Level/Level/LevelOption.cs
package pvzengine.level;

class LevelOption
{
	public function new() {}
	public function Serialize():SerializableLevelOption
	{
		var seri = new SerializableLevelOption();
		seri.leftFaction = LeftFaction;
		seri.rightFaction = RightFaction;
		seri.tps = TPS;
		seri.cardSlotCount = CardSlotCount;
		seri.starshardSlotCount = StarshardSlotCount;
		seri.maxEnergy = MaxEnergy;
		return seri;
	}
	public static function Deserialize(seri:SerializableLevelOption):LevelOption
	{
		var option = new LevelOption();
		option.LeftFaction = seri.leftFaction;
		option.RightFaction = seri.rightFaction;
		option.TPS = seri.tps;
		option.CardSlotCount = seri.cardSlotCount;
		option.StarshardSlotCount = seri.starshardSlotCount;
		option.MaxEnergy = seri.maxEnergy;
		return option;
	}
	public var LeftFaction:Int;
	public var RightFaction:Int;
	public var TPS:Int = 30;
	public var CardSlotCount:Int;
	public var StarshardSlotCount:Int;
	public var MaxEnergy:Float;
}
