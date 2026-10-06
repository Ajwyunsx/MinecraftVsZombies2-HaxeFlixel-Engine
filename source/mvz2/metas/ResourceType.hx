// Ported from: Assets/Scripts/MVZ2/Metas/ResourceType.cs
package mvz2.metas;

enum abstract ResourceType(Int) from Int to Int {
    var Meta = 0;
    var Sound = 1;
    var Model = 2;
}
