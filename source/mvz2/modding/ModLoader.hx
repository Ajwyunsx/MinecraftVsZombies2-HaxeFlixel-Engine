package mvz2.modding;

import mvz2.gamecontent.seeds.EntitySeed;
import mvz2logic.blueprints.EntitySeedDefinition;
import mvz2logic.seeds.OptionSeed;
import mvz2logic.spawns.SpawnEndlessBehaviour;
import mvz2logic.spawns.SpawnInLevelBehaviour;
import mvz2logic.spawns.SpawnPreviewBehaviour;
import mvz2.gamecontent.stages.ClassicStage;
import mvz2.gamecontent.stages.EndlessStage;
import mvz2.managers.MainManager;
import mvz2.managers.ResourceManager;
import mvz2.metas.AreaMeta;
import mvz2.metas.ArmorMeta;
import mvz2.metas.ArmorSlotMeta;
import mvz2.metas.ArtifactMeta;
import mvz2.metas.BlueprintErrorMeta;
import mvz2.metas.BlueprintOptionMeta;
import mvz2.metas.BuffMeta;
import mvz2.metas.CommandMeta;
import mvz2.metas.DifficultyMeta;
import mvz2.metas.EntityCounterMeta;
import mvz2.metas.EntityMeta;
import mvz2.metas.GridErrorMeta;
import mvz2.metas.GridLayerMeta;
import mvz2.metas.GridMeta;
import mvz2.metas.MapElementMeta;
import mvz2.metas.NoteMeta;
import mvz2.metas.OptionWidgetMeta;
import mvz2.metas.ShapeMeta;
import mvz2.metas.SpawnMeta;
import mvz2.metas.StageMeta;
import mvz2logic.Log;
import mvz2logic.armors.ArmorSlotDefinition;
import mvz2logic.armors.MetaArmorDefinition;
import mvz2logic.artifacts.ArtifactDefinition;
import mvz2logic.blueprints.LogicBlueprintID;
import mvz2logic.blueprints.LogicSeedOptionProps;
import mvz2logic.blueprints.SeedOptionDefinition;
import mvz2logic.commands.LogicCommandProps;
import mvz2logic.conditions.IConditionList;
import mvz2logic.definitions.LogicDefinitionTypes;
import mvz2logic.difficulties.LogicDifficultyProps;
import mvz2logic.entities.EntityCounterDefinition;
import mvz2logic.entities.LogicEntityProps;
import mvz2logic.entities.MetaEntityDefinition;
import mvz2logic.errors.ErrorMessageDefinition;
import mvz2logic.grids.LogicGridProps;
import mvz2logic.level.LogicAreaProps;
import mvz2logic.level.LogicStageProps;
import mvz2logic.maps.DefaultMapElement;
import mvz2logic.entities.LogicEntityProps;

import mvz2logic.modding.Mod;
import mvz2logic.notes.LogicNoteProps;
import mvz2logic.notes.NoteDefinition;
import mvz2logic.commands.LogicOptionWidgetProps;
import mvz2logic.options.OptionWidgetDefinition;
import mvz2logic.resources.SpriteReference;
import mvz2logic.shapes.ShapeDefinition;
import mvz2logic.spawns.LogicSpawnProps;
import pvzengine.spawns.SpawnDefinition;
import pvzengine.NamespaceID;
import pvzengine.PropertyMapper;
import pvzengine.base.Definition;
import pvzengine.buffs.EngineBuffProps;
import pvzengine.difficulties.DifficultyDefinition;
import pvzengine.grids.GridDefinition;
import pvzengine.level.EngineAreaProps;
import pvzengine.level.EngineStageProps;
import mvz2logic.grids.GridLayerDefinition;
import mvz2logic.spawns.LogicSpawnDefinition;
import system.reflection.Assembly;
import unity.Debug;
import pvzengine.DefinitionAttribute;
import mvz2logic.modding.IGlobalCallbacks;
import mvz2.gamecontent.commands.Load;
import mvz2logic.modding.ModGlobalCallbacksAttribute;
import system.io.Path;
import unity.Sprite;
import mvz2logic.level.StageTypes;
import mvz2.ui.Tooltip;
import mvz2.gamecontent.commands.Unlock;
import mvz2.gamecontent.seeds.EntitySeed.EntitySeedInfo;
import mvz2logic.maps.LogicEntityProps.LogicMapElementProps;
import flixel.addons.ui.Anchor;
import mvz2logic.commands.CommandDefinition;
import pvzengine.buffs.BuffDefinition;
import pvzengine.definitions.EngineDefinitionTypes;
import pvzengine.level.AreaDefinition;
import pvzengine.level.StageDefinition;

// PORT-NOTE: C# 中 ModLoader 用到的 Definition 属性读写几乎都是扩展方法（IGameContent/Definition 上的
// this 扩展），Haxe 侧统一用 `using` 把对应扩展类挂到调用点。
using mvz2logic.armors.LogicArmorProps;
using mvz2logic.artifacts.LogicArtifactProps;
using mvz2logic.blueprints.LogicSeedOptionProps;
using mvz2logic.blueprints.LogicSeedProps;
using mvz2logic.commands.LogicCommandProps;
using mvz2logic.commands.LogicOptionWidgetProps;
using mvz2logic.difficulties.LogicDifficultyProps;
using mvz2logic.entities.LogicContraptionProps;
using mvz2logic.entities.LogicEntityProps;
using mvz2logic.grids.LogicGridProps;
using mvz2logic.level.LogicAreaProps;
using mvz2logic.level.LogicLevelProps;
using mvz2logic.level.LogicStageProps;
using mvz2logic.maps.LogicEntityProps;
using mvz2logic.notes.LogicNoteProps;
using mvz2logic.spawns.LogicSpawnProps;
using pvzengine.buffs.EngineBuffProps;
using pvzengine.level.EngineAreaProps;
using pvzengine.level.EngineStageProps;

// Ported from: Assets/Scripts/MVZ2/Modding/ModLoader.cs
// PORT-NOTE: C# reflection (Assembly.GetTypes / GetCustomAttribute / Activator.CreateInstance) is
// replaced by Haxe's system.reflection.Assembly shim and Type-based helpers.
class ModLoader {
    public function new(main:MainManager) {
        this.main = main;
    }
    public function Load(mod:Mod, assemblies:Array<Assembly>):Void {
        LoadAssemblies(mod, assemblies);

        LoadDefinitions(mod);

        LoadDefinitionProperties(mod);
    }

    // #region 初始化
    // PORT-NOTE: C# 用反射扫描 Mod 程序集（Assembly.GetTypes / HasCustomAttribute / IsAbstract /
    // GetCustomAttributes / Activator.CreateInstance）来发现 Definition 与 ModGlobalCallbacks。
    // Haxe 没有运行期反射，工程把这些 C# 特性改写成了编译期元数据（`@:auto*Definition` /
    // `@:modGlobalCallbacks` / `@:propertyRegistryRegion`），由
    // `system.reflection.DefinitionRegistryMacro` 在编译期扫描后注入 `system.reflection.DefinitionRegistry`；
    // `system.reflection.Assembly` 就是这批数据上的「程序集视图」。
    // 下面这些动态调用形式（`Reflect.field(assembly, "GetTypes")`）与 C# 原文一一对应，无需再改。
    private static function AssemblyGetTypes(assembly:Assembly):Array<Class<Dynamic>> {
        var dynamicAssembly:Dynamic = assembly;
        var getTypes:Dynamic = Reflect.field(dynamicAssembly, "GetTypes");
        if (getTypes == null)
            return [];
        var types:Dynamic = getTypes();
        return types == null ? [] : cast types;
    }
    private static function AssemblyIsAbstract(assembly:Assembly, type:Class<Dynamic>):Bool {
        var dynamicAssembly:Dynamic = assembly;
        var isAbstract:Dynamic = Reflect.field(dynamicAssembly, "IsAbstract");
        return isAbstract == null ? false : cast isAbstract(type);
    }
    private static function AssemblyHasCustomAttribute(assembly:Assembly, type:Class<Dynamic>, attributeName:String):Bool {
        var dynamicAssembly:Dynamic = assembly;
        var hasAttribute:Dynamic = Reflect.field(dynamicAssembly, "HasCustomAttribute");
        return hasAttribute == null ? false : cast hasAttribute(type, attributeName);
    }
    private static function AssemblyGetCustomAttributes(assembly:Assembly, type:Class<Dynamic>, attributeName:String):Array<Dynamic> {
        var dynamicAssembly:Dynamic = assembly;
        var getAttributes:Dynamic = Reflect.field(dynamicAssembly, "GetCustomAttributes");
        if (getAttributes == null)
            return [];
        var attributes:Dynamic = getAttributes(type, attributeName);
        return attributes == null ? [] : cast attributes;
    }
    private static function AssemblyInvokeConstructor(assembly:Assembly, type:Class<Dynamic>, args:Array<Dynamic>):Dynamic {
        var dynamicAssembly:Dynamic = assembly;
        var invokeConstructor:Dynamic = Reflect.field(dynamicAssembly, "InvokeConstructor");
        return invokeConstructor == null ? null : invokeConstructor(type, args);
    }
    private function LoadAssemblies(mod:Mod, assemblies:Array<Assembly>):Void {
        var nsp = mod.Namespace;
        for (assembly in assemblies) {
            var types = AssemblyGetTypes(assembly);
            PropertyMapper.InitPropertyMaps(nsp, types);
        }

        for (assembly in assemblies) {
            var types = AssemblyGetTypes(assembly);
            for (type in types) {
                if (AssemblyHasCustomAttribute(assembly, type, "ModGlobalCallbacksAttribute") && !AssemblyIsAbstract(assembly, type)) {
                    var instance:Dynamic = Type.createInstance(type, []);
                    if (Std.isOfType(instance, mvz2logic.modding.IGlobalCallbacks)) {
                        mod.ApplyGlobalCallbacks(cast instance);
                    }
                }

                if (!AssemblyIsAbstract(assembly, type)) {
                    var definitionAttributes = AssemblyGetCustomAttributes(assembly, type, "DefinitionAttribute");
                    for (attribute in definitionAttributes) {
                        if (attribute == null)
                            continue;
                        var name:String = Reflect.field(attribute, "Name");
                        var instance:Dynamic = AssemblyInvokeConstructor(assembly, type, [nsp, name]);
                        if (Std.isOfType(instance, Definition)) {
                            mod.AddDefinition(cast instance);
                        }
                    }
                }

            }
        }
    }
    // #endregion

    // #region 加载Definitions
    private function LoadDefinitions(mod:Mod):Void {
        // 以下这这些没有相关联的定义类型，必须要手动创建。
        // 加载所有实体。
        LoadEntityMetas(mod);
        // 加载所有实体对策。
        LoadEntityCounterMetas(mod);
        // 加载所有实体形状。
        LoadEntityShapes(mod);

        // 加载所有护甲。
        LoadArmorMetas(mod);
        LoadArmorSlotMetas(mod);
        // 加载所有敌人生成信息。
        LoadSpawnMetas(mod);

        // 加载所有网格层信息。
        LoadGridLayerMetas(mod);
        // 加载所有网格错误信息。
        LoadGridErrorMetas(mod);

        // 加载所有难度。
        LoadDifficultyMetas(mod);

        // 加载所有关卡Meta。
        LoadStages(mod);

        LoadCustomEntityBlueprints(mod);
        // 加载所有蓝图错误信息。
        LoadBlueprintErrorMetas(mod);
        // 加载所有增益信息。
        LoadBuffMetas(mod);
        // 加载所有地图元素信息。
        LoadMapElementMetas(mod);
    }
    private function LoadEntityMetas(mod:Mod):Void {
        var nsp = mod.Namespace;
        for (meta in res.GetModEntityMetas(nsp)) {
            if (meta == null)
                continue;
            var name = meta.ID;
            var def = new MetaEntityDefinition(meta.Type, nsp, name);
            var entityID = def.GetID();

            def.SetProperty(LogicEntityProps.NAME, meta.Name);
            def.SetProperty(LogicEntityProps.DEATH_MESSAGE, meta.DeathMessage);
            def.SetProperty(LogicEntityProps.TOOLTIP, meta.Tooltip);
            def.SetPropertyObject(LogicEntityProps.UNLOCK, meta.Unlock);
            // 加载实体的属性。
            for (key in meta.Properties.keys()) {
                def.SetPropertyObject(PropertyMapper.ConvertFromName(key), meta.Properties.get(key));
            }
            for (behaviourID in meta.Behaviours) {
                def.AddBehaviourID(behaviourID);
            }
            mod.AddDefinition(def);

            // 将实体作为蓝图添加到游戏中。
            var mobileID = new NamespaceID(entityID.SpaceName, 'mobile_blueprint/${entityID.Path}');
            var info = new EntitySeedInfo({
                entityID: entityID,
                // PORT-NOTE: C# 重载 GetCost/GetRechargeID/IsTriggerActive/IsUpgradeBlueprint(this EntityDefinition)
                // 在移植层分别改名为 GetCostOfDefinition / GetRechargeIDOfDefinition /
                // IsTriggerActiveOfDefinition / IsUpgradeBlueprintOfDefinition（见 LogicEntityProps / LogicContraptionProps）。
                cost: def.GetCostOfDefinition(),
                rechargeID: def.GetRechargeIDOfDefinition(),
                triggerActive: def.IsTriggerActiveOfDefinition(),
                canInstantTrigger: def.CanInstantTrigger(),
                upgrade: def.IsUpgradeBlueprintOfDefinition(),
                canInstantEvoke: def.CanInstantEvoke(),
                model: def.GetModelID(),
                mobileIcon: new SpriteReference(mobileID)
            });
            var blueprintID = LogicBlueprintID.FromEntity(entityID);
            var seedDef = new EntitySeed(blueprintID.SpaceName, blueprintID.Path, info);
            mod.AddDefinition(seedDef);
        }
    }
    private function LoadEntityCounterMetas(mod:Mod):Void {
        var nsp = mod.Namespace;
        for (meta in res.GetModEntityCounterMetas(nsp)) {
            if (meta == null)
                continue;
            var name = meta.ID;
            var def = new EntityCounterDefinition(nsp, name, meta.Name);
            mod.AddDefinition(def);
        }
    }
    private function LoadEntityShapes(mod:Mod):Void {
        var nsp = mod.Namespace;
        for (meta in res.GetModShapeMetas(nsp)) {
            if (meta == null)
                continue;
            var name = meta.ID;
            var def = new ShapeDefinition(nsp, name);
            def.Armors = meta.Armors;
            mod.AddDefinition(def);
        }
    }
    private function LoadArmorMetas(mod:Mod):Void {
        var nsp = mod.Namespace;
        for (meta in res.GetModArmorMetas(nsp)) {
            if (meta == null)
                continue;
            var name = meta.ID;
            var def = new MetaArmorDefinition(nsp, name, meta.ColliderConstructors);
            def.SetArmorType(meta.Type);
            def.SetIgnored(meta.Ignored);

            // 加载护甲的属性。
            for (key in meta.Properties.keys()) {
                def.SetPropertyObject(PropertyMapper.ConvertFromName(key), meta.Properties.get(key));
            }
            for (behaviourID in meta.Behaviours) {
                def.AddBehaviourID(behaviourID);
            }
            mod.AddDefinition(def);
        }
    }
    private function LoadArmorSlotMetas(mod:Mod):Void {
        var nsp = mod.Namespace;
        for (meta in res.GetModArmorSlotMetas(nsp)) {
            if (meta == null)
                continue;
            var name = meta.Name;
            var def = new ArmorSlotDefinition(nsp, name, meta.Anchor);
            def.HPBarColor = meta.HPBarColor;
            def.HPBarIcon = meta.HPBarIcon;
            mod.AddDefinition(def);
        }
    }
    private function LoadSpawnMetas(mod:Mod):Void {
        var nsp = mod.Namespace;
        for (meta in res.GetModSpawnMetas(nsp)) {
            if (meta == null)
                continue;
            var name = meta.ID;
            var type = meta.Type;
            var entityID = meta.Entity;

            var spawnDef:SpawnDefinition = null;
            if (type == "entity") {
                if (NamespaceID.IsValid(entityID)) {
                    var def = new LogicSpawnDefinition(nsp, name);
                    var preview = new SpawnPreviewBehaviour();
                    var inLevel = new SpawnInLevelBehaviour();
                    var endless = new SpawnEndlessBehaviour();
                    def.SetBehaviours(inLevel, preview, endless);
                    spawnDef = def;
                }
            } else {
                // PORT-NOTE: C# 的 mod.GetSpawnDefinition(id) 是 IGameContent 扩展方法；移植层 Mod 未实现
                // IGameContent（见 Mod.hx 的 PORT-NOTE），改用 Mod 自身的 GetDefinition(type, id)。
                spawnDef = mod.GetDefinition(EngineDefinitionTypes.SPAWN, new NamespaceID(nsp, name));
            }
            if (spawnDef == null) {
                Debug.LogWarning('Could not create SpawnDefinition for spawn meta ${nsp}:${name}');
                continue;
            }
            mod.AddDefinition(spawnDef);
        }
    }
    private function LoadStages(mod:Mod):Void {
        var nsp = mod.Namespace;
        for (meta in res.GetModStageMetas(nsp)) {
            if (meta == null)
                continue;
            var stageDef:StageDefinition = null;
            switch (meta.Type) {
                case StageTypes.TYPE_NORMAL:
                    {
                        stageDef = new ClassicStage(nsp, meta.ID);
                    }
                case StageTypes.TYPE_ENDLESS:
                    {
                        stageDef = new EndlessStage(nsp, meta.ID);
                    }
                default:
            }
            if (stageDef != null) {
                mod.AddDefinition(stageDef);
            }
        }
    }
    private function LoadGridLayerMetas(mod:Mod):Void {
        var nsp = mod.Namespace;
        for (meta in res.GetModGridLayerMetas(nsp)) {
            if (meta == null)
                continue;
            var name = meta.ID;
            var def = new GridLayerDefinition(nsp, name, meta.AlmanacTag);
            def.HPBarColor = meta.HPBarColor;
            def.HPBarIcon = meta.HPBarIcon;
            mod.AddDefinition(def);
        }
    }
    private function LoadGridErrorMetas(mod:Mod):Void {
        var nsp = mod.Namespace;
        for (meta in res.GetModGridErrorMetas(nsp)) {
            if (meta == null)
                continue;
            var name = meta.ID;
            var def = new ErrorMessageDefinition(nsp, name, LogicDefinitionTypes.GRID_ERROR, meta.Message);
            mod.AddDefinition(def);
        }
    }
    private function LoadDifficultyMetas(mod:Mod):Void {
        var nsp = mod.Namespace;
        for (meta in res.GetModDifficultyMetas(nsp)) {
            if (meta == null)
                continue;
            var name = meta.ID;
            var def = new DifficultyDefinition(nsp, name);
            def.SetProperty(LogicDifficultyProps.NAME, meta.Name);
            def.SetProperty(LogicDifficultyProps.VALUE, meta.Value);
            def.SetProperty(LogicDifficultyProps.BUFF_ID, meta.BuffID);
            def.SetProperty(LogicDifficultyProps.I_ZOMBIE_BUFF_ID, meta.IZombieBuffID);
            def.SetProperty(LogicDifficultyProps.CLEAR_MONEY, meta.ClearMoney);
            def.SetProperty(LogicDifficultyProps.RERUN_CLEAR_MONEY, meta.RerunClearMoney);
            def.SetProperty(LogicDifficultyProps.CART_CONVERT_MONEY, meta.CartConvertMoney);
            def.SetProperty(LogicDifficultyProps.PUZZLE_MONEY, meta.PuzzleMoney);
            def.SetProperty(LogicDifficultyProps.MAP_BUTTON_BORDER_BACK, meta.MapButtonBorderBack);
            def.SetProperty(LogicDifficultyProps.MAP_BUTTON_BORDER_BOTTOM, meta.MapButtonBorderBottom);
            def.SetProperty(LogicDifficultyProps.MAP_BUTTON_BORDER_OVERLAY, meta.MapButtonBorderOverlay);
            def.SetProperty(LogicDifficultyProps.ARCADE_ICON, meta.ArcadeIcon);
            mod.AddDefinition(def);
        }
    }
    private function LoadBlueprintErrorMetas(mod:Mod):Void {
        var nsp = mod.Namespace;
        for (meta in res.GetModBlueprintErrorMetas(nsp)) {
            if (meta == null)
                continue;
            var name = meta.ID;
            var def = new ErrorMessageDefinition(nsp, name, LogicDefinitionTypes.SEED_ERROR, meta.Message);
            mod.AddDefinition(def);
        }
    }
    private function LoadCustomEntityBlueprints(mod:Mod):Void {
        var nsp = mod.Namespace;
        for (meta in res.GetModEntityBlueprintMetas(nsp)) {
            if (meta == null)
                continue;
            var entityID = meta.EntityID;
            if (!NamespaceID.IsValid(entityID))
                continue;

            var def = new EntitySeedDefinition(nsp, meta.ID, meta.Name, meta.Tooltip);
            mod.AddDefinition(def);

            // 将实体作为蓝图添加到游戏中。
            var info = new EntitySeedInfo({
                entityID: entityID,
                cost: meta.Cost,
                rechargeID: meta.RechargeID,
                triggerActive: meta.IsTriggerActive(),
                canInstantTrigger: meta.CanInstantTrigger(),
                upgrade: meta.IsUpgradeBlueprint(),
                canInstantEvoke: meta.CanInstantEvoke(),
                variant: meta.Variant,
                icon: meta.GetIcon(),
                mobileIcon: meta.GetMobileIcon(),
                model: meta.GetModelID()
            });
            var seedDef = new EntitySeed(nsp, meta.ID, info);
            mod.AddDefinition(seedDef);
        }
    }
    private function LoadBuffMetas(mod:Mod):Void {
        var nsp = mod.Namespace;
        // PORT-NOTE: C# 的 mod.GetAllBuffDefinitions() 是 IGameContent 扩展方法；移植层改用 Mod.GetDefinitionsByType。
        var buffDefinitions:Array<BuffDefinition> = mod.GetDefinitionsByType(EngineDefinitionTypes.BUFF);
        for (buffDefinition in buffDefinitions) {
            var id = buffDefinition.GetID();
            var meta = res.GetBuffMeta(id);
            if (meta == null) {
                Debug.LogWarning('Could not find the buff meta for buff definition ${id}!');
                continue;
            }
            var polarity = meta.Polarity;
            var level = meta.Level;

            buffDefinition.SetProperty(EngineBuffProps.POLARITY, polarity);
            buffDefinition.SetProperty(EngineBuffProps.BUFF_LEVEL, level);
        }
    }
    private function LoadMapElementMetas(mod:Mod):Void {
        var nsp = mod.Namespace;
        for (meta in res.GetModMapElementMetas(nsp)) {
            if (meta == null)
                continue;
            var name = meta.id;
            var def = new DefaultMapElement(nsp, name);
            var entityID = def.GetID();

            def.SetPropertyObject(LogicMapElementProps.UNLOCK_CONDITIONS, meta.unlockConditions);

            for (key in meta.properties.keys()) {
                def.SetPropertyObject(PropertyMapper.ConvertFromName(key), meta.properties.get(key));
            }
            for (behaviourID in meta.behaviours) {
                def.AddBehaviourID(behaviourID);
            }
            mod.AddDefinition(def);
        }
    }
    // #endregion

    // #region 加载Definition属性
    public function LoadDefinitionProperties(mod:Mod):Void {
        // 以下会通过LoadDefinitionsFromAssemblies自动创建，因此只需要读取额外信息。
        // 加载所有地形信息。
        LoadAreaProperties(mod);
        // 加载所有制品信息。
        LoadArtifactProperties(mod);
        // 加载选项蓝图信息。
        LoadSeedOptionProperties(mod);

        LoadSpawnProperties(mod);
        LoadStageProperties(mod);
        // 加载所有命令属性。
        LoadCommandProperties(mod);
        // 加载所有笔记属性。
        LoadNoteProperties(mod);
        // 加载所有地格属性。
        LoadGridProperties(mod);
        LoadOptionWidgetProperties(mod);
    }
    private function LoadAreaProperties(mod:Mod):Void {
        var nsp = mod.Namespace;
        for (meta in res.GetModAreaMetas(nsp)) {
            if (meta == null)
                continue;
            // PORT-NOTE: C# 的 mod.GetAreaDefinition(id) 是 IGameContent 扩展方法；移植层改用 Mod.GetDefinition。
            var area:AreaDefinition = mod.GetDefinition(EngineDefinitionTypes.AREA, new NamespaceID(nsp, meta.ID));
            if (area == null)
                continue;
            area.SetProperty(LogicAreaProps.MODEL_ID, meta.ModelID);
            area.SetProperty(LogicStageProps.MUSIC_ID, meta.MusicID);
            area.SetProperty(EngineAreaProps.CART_REFERENCE, meta.Cart);
            area.SetProperty(EngineAreaProps.AREA_TAGS, meta.Tags);
            area.SetProperty(LogicAreaProps.STARSHARD_ICON, meta.StarshardIcon);

            area.SetProperty(EngineAreaProps.ENEMY_SPAWN_X, meta.EnemySpawnX);
            area.SetProperty(LogicAreaProps.DOOR_Z, meta.DoorZ);

            area.SetProperty(LogicAreaProps.BACKGROUND_LIGHT, meta.BackgroundLight);
            area.SetProperty(LogicAreaProps.GLOBAL_LIGHT, meta.GlobalLight);

            area.SetProperty(EngineAreaProps.GRID_WIDTH, meta.GridWidth);
            area.SetProperty(EngineAreaProps.GRID_HEIGHT, meta.GridHeight);
            area.SetProperty(EngineAreaProps.GRID_LEFT_X, meta.GridLeftX);
            area.SetProperty(EngineAreaProps.GRID_BOTTOM_Z, meta.GridBottomZ);
            area.SetProperty(EngineAreaProps.ENTITY_LANE_Z_OFFSET, meta.EntityLaneZOffset);
            area.SetProperty(EngineAreaProps.MAX_LANE_COUNT, meta.Lanes);
            area.SetProperty(EngineAreaProps.MAX_COLUMN_COUNT, meta.Columns);

            area.SetGridLayout(Lambda.array(Lambda.map(meta.Grids, m -> m.ID)));
        }
    }
    private function LoadSeedOptionProperties(mod:Mod):Void {
        var nsp = mod.Namespace;
        for (meta in res.GetModBlueprintOptionMetas(nsp)) {
            if (meta == null)
                continue;
            // PORT-NOTE: C# 的 mod.GetSeedOptionDefinition(id) 是 IGameContent 扩展方法；移植层改用 Mod.GetDefinition。
            var seedOptionDefinition:SeedOptionDefinition = mod.GetDefinition(LogicDefinitionTypes.SEED_OPTION, new NamespaceID(nsp, meta.ID));
            if (seedOptionDefinition == null)
                continue;
            seedOptionDefinition.SetProperty(LogicSeedOptionProps.COST, meta.Cost);
            seedOptionDefinition.SetProperty(LogicSeedOptionProps.NAME, meta.Name);
            seedOptionDefinition.SetProperty(LogicSeedOptionProps.TOOLTIP, meta.Tooltip);
            seedOptionDefinition.SetProperty(LogicSeedOptionProps.ICON, meta.GetIcon());
            seedOptionDefinition.SetProperty(LogicSeedOptionProps.MOBILE_ICON, meta.GetMobileIcon());
            seedOptionDefinition.SetProperty(LogicSeedOptionProps.MODEL_ID, meta.GetModelID());

            var seedDef = new OptionSeed(nsp, seedOptionDefinition.Name, seedOptionDefinition.GetCost());
            seedDef.SetIcon(seedOptionDefinition.GetIcon());
            seedDef.SetMobileIcon(seedOptionDefinition.GetMobileIcon());
            seedDef.SetModelID(seedOptionDefinition.GetModelID());
            mod.AddDefinition(seedDef);
        }
    }
    private function LoadArtifactProperties(mod:Mod):Void {
        var nsp = mod.Namespace;
        for (meta in res.GetModArtifactMetas(nsp)) {
            if (meta == null)
                continue;
            var name = meta.ID;
            // PORT-NOTE: C# 的 mod.GetArtifactDefinition(id) 是 IGameContent 扩展方法；移植层改用 Mod.GetDefinition。
            var artifact:ArtifactDefinition = mod.GetDefinition(LogicDefinitionTypes.ARTIFACT, new NamespaceID(nsp, name));
            if (artifact == null)
                continue;
            artifact.SetArtifactName(meta.Name);
            artifact.SetArtifactTooltip(meta.Tooltip);
            artifact.SetUnlockConditions(meta.UnlockConditions);
            artifact.SetSpriteReference(meta.Sprite);
        }
    }
    private function LoadStageProperties(mod:Mod):Void {
        var nsp = mod.Namespace;
        for (meta in res.GetModStageMetas(nsp)) {
            if (meta == null)
                continue;
            var name = meta.ID;
            // PORT-NOTE: C# 的 mod.GetStageDefinition(id) 是 IGameContent 扩展方法；移植层改用 Mod.GetDefinition。
            var stageDef:StageDefinition = mod.GetDefinition(EngineDefinitionTypes.STAGE, new NamespaceID(nsp, name));
            if (stageDef == null)
                continue;
            stageDef.SetLevelName(meta.Name);
            stageDef.SetDayNumber(meta.DayNumber);
            stageDef.SetStartEnergy(meta.StartEnergy);

            stageDef.SetProperty(LogicStageProps.MUSIC_ID, meta.MusicID);
            stageDef.SetProperty(LogicStageProps.STAGE_TYPE, meta.Type);
            stageDef.SetPropertyObject(LogicStageProps.UNLOCK_CONDITIONS, meta.UnlockConditions);
            stageDef.SetProperty(LogicStageProps.MODEL_PRESET, meta.ModelPreset);

            stageDef.SetProperty(LogicStageProps.NO_START_TALK_MUSIC, meta.NoStartTalkMusic);

            stageDef.SetProperty(LogicStageProps.CLEAR_PICKUP_MODEL, meta.ClearPickupModel);
            stageDef.SetProperty(LogicStageProps.CLEAR_PICKUP_CONTENT_ID, meta.ClearPickupContentID);
            stageDef.SetProperty(LogicStageProps.DROPS_TROPHY, meta.DropsTrophy);
            stageDef.SetProperty(LogicStageProps.END_NOTE_ID, meta.EndNote);

            stageDef.SetProperty(LogicStageProps.START_CAMERA_POSITION, cast meta.StartCameraPosition);
            stageDef.SetProperty(LogicStageProps.START_TRANSITION, meta.StartTransition);

            stageDef.SetProperty(EngineStageProps.TOTAL_FLAGS, meta.TotalFlags);
            stageDef.SetProperty(EngineStageProps.FIRST_WAVE_TIME, meta.FirstWaveTime);
            stageDef.SetProperty(EngineStageProps.CONTINUED_FIRST_WAVE_TIME, meta.EndlessFirstWaveTime);
            stageDef.SetProperty(LogicStageProps.WAVE_MAX_TIME, meta.MaxWaveTime);
            stageDef.SetProperty(LogicStageProps.WAVE_ADVANCE_TIME, meta.AdvanceWaveTime);
            stageDef.SetProperty(LogicStageProps.WAVE_ADVANCE_HEALTH_PERCENT, meta.AdvanceHealthPercent);

            stageDef.SetProperty(LogicStageProps.ENEMY_POOL, meta.Spawns);
            stageDef.SetPropertyObject(LogicStageProps.TALKS, meta.Talks);
            stageDef.SetPropertyObject(LogicStageProps.CONVEYOR_POOL, meta.ConveyorPool);

            stageDef.SetNeedBlueprints(meta.NeedBlueprints);
            stageDef.SetSpawnPointPower(meta.SpawnPointsPower);
            stageDef.SetSpawnPointMultiplier(meta.SpawnPointsMultiplier);
            stageDef.SetSpawnPointAddition(meta.SpawnPointsAddition);

            for (key in meta.Properties.keys()) {
                stageDef.SetPropertyObject(PropertyMapper.ConvertFromName(key), meta.Properties.get(key));
            }
        }
    }
    private function LoadCommandProperties(mod:Mod):Void {
        var nsp = mod.Namespace;
        for (meta in res.GetModCommandMetas(nsp)) {
            if (meta == null)
                continue;
            var name = meta.ID;
            // PORT-NOTE: C# 的 mod.GetCommandDefinition(id) 是 IGameContent 扩展方法；移植层改用 Mod.GetDefinition。
            var def:CommandDefinition = mod.GetDefinition(LogicDefinitionTypes.COMMAND, new NamespaceID(nsp, name));
            if (def == null)
                continue;
            def.SetProperty(LogicCommandProps.DESCRIPTION, meta.Description);
            def.SetProperty(LogicCommandProps.MUST_IN_LEVEL, meta.InLevel);
            def.SetPropertyObject(LogicCommandProps.VARIANTS, meta.Variants);
        }
    }
    private function LoadSpawnProperties(mod:Mod):Void {
        var nsp = mod.Namespace;
        // PORT-NOTE: C# 的 mod.GetAllSpawnDefinitions() 是 IGameContent 扩展方法；移植层改用 Mod.GetDefinitionsByType。
        var spawnDefinitions:Array<SpawnDefinition> = mod.GetDefinitionsByType(EngineDefinitionTypes.SPAWN);
        for (def in spawnDefinitions) {
            var meta = res.GetSpawnMeta(def.GetID());
            if (meta == null)
                continue;
            var weight = meta.Weight;
            def.SetProperty(LogicSpawnProps.PREVIEW_ENTITY, meta.PreviewEntity);
            def.SetProperty(LogicSpawnProps.PREVIEW_VARIANT, meta.PreviewVariant);
            def.SetProperty(LogicSpawnProps.PREVIEW_COUNT, meta.PreviewCount);

            def.SetProperty(LogicSpawnProps.MIN_SPAWN_WAVE, meta.MinSpawnWave);
            def.SetProperty(LogicSpawnProps.SPAWN_LEVEL, meta.SpawnLevel);
            def.SetProperty(LogicSpawnProps.SPAWN_IN_WATER, meta.Terrain != null ? meta.Terrain.Water : false);
            def.SetProperty(LogicSpawnProps.SPAWN_IN_AIR, meta.Terrain != null ? meta.Terrain.Air : false);
            def.SetProperty(LogicSpawnProps.SPAWN_ENTITY, meta.Entity);
            def.SetProperty(LogicSpawnProps.SPAWN_ENTITY_VARIANT, meta.EntityVariant);

            def.SetProperty(LogicSpawnProps.NO_ENDLESS, meta.NoEndless);
            def.SetProperty(LogicSpawnProps.EXCLUDED_AREA_TAGS, meta.Terrain != null ? meta.Terrain.ExcludedAreaTags : []);

            if (weight != null) {
                def.SetProperty(LogicSpawnProps.WEIGHT_BASE, weight.Base);
                def.SetProperty(LogicSpawnProps.WEIGHT_DECAY_START, weight.DecreaseStart);
                def.SetProperty(LogicSpawnProps.WEIGHT_DECAY_END, weight.DecreaseEnd);
                def.SetProperty(LogicSpawnProps.WEIGHT_DECAY, weight.DecreasePerFlag);
            }
        }

    }
    private function LoadNoteProperties(mod:Mod):Void {
        var nsp = mod.Namespace;
        // PORT-NOTE: C# 的 mod.GetAllNoteDefinitions() 是 IGameContent 扩展方法；移植层改用 Mod.GetDefinitionsByType。
        var noteDefinitions:Array<NoteDefinition> = mod.GetDefinitionsByType(LogicDefinitionTypes.NOTE);
        for (def in noteDefinitions) {
            if (def == null)
                continue;
            var id = def.GetID();
            var meta = res.GetNoteMeta(id);
            if (meta == null)
                continue;
            def.SetProperty(LogicNoteProps.CAN_FLIP, meta.canFlip);
            def.SetProperty(LogicNoteProps.NOTE_BACKGROUND, meta.background);
            def.SetProperty(LogicNoteProps.NOTE_SPRITE, meta.sprite);
            def.SetProperty(LogicNoteProps.FLIP_NOTE_SPRITE, meta.flipSprite);
            def.SetProperty(LogicNoteProps.START_TALK, meta.startTalk);
        }
    }
    private function LoadGridProperties(mod:Mod):Void {
        var nsp = mod.Namespace;
        // PORT-NOTE: C# 的 mod.GetAllGridDefinitions() 是 IGameContent 扩展方法；移植层改用 Mod.GetDefinitionsByType。
        var gridDefinitions:Array<GridDefinition> = mod.GetDefinitionsByType(EngineDefinitionTypes.GRID);
        for (def in gridDefinitions) {
            if (def == null)
                continue;
            var id = def.GetID();
            var meta = res.GetGridMeta(id);
            if (meta == null)
                continue;
            def.SetProperty(LogicGridProps.OVERLAY_SPRITE, meta.OverlaySprite);
            def.SetProperty(LogicGridProps.SLOPE, meta.Slope);
        }
    }
    private function LoadOptionWidgetProperties(mod:Mod):Void {
        var nsp = mod.Namespace;
        // PORT-NOTE: C# 的 mod.GetAllOptionWidgetDefinitions() 是 IGameContent 扩展方法；移植层改用 Mod.GetDefinitionsByType。
        var optionWidgetDefinitions:Array<OptionWidgetDefinition> = mod.GetDefinitionsByType(LogicDefinitionTypes.OPTION_WIDGET);
        for (def in optionWidgetDefinitions) {
            if (def == null)
                continue;
            var id = def.GetID();
            var meta = res.GetOptionWidgetMeta(id);
            if (meta == null) {
                Log.LogWarning('Could not find option widget meta for OptionWidgetDefinition ${def}.');
                continue;
            }
            def.SetProperty(LogicOptionWidgetProps.CATEGORY_ID, meta.Category);
            def.SetProperty(LogicOptionWidgetProps.TOOLTIP, meta.Tooltip);
            def.SetProperty(LogicOptionWidgetProps.LABEL, meta.Label);
            def.SetProperty(LogicOptionWidgetProps.ORDER, meta.Order);
            def.SetProperty(LogicOptionWidgetProps.SLIDER_MIN_VALUE, meta.SliderMinValue);
            def.SetProperty(LogicOptionWidgetProps.SLIDER_MAX_VALUE, meta.SliderMaxValue);
            def.SetProperty(LogicOptionWidgetProps.SLIDER_WHOLE_NUMBERS, meta.SliderWholeNumber);
        }
    }
    // #endregion

    private var res(get, never):ResourceManager;
    inline function get_res():ResourceManager return main.ResourceManager;
    private var main:MainManager;
}
