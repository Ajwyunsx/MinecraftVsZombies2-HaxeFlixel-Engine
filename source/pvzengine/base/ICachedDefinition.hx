// Ported from: Assets/Scripts/Engine/Base/Definitions/ICachedDefinition.cs
package pvzengine.base;

import pvzengine.IGameContent;

interface ICachedDefinition
{
    public function CacheContents(content:IGameContent):Void;
    public function ClearCaches():Void;
}
