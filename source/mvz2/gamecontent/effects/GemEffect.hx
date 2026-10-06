// Ported from: Assets/Scripts/Vanilla/GameContent/Effects/Prologue/GemEffect.cs
package mvz2.gamecontent.effects;

import mvz2.gamecontent.models.VanillaModelID;
import mvz2.vanilla.audios.VanillaSoundID;
import mvz2logic.entities.LogicEntityExt;
import mvz2logic.level.LogicLevelExt;
import mvz2logic.level.LevelPositions;
import pvzengine.NamespaceID;
import pvzengine.entities.Entity;
import pvzengine.level.LevelEngine;
import unity.Mathf;
import unity.Quaternion;
import unity.Vector3;
import mvz2.gamecontent.effects.GemEffect.GemType;
import mvz2.gamecontent.effects.VanillaEffectID.VanillaEffectNames;
using mvz2logic.entities.LogicEntityExt;

@:autoEntityBehaviourDefinition(VanillaEffectNames.gemEffect)
class GemEffect extends EffectBehaviour
{
    // #region 公有方法
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
    }
    public override function Init(entity:Entity):Void
    {
        super.Init(entity);
        entity.Timeout = MIN_TIMEOUT;
    }
    public override function Update(entity:Entity):Void
    {
        super.Update(entity);
        var level = entity.Level;

        var alpha:Float = 1;
        var timeout = entity.Timeout;
        var vanishTime = VANISH_TICKS;
        var moveTime = MOVE_TICKS;
        if (timeout > vanishTime + moveTime)
        {
            entity.Velocity *= 0.9;
        }
        else if (timeout > vanishTime)
        {
            var targetPos = GetMoveTargetPosition(entity);
            entity.Velocity = (targetPos - entity.Position) * 0.2;
            alpha = 1;
        }
        else
        {
            if (timeout == vanishTime)
            {
                level.RemoveDelayedMoney(entity);
            }

            var vanishLerp = 1 - timeout / (vanishTime : Float);
            entity.SetDisplayScale(Vector3.one * Mathf.Lerp(1, 0.5, vanishLerp));
            alpha = Mathf.Lerp(1, 0, vanishLerp);
        }
        var color = entity.GetTint(true);
        color.a = alpha;
        entity.SetTint(color);
    }
    public static function SpawnGemEffects(level:LevelEngine, money:Int, position:Vector3, spawner:Null<Entity>, mute:Bool = false, timeout:Int = 20):Array<Entity>
    {
        // C#: gemMoneyDict.OrderByDescending(p => p.Value)
        // PORT-NOTE: Dictionary → Map 后迭代顺序不保证与原 C# Dictionary 完全一致；此处显式按面值降序排序。
        var moneyPairs:Array<{key:GemType, value:Int}> = [];
        for (key in gemMoneyDict.keys())
        {
            moneyPairs.push({key: key, value: gemMoneyDict.get(key)});
        }
        moneyPairs.sort(function(a, b) return b.value - a.value);

        var currentMoney = money;
        var totalCountToSpawn = 0;
        var gemsToSpawn:Map<GemType, Int> = new Map();
        for (pair in moneyPairs)
        {
            var count = Std.int(currentMoney / pair.value);
            currentMoney = currentMoney % pair.value;
            gemsToSpawn.set(pair.key, count);
            totalCountToSpawn += count;
        }
        var spawnedGems:Array<Entity> = [];
        var currentIndex = 0;
        var anglePerGem = 180 / (totalCountToSpawn + 1);
        var startAngle = -90 + anglePerGem;
        for (type in gemsToSpawn.keys())
        {
            var count = gemsToSpawn.get(type);
            for (i in 0...count)
            {
                var e = SpawnGemEffect(level, type, position, spawner, mute, timeout);
                // C#: ...?.Let(e => {...})
                if (e != null)
                {
                    spawnedGems.push(e);
                    var angle = startAngle + anglePerGem * currentIndex;
                    e.Velocity = (Quaternion.Euler(0, 0, angle) * Vector3.up) * 10;
                }

                currentIndex++;
            }
        }
        // 把剩下的钱补上
        if (currentMoney > 0)
        {
            level.AddMoney(currentMoney);
        }
        return spawnedGems;
    }
    public static function SpawnGemEffect(level:LevelEngine, type:GemType, position:Vector3, spawner:Null<Entity>, mute:Bool = false, timeout:Int = 0):Null<Entity>
    {
        var effect = level.Spawn(VanillaEffectID.gemEffect, position, spawner);
        if (effect != null)
        {
            effect.ChangeModel(gemModelDict.get(type));
            effect.Timeout = timeout + MIN_TIMEOUT;
            if (!mute)
            {
                effect.PlaySound(gemSoundDict.get(type));
            }
        }
        if (effect != null)
        {
            level.ShowMoney();
            level.AddDelayedMoney(effect, gemMoneyDict.get(type));
        }
        return effect;
    }
    // #endregion

    private static function GetMoveTargetPosition(entity:Entity):Vector3
    {
        var level = entity.Level;
        var slotPosition = LevelPositions.GetMoneyPanelEntityPosition(level);
        return new Vector3(slotPosition.x, slotPosition.y - COLLECTED_Z - 15, COLLECTED_Z);
    }
    public static inline var MOVE_TICKS:Int = 20;
    public static inline var VANISH_TICKS:Int = 10;
    public static inline var COLLECTED_Z:Float = -100;
    public static inline var MIN_TIMEOUT:Int = VANISH_TICKS + MOVE_TICKS;
    private static var gemMoneyDict:Map<GemType, Int> = [
        GemType.Emerald => 10,
        GemType.Ruby => 50,
        GemType.Diamond => 1000
    ];
    private static var gemSoundDict:Map<GemType, NamespaceID> = [
        GemType.Emerald => VanillaSoundID.coin,
        GemType.Ruby => VanillaSoundID.coin,
        GemType.Diamond => VanillaSoundID.diamond
    ];
    private static var gemModelDict:Map<GemType, NamespaceID> = [
        GemType.Emerald => VanillaModelID.emerald,
        GemType.Ruby => VanillaModelID.ruby,
        GemType.Diamond => VanillaModelID.diamond
    ];
}

enum abstract GemType(Int)
{
    var Emerald = 0;
    var Ruby = 1;
    var Diamond = 2;
}
