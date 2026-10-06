// Ported from: Assets/Scripts/Engine/Level/Grids/GridDefinition.cs
package pvzengine.grids;

import pvzengine.NamespaceID;
import pvzengine.auras.AuraEffectDefinition;
import pvzengine.base.Definition;
import pvzengine.definitions.EngineDefinitionTypes;
import pvzengine.entities.Entity;

class GridDefinition extends Definition
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
    }
    public function GetPlaceSound(entity:Entity):Null<NamespaceID>
    {
        return null;
    }
    public function GetAuraCount():Int
    {
        return auraDefinitions.length;
    }
    public function GetAuraAt(index:Int):AuraEffectDefinition
    {
        return auraDefinitions[index];
    }
    // C#: protected void AddAura(AuraEffectDefinition aura)
    // PORT-NOTE: Haxe 无 protected，private 成员对子类可见，语义等价。
    private function AddAura(aura:AuraEffectDefinition):Void
    {
        auraDefinitions.push(aura);
    }
    public override function GetDefinitionType():String return EngineDefinitionTypes.GRID;
    private var auraDefinitions:Array<AuraEffectDefinition> = [];
}
