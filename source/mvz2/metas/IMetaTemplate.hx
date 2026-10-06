// Ported from: Assets/Scripts/MVZ2/Metas/IMetaTemplate.cs
package mvz2.metas;
import mvz2.metas.EntityMeta.BehaviourItem;  // IMPORTAUTO

interface IMetaTemplate {
    function GetBehaviours():Array<BehaviourItem>;
    function GetProperties():Map<String, Dynamic>;
}
