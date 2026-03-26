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
  - **注意**: 底部导航栏的菜单主页面（Tab 页）统一**不使用**跳转动画，直接使用 `builder` 接入。

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
  - **接口日志收口**: **禁止**在业务页面或 Cubit/Bloc 中手动打印接口请求和响应日志。
  - **统一处理**: 所有接口请求日志已由 `ApiService` 内部通过 `LogUtil.logApi` 统一处理，确保原子化输出（请求路径、方法、参数、响应、耗时）。
  - **LogFormat.json**: 接口响应默认采用 JSON 美化输出。
  - **使用示例**:
    ```dart
    // 普通文本日志
    LogUtil.log('这是一条普通文本日志');

    // JSON 对象日志
    LogUtil.log(
      {'id': 100, 'name': '测试对象', 'active': true, 'tags': ['flutter', 'demo']},
      format: LogFormat.json,
    );

    // 格式化 JSON 字符串
    LogUtil.log('{"code": 200, "data": {"list": [1, 2, 3]}}', format: LogFormat.json);
    ```

- **网络服务 (ApiService)**:
  - 统一使用全局实例 `apiService` ([api_service.dart](file:///Users/chen/Project/Codes/flutter_demo/lib/core/services/api_service.dart))。
  - **方法调用**: `request` 方法始终返回 `ApiResponse<T>` 对象，**禁止**在业务层编写 `try-catch` 处理网络异常。
  - **结果处理**: 通过 `response.isSuccess` 判断请求状态，`response.data` 获取数据，`response.message` 获取错误信息。
  - **HttpMethod**: 显式指定 `get`, `post`, `put`, `delete` 等。
  - **使用示例**:
    ```dart
    // GET 请求示例
    final response = await apiService.request('https://httpstat.us/200');
    if (response.isSuccess) {
      // 处理成功逻辑
    } else {
      // 处理失败逻辑 (错误码: response.code, 错误信息: response.message)
    }

    // POST 请求示例
    await apiService.request(
      '/api/v1/user',
      method: HttpMethod.post,
      params: {'name': 'Trae', 'age': 1},
    );
    ```

## 5. 编码原则

- **DRY (Don't Repeat Yourself)**:
  - 跨项目的纯 UI 逻辑 -> `lib/core/`。
  - 本项目的业务公共逻辑 -> `lib/shared/`。
  - 模块内私有逻辑 -> 页面或组件文件夹内部。
- **Lint 遵循**: 严格遵守 `flutter_lints` 规则。
- **注释**: 为复杂的逻辑或公共组件编写清晰的 DartDoc 注释。
- **响应式布局**: 使用 `Flexible`, `Expanded` 或 `MediaQuery` 确保应用在不同屏幕尺寸下表现良好。

## 6. 自定义组件使用指南

### CustomAlert 组件

`CustomAlert` 是项目中的自定义弹窗组件，提供统一的弹窗和底部弹窗样式。

#### 功能特性
- **背景模糊**: 支持背景模糊效果
- **高度控制**: 支持固定高度和自适应高度
- **动画效果**: 平滑的弹出动画
- **回调通知**: 支持关闭时的回调
- **全局上下文**: 使用 `navigatorKey` 获取全局上下文

#### 使用方法

**1. 自定义对话框 (showCustomDialog)**
```dart
CustomAlert.showCustomDialog(
  child: Container(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('标题'),
        Text('内容'),
      ],
    ),
  ),
  blurAmount: 5.0,
  onDismissed: () {
    debugPrint('对话框已关闭');
  },
);
```

**2. 自定义底部弹窗 (showCustomBottom)**

*自适应高度模式*:
```dart
CustomAlert.showCustomBottom(
  child: Container(
    child: Column(
      children: [
        Text('标题'),
        Text('内容'),
      ],
    ),
  ),
);
```

*固定高度模式*:
```dart
CustomAlert.showCustomBottom(
  child: Container(
    child: ListView.builder(
      itemCount: 50,
      itemBuilder: (context, index) => ListTile(
        title: Text('项目 $index'),
      ),
    ),
  ),
  fixedHeight: 400,
  blurAmount: 5.0,
  onDismissed: () {
    debugPrint('BottomSheet 已关闭');
  },
);
```

#### 参数说明

**showCustomDialog 参数**:
- `child`: 必需，弹窗显示的 Widget 内容
- `horizontalMargin`: 可选，水平边距，默认 20.0
- `barrierDismissible`: 可选，点击外部是否关闭，默认 true
- `barrierColor`: 可选，遮罩颜色，默认黑色带 0.6 透明度
- `blurAmount`: 可选，背景模糊度，默认 0.0
- `onDismissed`: 可选，关闭时的回调函数

**showCustomBottom 参数**:
- `child`: 必需，BottomSheet 显示的 Widget 内容
- `barrierDismissible`: 可选，点击外部是否关闭，默认 true
- `barrierColor`: 可选，遮罩颜色，默认黑色带 0.6 透明度
- `blurAmount`: 可选，背景模糊度，默认 0.0
- `onDismissed`: 可选，关闭时的回调函数
- `fixedHeight`: 可选，固定高度，如果未指定则完全自适应高度

#### 最佳实践
- **内容高度**: 根据内容复杂度选择固定高度或自适应高度
- **模糊效果**: 适度的模糊效果可以提升用户体验，但不要过度使用
- **回调通知**: 使用回调来处理弹窗关闭后的逻辑
- **性能优化**: 大量内容时使用 `ListView.builder` 避免性能问题

## 7. 新增功能工作流 (Workflow)

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
