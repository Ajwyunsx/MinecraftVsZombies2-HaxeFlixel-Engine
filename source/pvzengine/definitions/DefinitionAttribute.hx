// Ported from: Assets/Scripts/Engine/Level/Definitions/DefinitionAttribute.cs
// PORT-NOTE: 本 C# 文件并不定义 DefinitionAttribute 本身（它在 PVZEngine 命名空间的
// Engine/Base/Definitions/DefinitionAttribute.cs 中，即 Haxe 的 pvzengine.DefinitionAttribute），
// 只定义其 Auto* 子类，因此模块名与主类型名不一致（模块 DefinitionAttribute，主类型 AutoAreaDefinitionAttribute）。
// PORT-NOTE: C# 特性类在 Haxe 中仅作为 `@:autoXxxDefinition("name")` 元数据标注的对应类保留，
// 上层既有文件（mvz2logic/definitions/DefinitionAttribute.hx 等）也按同样方式 extends DefinitionAttribute。
package pvzengine.definitions;

import pvzengine.DefinitionAttribute;

class AutoAreaDefinitionAttribute extends DefinitionAttribute
{
    public function new(name:String)
    {
        super(name, EngineDefinitionTypes.AREA);
    }
}
class AutoRechargeDefinitionAttribute extends DefinitionAttribute
{
    public function new(name:String)
    {
        super(name, EngineDefinitionTypes.RECHARGE);
    }
}
class AutoSeedDefinitionAttribute extends DefinitionAttribute
{
    public function new(name:String)
    {
        super(name, EngineDefinitionTypes.SEED);
    }
}
class AutoSpawnDefinitionAttribute extends DefinitionAttribute
{
    public function new(name:String)
    {
        super(name, EngineDefinitionTypes.SPAWN);
    }
}
class AutoStageDefinitionAttribute extends DefinitionAttribute
{
    public function new(name:String)
    {
        super(name, EngineDefinitionTypes.STAGE);
    }
}
class AutoBuffDefinitionAttribute extends DefinitionAttribute
{
    public function new(name:String)
    {
        super(name, EngineDefinitionTypes.BUFF);
    }
}
class AutoGridDefinitionAttribute extends DefinitionAttribute
{
    public function new(name:String)
    {
        super(name, EngineDefinitionTypes.GRID);
    }
}
class AutoEntityDefinitionAttribute extends DefinitionAttribute
{
    public function new(name:String)
    {
        super(name, EngineDefinitionTypes.ENTITY);
    }
}
class AutoArmorDefinitionAttribute extends DefinitionAttribute
{
    public function new(name:String)
    {
        super(name, EngineDefinitionTypes.ARMOR);
    }
}
class AutoArmorBehaviourDefinitionAttribute extends DefinitionAttribute
{
    public function new(name:String)
    {
        super(name, EngineDefinitionTypes.ARMOR_BEHAVIOUR);
    }
}
class AutoEntityBehaviourDefinitionAttribute extends DefinitionAttribute
{
    public function new(name:String)
    {
        super(name, EngineDefinitionTypes.ENTITY_BEHAVIOUR);
    }
}
class AutoPlacementDefinitionAttribute extends DefinitionAttribute
{
    public function new(name:String)
    {
        super(name, EngineDefinitionTypes.PLACEMENT);
    }
}
class AutoShellDefinitionAttribute extends DefinitionAttribute
{
    public function new(name:String)
    {
        super(name, EngineDefinitionTypes.SHELL);
    }
}
