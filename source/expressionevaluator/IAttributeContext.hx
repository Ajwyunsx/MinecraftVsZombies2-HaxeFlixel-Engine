// Ported from: Assets/Scripts/ExpressionEvaluator/IAttributeContext.cs

package expressionevaluator;

interface IAttributeContext {
	function EvaluateVariable(name:String):Dynamic;
	function EvaluateFunction(name:String, args:Array<Dynamic>):Dynamic;
}
