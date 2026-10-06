// Ported from: Assets/Scripts/MVZ2/Metas/TalkCharacterMeta.cs
package mvz2.metas;

import pvzengine.NamespaceID;
import unity.Vector2;

class TalkCharacterVariant {
    public var id:NamespaceID;
    public var unlock:XMLConditionList;
    public var width:Int;
    public var height:Int;
    public var pivotX:Float = 0.5;
    public var pivotY:Float = 0.5;
    // PORT-NOTE: C#（TalkCharacterMeta.cs:171）这里是 `public Vector2 widthExtend;`，Vector2 是
    // struct，字段默认值恒为 (0,0)、永不为 null；Haxe 的 unity.Vector2 是 abstract over class
    // （引用类型），不显式初始化就是 null。TalkCharacterVariantTemplate.GetCharacterVariantProperties
    // （TalkCharacterVariantTemplate.hx:85）会直接读 `result.widthExtend.x`，null 时在 cpp 上是空引用
    // （debug 构建报 Null Object Reference / release 构建访问违例崩溃），故按 C# 的默认值显式初始化为零向量。
    public var widthExtend:Vector2 = new Vector2(0, 0);
    public var layers:Array<TalkCharacterLayer> = [];

    public function new(id:NamespaceID) {
        this.id = id;
    }
}
