// Ported from: Assets/Scripts/Logic/Callbacks/LogicCallbacks.cs
package mvz2logic.callbacks;

import mvz2logic.almanac.AlmanacEntryTagInfo;
import mvz2logic.inputs.PointerPhase;
import mvz2logic.talk.ITalkSystem;
import pvzengine.NamespaceID;
import pvzengine.SeedDefinition;
import pvzengine.callbacks.CallbackType;
import pvzengine.callbacks.EmptyCallbackParams;
import pvzengine.callbacks.StringCallbackParams;
import unity.Vector2;

class LogicCallbacks
{
	public static var POST_POINTER_ACTION:CallbackType<PostPointerActionParams> = new CallbackType<PostPointerActionParams>();
	public static var TALK_ACTION:CallbackType<TalkActionParams> = new CallbackType<TalkActionParams>();
	public static var GET_ALMANAC_ENTRY_TAGS:CallbackType<GetAlmanacEntryTagsParams> = new CallbackType<GetAlmanacEntryTagsParams>();
	public static var GET_INNATE_BLUEPRINTS:CallbackType<GetInnateBlueprintsParams> = new CallbackType<GetInnateBlueprintsParams>();
	public static var GET_INNATE_ARTIFACTS:CallbackType<GetInnateArtifactsParams> = new CallbackType<GetInnateArtifactsParams>();
	public static var GET_BLUEPRINT_SLOT_COUNT:CallbackType<EmptyCallbackParams> = new CallbackType<EmptyCallbackParams>();
	public static var GET_BLUEPRINT_STYLE:CallbackType<GetBlueprintStyleParams> = new CallbackType<GetBlueprintStyleParams>();

	public static var IS_SPECIAL_USER_NAME:CallbackType<StringCallbackParams> = new CallbackType<StringCallbackParams>();
	public static var POST_USER_LOAD:CallbackType<PostUserLoadParams> = new CallbackType<PostUserLoadParams>();

	private function new() {}
}

class TalkActionParams
{
	public var system:ITalkSystem;
	public var action:String;
	public var parameters:Array<String>;

	public function new(system:ITalkSystem, action:String, parameters:Array<String>)
	{
		this.system = system;
		this.action = action;
		this.parameters = parameters;
	}
}

class GetAlmanacEntryTagsParams
{
	public var category:String;
	public var entryID:NamespaceID;
	public var sourceEntityID:Null<NamespaceID>;
	public var tags:Array<AlmanacEntryTagInfo>;

	public function new(category:String, entryID:NamespaceID, sourceEntityID:Null<NamespaceID>, tags:Array<AlmanacEntryTagInfo>)
	{
		this.category = category;
		this.entryID = entryID;
		this.sourceEntityID = sourceEntityID;
		this.tags = tags;
	}
}

class GetInnateBlueprintsParams
{
	public function new() {}
	public var list:Array<NamespaceID>;
}

class GetInnateArtifactsParams
{
	public function new() {}
	public var list:Array<NamespaceID>;
}

class PostUserLoadParams
{
	public function new() {}
	public var userIndex:Int;
	public var userName:String;
}

class GetBlueprintStyleParams
{
	public var blueprintDefinition:SeedDefinition;
	public var isCommandBlock:Bool;

	public function new(blueprintID:SeedDefinition, isCommandBlock:Bool)
	{
		this.blueprintDefinition = blueprintID;
		this.isCommandBlock = isCommandBlock;
	}
}

class PostPointerActionParams
{
	public var type:Int;
	public var button:Int;
	public var screenPos:Vector2 = new Vector2(0, 0); // PORT-NOTE: C# Vector2 为 struct，默认 (0,0)；显式初始化避免 abstract-over-class 的 null 解引用
	public var delta:Vector2 = new Vector2(0, 0); // PORT-NOTE: C# Vector2 为 struct，默认 (0,0)；显式初始化避免 abstract-over-class 的 null 解引用
	public var phase:PointerPhase;

	public function new(type:Int, button:Int, screenPos:Vector2, delta:Vector2, phase:PointerPhase)
	{
		this.type = type;
		this.button = button;
		this.screenPos = screenPos;
		this.delta = delta;
		this.phase = phase;
	}
}
