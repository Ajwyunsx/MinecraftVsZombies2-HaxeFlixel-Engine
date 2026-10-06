// Ported from: Assets/Scripts/Logic/Artifacts/ArtifactList.cs
package mvz2logic.artifacts;

import pvzengine.NamespaceID;
import pvzengine.level.LevelEngine;
using mvz2logic.level.LogicLevelExt;

class ArtifactList
{
	public function new(level:LevelEngine, count:Int)
	{
		Level = level;
		artifacts = [for (_ in 0...count) null];
	}
	// #region 制品操作
	public function SetSlotCount(count:Int):Void
	{
		var newArray:Array<Null<Artifact>> = [for (_ in 0...count) null];
		if (artifacts != null)
		{
			for (i in 0...Std.int(Math.min(count, artifacts.length)))
			{
				newArray[i] = artifacts[i];
			}
		}
		artifacts = newArray;
	}
	public function GetSlotCount():Int
	{
		return artifacts.length;
	}
	public function ReplaceArtifacts(definitions:Null<Array<Null<ArtifactDefinition>>>):Void
	{
		if (definitions == null)
		{
			// 设置为空
			// 移除列表中的所有制品。
			for (i in 0...artifacts.length)
			{
				SetArtifact(i, null);
			}
		}
		else
		{
			// 设置不为空。
			var oldArtifacts = artifacts.copy();
			for (i in 0...artifacts.length)
			{
				if (i < 0 || i >= definitions.length)
				{
					artifacts[i] = null;
					continue;
				}
				var definition = definitions[i];
				if (definition == null)
				{
					artifacts[i] = null;
					continue;
				}
				// 在当前制品列表中寻找匹配定义的制品。
				// 若找到了则直接搬过来。
				// 若没找到则新建。
				var oldArtifact:Null<Artifact> = null;
				for (a in oldArtifacts)
				{
					if (a != null && a.Definition == definition)
					{
						oldArtifact = a;
						break;
					}
				}
				if (oldArtifact != null)
				{
					artifacts[i] = oldArtifact;
					oldArtifacts.remove(oldArtifact);
				}
				else
				{
					var newArtifact = new Artifact(Level, definition);
					artifacts[i] = newArtifact;
					newArtifact.PostAdd();
					newArtifact.OnHighlighted.push(OnItemHighlightedCallback);
				}
			}
			// 之前制品列表中仍残留的制品被去除。
			for (oldArtifact in oldArtifacts)
			{
				if (oldArtifact == null)
					continue;
				oldArtifact.PostRemove();
				oldArtifact.OnHighlighted.remove(OnItemHighlightedCallback);
			}
		}
	}
	public function ReplaceArtifact(slot:Int, definition:Null<ArtifactDefinition>):Void
	{
		if (definition == null)
		{
			SetArtifact(slot, null);
		}
		else
		{
			SetArtifact(slot, new Artifact(Level, definition));
		}
	}
	public function SetArtifact(slot:Int, newArtifact:Null<Artifact>):Void
	{
		if (slot < 0 || slot >= artifacts.length)
			return;
		var oldArtifact = artifacts[slot];
		if (oldArtifact != null)
		{
			oldArtifact.PostRemove();
			oldArtifact.OnHighlighted.remove(OnItemHighlightedCallback);
		}
		artifacts[slot] = newArtifact;
		if (newArtifact != null)
		{
			newArtifact.PostAdd();
			newArtifact.OnHighlighted.push(OnItemHighlightedCallback);
		}
	}
	// PORT-NOTE: C# 有 4 个 HasArtifact / 2 个 GetArtifacts / 3 个 GetArtifactIndex 重载，Haxe 不支持重载，重命名如下：
	//   HasArtifact<T>()                -> HasArtifactOfType<T>()
	//   HasArtifact(ArtifactDefinition) -> HasArtifact(artifactDef)
	//   HasArtifact(NamespaceID)        -> HasArtifactByID(id)
	//   HasArtifact(Artifact)           -> ContainsArtifact(artifact)
	//   GetArtifacts<T>()               -> GetArtifactsOfType<T>()
	//   GetArtifacts(ArtifactDefinition)-> GetArtifactsByDefinition(buffDef)
	//   GetArtifactIndex(Artifact)      -> GetArtifactIndex(artifact)
	//   GetArtifactIndex(ArtifactDefinition) -> GetArtifactIndexByDefinition(def)
	//   GetArtifactIndex(NamespaceID)   -> GetArtifactIndexByID(id)
	// PORT-NOTE: C# 泛型方法 HasArtifact<T>()，Haxe 无显式类型实参，改为传入类对象。
	public function HasArtifactOfType<T:ArtifactDefinition>(typeClass:Class<T>):Bool
	{
		for (b in artifacts)
		{
			if (b != null && Std.isOfType(b.Definition, typeClass))
				return true;
		}
		return false;
	}
	public function HasArtifact(artifactDef:ArtifactDefinition):Bool
	{
		for (b in artifacts)
		{
			if (b != null && b.Definition == artifactDef)
				return true;
		}
		return false;
	}
	public function HasArtifactByID(id:NamespaceID):Bool
	{
		for (b in artifacts)
		{
			if (b != null && b.Definition != null && b.Definition.GetID() == id)
				return true;
		}
		return false;
	}
	public function ContainsArtifact(artifact:Artifact):Bool
	{
		return artifacts.indexOf(artifact) >= 0;
	}
	// PORT-NOTE: C# 泛型方法 GetArtifacts<T>()，Haxe 无显式类型实参，改为传入类对象。
	public function GetArtifactsOfType<T:ArtifactDefinition>(typeClass:Class<T>):Array<Artifact>
	{
		var result:Array<Artifact> = [];
		for (b in artifacts)
		{
			if (b != null && Std.isOfType(b.Definition, typeClass))
				result.push(b);
		}
		return result;
	}
	public function GetArtifactsByDefinition(buffDef:ArtifactDefinition):Array<Artifact>
	{
		var result:Array<Artifact> = [];
		for (b in artifacts)
		{
			if (b != null && b.Definition == buffDef)
				result.push(b);
		}
		return result;
	}
	public function GetArtifactIndex(artifact:Artifact):Int
	{
		return artifacts.indexOf(artifact);
	}
	public function GetArtifactIndexByDefinition(def:ArtifactDefinition):Int
	{
		for (i in 0...artifacts.length)
		{
			var a = artifacts[i];
			if (a != null && a.Definition == def)
				return i;
		}
		return -1;
	}
	public function GetArtifactIndexByID(id:NamespaceID):Int
	{
		for (i in 0...artifacts.length)
		{
			var a = artifacts[i];
			if (a != null && a.Definition != null && a.Definition.GetID() == id)
				return i;
		}
		return -1;
	}
	public function GetArtifactAt(index:Int):Null<Artifact>
	{
		if (index < 0 || index >= artifacts.length)
			return null;
		return artifacts[index];
	}
	public function GetAllArtifacts():Array<Null<Artifact>>
	{
		return artifacts.copy();
	}
	// #endregion

	// #region 序列化
	public function ToSerializable():SerializableArtifactList
	{
		var seri = new SerializableArtifactList();
		seri.artifacts = artifacts == null ? [] : [for (b in artifacts) b == null ? null : b.ToSerializable()];
		return seri;
	}
	public static function CreateFromSerializable(serializable:SerializableArtifactList, level:LevelEngine):ArtifactList
	{
		if (serializable.artifacts == null)
		{
			return new ArtifactList(level, 0);
		}
		var artifactList = new ArtifactList(level, serializable.artifacts.length);
		for (i in 0...artifactList.artifacts.length)
		{
			var seri = serializable.artifacts[i];
			if (seri == null)
				continue;
			var artifact = Artifact.CreateFromSerializable(seri, level);
			if (artifact == null)
				continue;
			artifact.OnHighlighted.push(artifactList.OnItemHighlightedCallback);
			artifactList.artifacts[i] = artifact;
		}
		return artifactList;
	}
	public function LoadFromSerializable(serializable:SerializableArtifactList):Void
	{
		if (serializable.artifacts == null)
			return;

		for (i in 0...artifacts.length)
		{
			if (i >= serializable.artifacts.length)
				continue;
			var seri = serializable.artifacts[i];
			if (seri == null)
				continue;
			var artifact = artifacts[i];
			if (artifact == null)
				continue;
			artifact.LoadFromSerializable(seri);
			Level.IncreaseLevelObjectReference(artifact, true);
		}
	}
	// #endregion

	public function Update():Void
	{
		for (artifact in artifacts)
		{
			if (artifact == null)
				continue;
			artifact.Update();
		}
	}
	private function OnItemHighlightedCallback(artifact:Artifact):Void
	{
		dispatchOnArtifactHighlighted(GetArtifactIndex(artifact));
	}

	// PORT-NOTE: C# event Action<int>? OnArtifactHighlighted -> Array<Int->Void>
	public var OnArtifactHighlighted:Array<Int->Void> = [];
	private function dispatchOnArtifactHighlighted(index:Int):Void
	{
		for (f in OnArtifactHighlighted.copy())
		{
			f(index);
		}
	}
	public var Level(default, null):LevelEngine;
	private var artifacts:Array<Null<Artifact>>;
}
