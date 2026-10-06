// Ported from: Assets/Scripts/View/Models/IModelBuilder.cs
package mvz2.models;

import unity.Transform;

interface IModelBuilder
{
	function Build(parent:Transform):Null<Model>;
}
