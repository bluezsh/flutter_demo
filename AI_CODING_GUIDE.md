# AI Coding Guide - flutter_demo

本文档旨在指导 AI（及开发者）在本项目中进行高效、规范的编码工作。请在生成代码、重构或新增功能时遵循以下准则。

## 1. 项目架构与目录规范

项目遵循模块化和分层设计的原则，代码组织如下：

- **`lib/app/`**: 应用全局配置。
  - `router/`: 路由定义 (`AppRoute` 枚举) 与 `go_router` 配置。
  - `app.dart`: 应用启动后的首个承载页面。
- **`lib/core/`**: 核心通用层。包含与业务无关、可复用于任何项目的通用工具和组件。
  - `utils/`: 纯函数/工具类 (如日期格式化、网络状态监测等，不依赖本项目业务模型)。
  - `widgets/`: 纯 UI 组件 (如自定义按钮、输入框模板、加载指示器等，不包含本项目业务逻辑)。
- **`lib/shared/`**: 项目公共层。包含本项目内跨模块复用的业务组件和逻辑。
  - `widgets/`: 本项目通用的业务组件 (如 `BasePage`, 项目特有的商品卡片等)。
  - `models/`: 跨模块使用的业务数据模型。
  - `utils/`: 依赖本项目业务逻辑的工具方法。
- **`lib/pages/`**: 业务功能页面。
  - 按照功能模块分组 (如 `main_tabs/`)。
  - 每个页面应为一个独立的 Dart 文件。
- **`lib/main.dart`**: 应用入口，负责初始化基础服务和启动 `MaterialApp`。

## 2. 路由管理 (go_router)

项目使用 `go_router` 进行声明式路由管理。

- **定义路由**: 在 [app_routes.dart](file:///Users/chen/Project/Codes/flutter_demo/lib/app/router/app_routes.dart) 的 `AppRoute` 枚举中添加新路由及其路径。
- **配置路由**: 在 [app_router.dart](file:///Users/chen/Project/Codes/flutter_demo/lib/app/router/app_router.dart) 的 `AppRouter.router` 中注册对应的 `GoRoute` 或 `StatefulShellBranch`。
- **跳转方式**:
  - **一级页面/状态切换**: 使用 `context.go(AppRoute.xxx.path)`。
  - **二级/详情页面**: 使用 `context.push(AppRoute.xxx.path)`，以保留返回栈。
- **页面跳转动画**:
  - 动画枚举 `_PageTransitionType` 和构建方法 `_buildPage` 私有实现在 [app_router.dart](file:///Users/chen/Project/Codes/flutter_demo/lib/app/router/app_router.dart) 中。
  - **右侧滑入 (slideRight)**: 模仿 iOS 原生效果，为项目**默认动画**，时长 350ms。
  - **其他滑入 (slideLeft, slideTop, slideBottom)**: 可选的侧滑/上下滑入动画，时长 350ms。
  - **渐隐动画 (fadeIn)**: 时长 200ms。
  - 在 `GoRoute` 中使用 `pageBuilder: (context, state) => _buildPage(...)` 接入，默认 `type` 为 `slideRight`。

## 3. UI 编码规范

- **组件化**: 复杂的 UI 应拆分为更小的组件，按复用范围存放：
  - **私有组件**: 仅在当前文件或模块内部使用，存放在页面文件底部。
  - **业务组件 (本项目复用)**: 跨页面但带业务逻辑的组件，存放在 `lib/shared/widgets/`。
  - **通用组件 (跨项目复用)**: 纯 UI 组件，存放在 `lib/core/widgets/`。
- **Stateless 优先**: 除非需要管理生命周期或内部状态，否则优先使用 `StatelessWidget`。
- **BasePage**: 所有页面应基于 [BasePage](file:///Users/chen/Project/Codes/flutter_demo/lib/core/widgets/base_page.dart)。
  - `BasePage` 不再直接接收导航栏配置（如 title, actions 等）。
  - 必须通过 `appBar` 参数显式传递 [CustomAppBar](file:///Users/chen/Project/Codes/flutter_demo/lib/core/widgets/custom_app_bar.dart) 或其他 `PreferredSizeWidget`。
  - 这种设计实现了页面框架与导航栏配置的解耦。
- **命名规范**:
  - 类名: `UpperCamelCase` (例如: `HomePage`, `MainTabPage`)。
  - 方法/变量: `lowerCamelCase` (例如: `buildHeader`, `isLoaded`)。
  - 文件名: `snake_case` (例如: `home_page.dart`)。

- **状态管理 (flutter_bloc)**:
  - 统一使用 `flutter_bloc` 进行状态管理。
  - **简单状态**: 优先使用 `Cubit`。
  - **复杂异步/多事件状态**: 使用 `Bloc`。
  - **Provider 注入**: 在 `main.dart` 或页面入口处使用 `BlocProvider` 或 `MultiBlocProvider`。
  - **全局 Cubit**: 对于需要跨模块共享的状态（如 `RouterCubit`），应在 `main.dart` 顶层注入。
  - **UI 消费**: 使用 `BlocBuilder`, `BlocListener` 或 `BlocConsumer` 进行响应式更新。
  - **逻辑分离**: 业务逻辑必须封装在 Cubit/Bloc 中，Widget 仅负责 UI 展示。
- **日志打印 (LogUtil)**:
  - 统一使用 [LogUtil](file:///Users/chen/Project/Codes/flutter_demo/lib/core/utils/log_util.dart) 进行日志打印。
  - **dart:developer.log**: 使用 `dart:developer` 的 `log` 函数，确保在调试控制台（如 DevTools）中有更好的集成效果，并自动处理长文本输出。
  - **LogFormat.text**: 默认文本输出格式。
  - **LogFormat.json**: 结构化 JSON 输出格式，适用于复杂对象和 API 数据。
  - 仅在 `kDebugMode` 下输出日志。

## 5. 编码原则

- **DRY (Don't Repeat Yourself)**:
  - 跨项目的纯 UI 逻辑 -> `lib/core/`。
  - 本项目的业务公共逻辑 -> `lib/shared/`。
  - 模块内私有逻辑 -> 页面或组件文件夹内部。
- **Lint 遵循**: 严格遵守 `flutter_lints` 规则。
- **注释**: 为复杂的逻辑或公共组件编写清晰的 DartDoc 注释。
- **响应式布局**: 使用 `Flexible`, `Expanded` 或 `MediaQuery` 确保应用在不同屏幕尺寸下表现良好。

## 6. 新增功能工作流 (Workflow)

当 AI 接收到新增功能请求时，请按以下步骤操作：
1. **分析需求**: 确定所属模块及是否需要新路由。
2. **定义路由**: 在 `AppRoute` 中新增枚举值。
3. **创建页面**: 在 `lib/pages/` 下创建对应目录和文件。
4. **注册路由**: 在 `AppRouter` 中配置新页面的 Builder。
5. **实现 UI**:
    - 通用 UI -> `lib/core/widgets/`。
    - 项目业务公共逻辑/组件 -> `lib/shared/`。
    - 页面私有逻辑 -> 页面内部。
6. **验证**: 运行 `flutter analyze` 确保无 Lint 错误。
