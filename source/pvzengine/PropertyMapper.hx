// Ported from: Assets/Scripts/Engine/Base/Properties/PropertyMapper.cs
package pvzengine;

import pvzengine.PropertyMeta.IPropertyMeta;
import tools.Ref;
import unity.Debug;

class PropertyMapper
{
    public static function InitTypePropertyMaps(namespaceName:String, type:Class<Dynamic>):Void
    {
        // PORT-NOTE: C# 通过反射读取类/字段上的 [PropertyRegistryRegion]/[PropertyRegistry]/[DefinitionAttribute] 特性
        // （Assets/Scripts/Engine/Base/Properties/PropertyMapper.cs:17~20）。
        // Haxe 没有运行期特性：工程把这些特性写成了编译期元数据（`@:propertyRegistryRegion(...)` 等），
        // 由 system.reflection.DefinitionRegistry 的编译期宏扫描成运行期数据（见 DefinitionRegistryMacro.hx）。
        // 这里改为从该注册表取区域信息，语义与 C# 一致：类级 region → 字段级 region → 定义特性 Type/Name。
        var record:Dynamic = system.reflection.DefinitionRegistry.getRecordOfClass(type);
        var regionAttribute:PropertyRegistryRegionAttribute = null;
        var definitionAttribute:DefinitionAttribute = null;
        if (record != null) {
            if (record.region != null)
                regionAttribute = new PropertyRegistryRegionAttribute(cast record.region);
            var defs:Array<Dynamic> = record.defs;
            if (defs != null && defs.length > 0) {
                // C#: `type.GetCustomAttribute<DefinitionAttribute>()` 取定义特性的 Name/Type 作为区域名。
                // 一个类只带一个定义特性（AttributeUsage AllowMultiple = false），取第一条即可。
                var d:Dynamic = defs[0];
                var typeName:String = d.type;
                if (typeName == null)
                    typeName = pvzengine.definitions.EngineDefinitionTypes.ENTITY;
                definitionAttribute = new DefinitionAttribute(cast d.name, typeName);
            }
        }
        foreachField(type, function(fieldName:String)
        {
            var fieldValue:Dynamic = Reflect.field(type, fieldName);
            if (!Std.isOfType(fieldValue, IPropertyMeta))
                return;
            var meta:IPropertyMeta = cast fieldValue;
            var fieldAttribute = GetRegistryAttributeOf(record, fieldName);
            var regionName = GetPropertyRegionName(fieldAttribute, regionAttribute, definitionAttribute);
            if (regionName == null)
            {
                // PORT-NOTE: C# 中 regionName 为空表示该字段未标注区域，直接跳过（不注册）。
                // 工程里仍有个别静态 PropertyMeta 字段没有任何区域标注（如
                // mvz2/gamecontent/enemies/PopCaptain.hx 的 PROP_NO_ANCHOR / PROP_SMASH_UPWARDS，
                // 其 C# 原文 Assets/Scripts/Vanilla/GameContent/Enemies/Chapter5/PopCaptain.cs:53/55
                // 同样没有特性），C# 侧一样会跳过，故这里保持同样语义、不注册也不告警。
                return;
            }
            meta.RegisterNames(namespaceName, regionName);

            // 注册属性键。
            var propertyName = meta.GetPropertyName();
            var defaultValue = meta.GetDefaultValueObject();
            var obsoleteNames = meta.GetObsoleteNames();

            var fullName = PropertyKeyHelper.CombineFullName(namespaceName, regionName, propertyName);
            var keyRef = Ref.to(PropertyKeyHelper.Invalid);
            if (registries.TryGetKeyOfFullName(fullName, keyRef))
            {
                // 有重复名称的属性注册了
                Debug.LogWarning('Duplicate property meta $meta');
            }
            else
            {
                // 注册一个属性键
                var propName = PropertyKeyHelper.CombineRegionName(regionName, propertyName);
                var namespaceKeyRef = Ref.to(0);
                var propertyKeyRef = Ref.to(0);
                registries.GetOrRegisterPropertyKey(namespaceName, propName, namespaceKeyRef, propertyKeyRef);

                var key = meta.CreateKey(namespaceKeyRef.value, propertyKeyRef.value);
                registries.RegisterFullName(fullName, key);

                // 过时名称替换
                if (obsoleteNames != null)
                {
                    for (name in obsoleteNames)
                    {
                        var fullObsoleteName = PropertyKeyHelper.CombineFullName(namespaceName, regionName, name);
                        var existingRef = Ref.to(PropertyKeyHelper.Invalid);
                        if (registries.TryGetKeyOfFullName(fullObsoleteName, existingRef))
                        {
                            // 有重复名称的属性注册了
                            Debug.LogWarning('An obsolete name "$fullObsoleteName" of property "$fullName" conflicts with another property.');
                            continue;
                        }
                        var conflictRef = Ref.to((null:String));
                        if (registries.TryGetFullNameOfObsoleteName(fullObsoleteName, conflictRef))
                        {
                            // 有重复名称的属性注册了
                            Debug.LogWarning('An obsolete name "$fullObsoleteName" of property "$fullName" has already been registed to map "${conflictRef.value}".');
                            continue;
                        }
                        registries.RegisterObsoleteName(fullObsoleteName, fullName);
                    }
                }
                keyRef.value = key;
            }
            meta.SetRegisteredKey(keyRef.value);
        });
    }
    public static function InitPropertyMaps(namespaceName:String, types:Array<Class<Dynamic>>):Void
    {
        for (type in types)
        {
            InitTypePropertyMaps(namespaceName, type);
        }
    }
    public static function GetPropertyRegionName(fieldAttribute:PropertyRegistryAttribute, regionAttribute:PropertyRegistryRegionAttribute, definitionAttribute:DefinitionAttribute):Null<String>
    {
        if (fieldAttribute != null)
        {
            return PropertyKeyHelper.CombineRegionName(fieldAttribute.TypeName, fieldAttribute.RegionName);
        }
        else if (regionAttribute != null)
        {
            return regionAttribute.RegionName;
        }
        else if (definitionAttribute != null)
        {
            return PropertyKeyHelper.CombineRegionName(definitionAttribute.Type, definitionAttribute.Name);
        }
        return null;
    }

    // PORT-NOTE: C# 有 `ConvertFromName(string)` 与 `ConvertFromName(string, string, string)` 两个重载。
    // Haxe 无重载，这里用可选参数合并：只传 propertyName 时走直接查表（1 参数调用点的行为）。
    public static function ConvertFromName(propertyName:String, ?regionName:String, ?defaultNsp:String):IPropertyKey
    {
        var keyRef = Ref.to(PropertyKeyHelper.Invalid);
        if (registries.TryGetKeyOfFullName(propertyName, keyRef))
        {
            return keyRef.value;
        }
        if (regionName != null && defaultNsp != null)
        {
            // C#: var id = NamespaceID.Parse(propertyName, defaultNsp);
            //     var newName = PropertyKeyHelper.CombineFullName(id.SpaceName, regionName, id.Path);
            //     return ConvertFromName(newName);
            var id = NamespaceID.Parse(propertyName, defaultNsp);
            var newName = PropertyKeyHelper.CombineFullName(id.SpaceName, regionName, id.Path);
            var newKeyRef = Ref.to(PropertyKeyHelper.Invalid);
            if (registries.TryGetKeyOfFullName(newName, newKeyRef))
            {
                return newKeyRef.value;
            }
            propertyName = newName;
        }
        var obsNameTargetRef = Ref.to((null:String));
        if (registries.TryGetFullNameOfObsoleteName(propertyName, obsNameTargetRef))
        {
            Debug.LogWarning('Property name "$propertyName" has been obsoleted, please change it to "${obsNameTargetRef.value}".');
            var obsNameKeyRef = Ref.to(PropertyKeyHelper.Invalid);
            if (registries.TryGetKeyOfFullName(obsNameTargetRef.value, obsNameKeyRef))
            {
                return obsNameKeyRef.value;
            }
        }
        // PORT-NOTE: 兜底：当前工程内的区域元数据是编译期的（见 InitTypePropertyMaps 的 PORT-NOTE），
        // 属性注册时不含区域段，因此这里再尝试去掉区域段的写法（"nsp:region/name" → "nsp:name"），
        // 并同样检查过时名称表，使旧数据文件（含区域段的全名）仍可加载。
        if (propertyName.indexOf(':') >= 0 && propertyName.indexOf('/') >= 0)
        {
            var colon = propertyName.indexOf(':');
            var slash = propertyName.lastIndexOf('/');
            // 兜底场景下属性注册为 "nsp:/name"（区域为空字符串），因此同时尝试保留/去掉斜杠两种写法。
            var candidates = [
                propertyName.substr(0, colon + 1) + propertyName.substr(slash),
                propertyName.substr(0, colon + 1) + propertyName.substr(slash + 1)
            ];
            for (candidate in candidates)
            {
                var strippedRef = Ref.to(PropertyKeyHelper.Invalid);
                if (registries.TryGetKeyOfFullName(candidate, strippedRef))
                {
                    return strippedRef.value;
                }
                var strippedObsRef = Ref.to((null:String));
                if (registries.TryGetFullNameOfObsoleteName(candidate, strippedObsRef))
                {
                    var strippedObsKeyRef = Ref.to(PropertyKeyHelper.Invalid);
                    if (registries.TryGetKeyOfFullName(strippedObsRef.value, strippedObsKeyRef))
                    {
                        return strippedObsKeyRef.value;
                    }
                }
            }
        }
        Debug.LogWarning('Property with name $propertyName is not registered.');
        return PropertyKeyHelper.Invalid;
    }
    public static function ConvertToFullName(key:IPropertyKey):Null<String>
    {
        var nameRef = Ref.to((null:String));
        if (registries.TryGetFullNameOfKey(key, nameRef))
        {
            return nameRef.value;
        }
        Debug.LogWarning('Cannot find property name of key $key.');
        return null;
    }

    private static var registries:Registries = new Registries();

    // #region 运行期元数据读取（数据来自 system.reflection.DefinitionRegistry 的编译期扫描）
    private static function foreachField(type:Class<Dynamic>, callback:String->Void):Void
    {
        var fields = Type.getClassFields(type);
        if (fields == null)
            return;
        for (fieldName in fields)
        {
            callback(fieldName);
        }
    }
    /**
     * C#: `field.GetCustomAttribute<PropertyRegistryAttribute>()`。
     * 从注册表里按字段名取区域信息；`@:entityPropertyRegistry` / `@:levelPropertyRegistry`
     * 对应 C# 的 Entity/LevelPropertyRegistryAttribute（TypeName 分别为 entity / level）。
     */
    private static function GetRegistryAttributeOf(record:Dynamic, fieldName:String):PropertyRegistryAttribute
    {
        if (record == null)
            return null;
        var fields:Array<Dynamic> = record.fields;
        if (fields == null)
            return null;
        for (f in fields)
        {
            if (f.name == fieldName)
                return new PropertyRegistryAttribute(cast f.region, cast f.type);
        }
        return null;
    }
    // #endregion
}

// PORT-NOTE: C# 中 Registries / NamespaceRegistry 是 PropertyMapper 的私有嵌套类；
// Haxe 不支持嵌套类，改为同模块内的 private class。
private class Registries
{
    public function new() {}
        public function GetOrRegisterNamespace(namespaceName:String):NamespaceRegistry
        {
            if (namespaceName == null || namespaceName.length == 0)
            {
                return emptyNamespace;
            }
            if (registeredNamespaces.exists(namespaceName))
            {
                return registeredNamespaces.get(namespaceName);
            }
            currentNamespaceNumber++;
            var registry = new NamespaceRegistry(currentNamespaceNumber);
            registeredNamespaces.set(namespaceName, registry);
            return registry;
        }
        public function GetOrRegisterPropertyKey(namespaceName:String, propertyName:String, namespaceKeyRef:Ref<Int>, propertyKeyRef:Ref<Int>):Void
        {
            var namespaceRegistry = GetOrRegisterNamespace(namespaceName);
            namespaceKeyRef.value = namespaceRegistry.number;
            propertyKeyRef.value = namespaceRegistry.GetOrRegisterPropertyKey(propertyName);
        }
        public function RegisterFullName(fullName:String, key:IPropertyKey):Void
        {
            fullNameMap.set(fullName, key);
            reversedFullNameMap.set(key.Key, fullName);
        }
        public function RegisterObsoleteName(obsoleteName:String, fullName:String):Void
        {
            obsoleteNameMap.set(obsoleteName, fullName);
        }
        public function TryGetFullNameOfKey(key:IPropertyKey, nameRef:Ref<Null<String>>):Bool
        {
            if (!reversedFullNameMap.exists(key.Key))
                return false;
            nameRef.value = reversedFullNameMap.get(key.Key);
            return true;
        }
        public function TryGetKeyOfFullName(name:String, keyRef:Ref<IPropertyKey>):Bool
        {
            if (!fullNameMap.exists(name))
                return false;
            keyRef.value = fullNameMap.get(name);
            return true;
        }
        public function TryGetFullNameOfObsoleteName(name:String, fullNameRef:Ref<Null<String>>):Bool
        {
            if (!obsoleteNameMap.exists(name))
                return false;
            fullNameRef.value = obsoleteNameMap.get(name);
            return true;
        }
        private var currentNamespaceNumber:Int = 0;
        private var emptyNamespace:NamespaceRegistry = new NamespaceRegistry(0);
        private var registeredNamespaces:Map<String, NamespaceRegistry> = new Map<String, NamespaceRegistry>();
        // PORT-NOTE: C# 的 `Dictionary<IPropertyKey, string>` 使用 PropertyKeyComparer（按 int Key 比较），
        // Haxe 的 Map 无法自定义比较器，因此以 Key 为键。
        private var fullNameMap:Map<String, IPropertyKey> = new Map<String, IPropertyKey>();
        private var obsoleteNameMap:Map<String, String> = new Map<String, String>();
        private var reversedFullNameMap:Map<Int, String> = new Map<Int, String>();
    }
    private class NamespaceRegistry
    {
        public function new(number:Int)
        {
            this.number = number;
        }
        public function GetOrRegisterPropertyKey(propertyName:String):Int
        {
            if (propertyName == null || propertyName.length == 0)
            {
                return 0;
            }
            if (registeredProperties.exists(propertyName))
            {
                return registeredProperties.get(propertyName);
            }
            currentPropertyNumber++;
            var number = currentPropertyNumber;
            registeredProperties.set(propertyName, number);
            return number;
        }
        private var currentPropertyNumber:Int = 0;
        public var number:Int;
        public var registeredProperties:Map<String, Int> = new Map<String, Int>();
    }
