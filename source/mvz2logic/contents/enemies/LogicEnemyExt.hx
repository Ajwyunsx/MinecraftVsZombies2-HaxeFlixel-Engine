// Ported from: Assets/Scripts/Logic/Contents/Enemies/LogicEnemyExt.cs
package mvz2logic.contents.enemies;

import mvz2logic.contents.buffs.enemies.BeingRidenBuff;
import mvz2logic.contents.buffs.enemies.RidingPassengerBuff;
import pvzengine.buffs.Buff;
import pvzengine.entities.Entity;
using mvz2logic.entities.LogicEnemyProps;
using pvzengine.buffs.BuffTargetExt;

// PORT-NOTE: C# 的泛型无参扩展 AddBuff<T>() / RemoveBuffs<T>() / GetFirstBuff<T>() 在 Haxe 中
//   不支持显式类型参数调用，改为把类对象作为参数传入（BuffTargetExt 侧签名相应为 Class<T>）。
class LogicEnemyExt
{
	// #region 骑乘
	public static function RideOn(passenger:Entity, horse:Entity):Void
	{
		if (passenger == null || horse == null)
			return;
		GetOffPassenger(passenger);
		GetOffHorse(horse);

		var passengerBuff = passenger.AddBuff(RidingPassengerBuff);
		RidingPassengerBuff.SetRidingEntity(passengerBuff, horse);
		UpdatePassengerPosition(passenger, horse);

		var horseBuff = horse.AddBuff(BeingRidenBuff);
		BeingRidenBuff.SetPassenger(horseBuff, passenger);
	}
	public static function GetOffPassenger(passenger:Entity):Void
	{
		if (passenger == null)
			return;
		var horse = GetRidingEntity(passenger);
		if (horse != null)
		{
			horse.RemoveBuffs(BeingRidenBuff);
		}
		passenger.RemoveBuffs(RidingPassengerBuff);
	}
	public static function GetOffHorse(horse:Entity):Void
	{
		if (horse == null)
			return;
		var passenger = GetRideablePassenger(horse);
		if (passenger != null)
		{
			passenger.RemoveBuffs(RidingPassengerBuff);
		}
		horse.RemoveBuffs(BeingRidenBuff);
	}
	public static function GetRidingEntity(entity:Entity):Null<Entity>
	{
		var buff = entity.GetFirstBuff(RidingPassengerBuff);
		if (buff == null)
			return null;
		return RidingPassengerBuff.GetRidingEntity(buff);
	}
	public static function GetRideablePassenger(entity:Entity):Null<Entity>
	{
		var buff = entity.GetFirstBuff(BeingRidenBuff);
		if (buff == null)
			return null;
		return BeingRidenBuff.GetPassenger(buff);
	}
	public static function UpdatePassengerPosition(passenger:Entity, horse:Entity):Void
	{
		passenger.Position = horse.Position + horse.GetPassengerOffset();
	}
	// #endregion
}
