package mvz2.ui.arcade;

// PORT-NOTE: C# 的 IndexArcadePage 位于 Assets/Scripts/View/Arcade/IndexArcadePage.cs，
// namespace 为 MVZ2.Arcade，按 PORTING.md 其正体位于 mvz2.arcade.IndexArcadePage。
// 已存在的 mvz2.arcade.ArcadeController 以 mvz2.ui.arcade.IndexArcadePage 引用它，
// 这里提供别名模块以同时满足两种引用路径（含其内嵌枚举 ButtonType）。
typedef IndexArcadePage = mvz2.arcade.IndexArcadePage;
typedef ButtonType = mvz2.arcade.IndexArcadePage.ButtonType;
