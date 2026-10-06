// Ported from: Assets/Scripts/MVZ2/Level/AreaModelInterface.cs
package mvz2.level;

import mvz2.models.Model;
import mvz2.models.ModelInterface;

class AreaModelInterface extends ModelInterface
{
	public function new(level:LevelController)
	{
		super();
		this.level = level;
	}
	override function GetModel():Model
	{
		return level.GetAreaModel();
	}

	private var level:LevelController;
}
