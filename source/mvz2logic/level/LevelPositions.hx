// Ported from: Assets/Scripts/Logic/Level/LevelPositions.cs
package mvz2logic.level;

import mvz2logic.Global;
import pvzengine.level.LevelEngine;
import unity.Rect;
import unity.Vector2;

// PORT-NOTE: C# 扩展方法 (this LevelEngine level) 按 PORTING.md 改为静态方法，level 作为第一个参数。
class LevelPositions
{
	public static function GetLeftUIBorderX(level:LevelEngine):Float
	{
		if (Global.Game.UseMobileLayout())
		{
			return 160;
		}
		return GetBorderX(false);
	}
	public static function GetMoneyPanelEntityPosition(level:LevelEngine):Vector2
	{
		var x = GetLeftUIBorderX(level) + MONEY_PANEL_X_TO_LEFT;
		var y = MONEY_PANEL_Y_TO_BOTTOM;
		return new Vector2(x, y);
	}
	public static function GetStarshardEntityPosition(level:LevelEngine):Vector2
	{
		var x = GetLeftUIBorderX(level) + STARSHARD_X_TO_LEFT;
		var y = STARSHARD_Y_TO_BOTTOM;
		return new Vector2(x, y);
	}
	public static function GetEnergySlotEntityPosition(level:LevelEngine):Vector2
	{
		var x = GetLeftUIBorderX(level) + ENERGY_SLOT_WIDTH * 0.5;
		var y = GetScreenHeight() - ENERGY_SLOT_WIDTH * 0.5;
		return new Vector2(x, y);
	}
	public static function GetScreenCenterPosition(level:LevelEngine):Vector2
	{
		var x = GetLeftUIBorderX(level) + SCREEN_WIDTH * 0.5;
		var y = SCREEN_HEIGHT * 0.5;
		return new Vector2(x, y);
	}
	public static function GetEnemySpawnRect():Rect
	{
		return new Rect(MIN_PREVIEW_X, MIN_PREVIEW_Y, MAX_PREVIEW_X - MIN_PREVIEW_X, MAX_PREVIEW_Y - MIN_PREVIEW_Y);
	}
	public static function GetScreenHeight():Float
	{
		return SCREEN_HEIGHT;
	}
	public static function GetBorderX(right:Bool):Float
	{
		return right ? RIGHT_BORDER : LEFT_BORDER;
	}
	public static function GetAttackBorderX(right:Bool):Float
	{
		return right ? ATTACK_RIGHT_BORDER : ATTACK_LEFT_BORDER;
	}
	public static function GetPickupBorderX(right:Bool):Float
	{
		return right ? PICKUP_RIGHT_BORDER : PICKUP_LEFT_BORDER;
	}
	public static function GetPickupBorderZ(top:Bool):Float
	{
		return top ? PICKUP_TOP_BORDER : PICKUP_BOTTOM_BORDER;
	}
	public static function GetEnemyRightBorderX():Float
	{
		return ENEMY_RIGHT_BORDER;
	}
	public static inline var ENERGY_SLOT_WIDTH:Float = 48;

	public static inline var MONEY_PANEL_X_TO_LEFT:Float = 16;
	public static inline var MONEY_PANEL_Y_TO_BOTTOM:Float = 32;

	public static inline var STARSHARD_X_TO_LEFT:Float = 128 + 165 + 16;
	public static inline var STARSHARD_Y_TO_BOTTOM:Float = 32;

	public static inline var MIN_PREVIEW_X:Float = 1080;
	public static inline var MAX_PREVIEW_X:Float = 1300;
	public static inline var MIN_PREVIEW_Y:Float = 50;
	public static inline var MAX_PREVIEW_Y:Float = 450;

	public static inline var GRID_SIZE:Float = 80;
	public static inline var LAWN_HEIGHT:Float = 600;
	public static inline var LEVEL_WIDTH:Float = 1400;
	public static inline var LEVEL_LEFTMOST:Float = 0;
	public static inline var LEVEL_RIGHTMOST:Float = LEVEL_LEFTMOST + LEVEL_WIDTH;
	public static inline var CART_START_X:Float = 150;
	public static inline var CART_TARGET_X:Float = LEFT_BORDER;
	public static inline var SCREEN_WIDTH:Float = 800;
	public static inline var SCREEN_HEIGHT:Float = 600;
	public static inline var LEFT_BORDER:Float = 220;
	public static inline var RIGHT_BORDER:Float = LEFT_BORDER + SCREEN_WIDTH;
	public static inline var LAWN_CENTER_X:Float = (LEFT_BORDER + RIGHT_BORDER) * 0.5;

	public static inline var PICKUP_LEFT_BORDER:Float = LEFT_BORDER + 50;
	public static inline var PICKUP_RIGHT_BORDER:Float = RIGHT_BORDER - 50;
	public static inline var PICKUP_TOP_BORDER:Float = 460;
	public static inline var PICKUP_BOTTOM_BORDER:Float = 0;
	public static inline var ATTACK_LEFT_BORDER:Float = LEFT_BORDER;
	public static inline var ATTACK_RIGHT_BORDER:Float = RIGHT_BORDER;

	public static inline var ENEMY_LEFT_BORDER:Float = LEFT_BORDER - 60;
	public static inline var ENEMY_RIGHT_BORDER:Float = RIGHT_BORDER + 30;


	public static inline var PROJECTILE_LEFT_BORDER:Float = LEFT_BORDER - 40;
	public static inline var PROJECTILE_RIGHT_BORDER:Float = RIGHT_BORDER + 40;
	public static inline var PROJECTILE_UP_BORDER:Float = 540;
	public static inline var PROJECTILE_DOWN_BORDER:Float = -40;
	public static inline var PROJECTILE_TOP_BORDER:Float = 1000;
	public static inline var PROJECTILE_BOTTOM_BORDER:Float = -1000;

	private function new() {}
}
