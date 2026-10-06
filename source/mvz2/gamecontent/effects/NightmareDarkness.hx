// Ported from: Assets/Scripts/Vanilla/GameContent/Effects/Chapter2/NightmareDarkness.cs
package mvz2.gamecontent.effects;

import mvz2logic.level.LogicLevelExt;
import pvzengine.NamespaceID;
import pvzengine.entities.Entity;
import unity.Debug;
import unity.Mathf;
import unity.Vector3;
import mvz2.gamecontent.effects.VanillaEffectID.VanillaEffectNames;

@:autoEntityBehaviourDefinition(VanillaEffectNames.nightmareDarkness)
class NightmareDarkness extends EffectBehaviour
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
    }
    public override function Init(entity:Entity):Void
    {
        super.Init(entity);
        entity.Position = Vector3.zero;
        GenerateEyes(entity);
    }
    private function GenerateEyes(entity:Entity):Void
    {
        var infos:Array<NightmareEyeInfo> = [];
        var rng = entity.RNG;
        for (i in 0...MAX_EYE_COUNT)
        {
            var pos = Vector3.zero;
            var scale = Mathf.Lerp(1, 0.4, i / 15.0);
            var times = 0;
            final limit = 256;
            do
            {
                if (times >= limit)
                {
                    Debug.LogWarning("Limit reached while generating eyes on nightmare darkness.");
                    break;
                }
                var x = rng.Next(0, 1020.0);
                var z = rng.Next(0, 600.0);
                pos = new Vector3(x, 0, z);
                times++;
            }
            while (Lambda.exists(infos, info -> Vector3.Distance(pos, info.position) < (scale + info.scale) * 50));

            var info = new NightmareEyeInfo();
            info.position = pos;
            info.angle = rng.Next(0, 360.0);
            info.scale = scale;
            info.time = GetInfoTimeByIndex(i);

            infos.push(info);
        }
        entity.SetModelProperty("Eyes", infos);
    }
    public override function Update(entity:Entity):Void
    {
        super.Update(entity);
        entity.SetModelProperty("Timeout", entity.Timeout);
        if (entity.Timeout == 30)
        {
            var level = entity.Level;
            level.SetModelAnimatorBool("Boss", true);
            level.ShakeScreen(0, 50, 30);
        }
    }
    private function GetInfoTimeByIndex(index:Int):Int
    {
        var time:Float = 0;
        if (index == 0)
        {
            time = 0;
        }
        else if (index <= 2)
        {
            time = Mathf.Lerp(30, 60, index - 1);
        }
        else if (index <= 4)
        {
            time = Mathf.Lerp(60, 75, index - 3);
        }
        else if (index <= 25)
        {
            time = Mathf.Lerp(75, 105, (index - 5) / 20.0);
        }
        else if (index <= MAX_EYE_COUNT)
        {
            time = Mathf.Lerp(105, 135, (index - 26) / (MAX_EYE_COUNT - 26));
        }
        return Mathf.CeilToInt(time);
    }
    private static inline var MAX_RADIUS:Float = 1200;
    private static inline var MAX_EYE_COUNT:Int = 100;

    public static var ID:NamespaceID = VanillaEffectID.nightmareDarkness;
}

// [Serializable]
class NightmareEyeInfo
{
    public function new()
    {
    }
    public var position:Vector3 = new Vector3(0, 0, 0); // PORT-NOTE: C# Vector3 为 struct，默认 (0,0,0)；显式初始化避免 abstract-over-class 的 null 解引用
    public var angle:Float;
    public var scale:Float;
    public var time:Int;
}
