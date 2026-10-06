// Ported from: Assets/Scripts/Logic/Shapes/ShapeDefinition.cs
// PORT-NOTE: IShapeDefinitionArmor 与 ShapeDefinition 同文件，但其 C# namespace 为 MVZ2Logic.Blueprints，
// 按 PORTING.md 的 namespace→package 映射单独成文件（包 mvz2logic.blueprints）。
package mvz2logic.blueprints;

import pvzengine.NamespaceID;
import unity.Vector3;

interface IShapeDefinitionArmor
{
	function GetArmorPosition(slotID:NamespaceID, armorID:NamespaceID):Vector3;
	function GetArmorScale(slotID:NamespaceID, armorID:NamespaceID):Vector3;
}
