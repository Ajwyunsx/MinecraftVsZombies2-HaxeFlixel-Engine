// Ported from: Assets/Scripts/MVZ2/Metas/Almanac/Variable/AlmanacVariableContext.cs
package mvz2.metas;

import expressionevaluator.IAttributeContext;
import mvz2.managers.MainManager;
import pvzengine.NamespaceID;

class AlmanacVariableContext implements IAttributeContext {
    public var main:MainManager;
    public var currentDefinitionType:String;
    public var currentDefinitionID:NamespaceID;
    public var currentAlmanacEntry:AlmanacMetaEntry;
    public var globalCallStack:Map<NamespaceID, Bool> = new Map();
    public var localCallStack:Map<String, Bool> = new Map();

    public function new(main:MainManager, currentDefinitionType:String, currentDefinitionID:NamespaceID, currentAlmanacEntry:AlmanacMetaEntry) {
        this.main = main;
        this.currentDefinitionType = currentDefinitionType;
        this.currentDefinitionID = currentDefinitionID;
        this.currentAlmanacEntry = currentAlmanacEntry;
    }

    public function EvaluateVariable(name:String):Dynamic {
        return null;
    }

    public function EvaluateFunction(name:String, args:Array<Dynamic>):Dynamic {
        return AlmanacVariableFunctions.EvaluateFunctions(this, name, args);
    }
}
