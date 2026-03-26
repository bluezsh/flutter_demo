# Flutter Demo - AI Coding 指南

## 项目概述

这是一个采用现代化最佳实践的 Flutter 项目，使用 `go_router` 进行路由管理，`flutter_bloc` 进行状态管理，`dio` 进行网络请求。

## 目录结构

```
lib/
├── app/                          # 应用层
│   ├── app.dart                  # 应用主页面
│   └── router/                   # 路由相关
│       ├── app_routes.dart       # 路由定义（枚举）
│       ├── app_router.dart       # 路由配置（GoRouter配置）
│       └── cubit/router_cubit.dart # 路由状态管理
├── core/                         # 核心功能
│   ├── services/                 # 服务层
│   │   └── api_service/          # API服务封装
│   │       └── api_service.dart  # 统一网络请求
│   ├── utils/                    # 工具类
│   │   ├── loading_util.dart     # Loading遮罩
│   │   ├── log_util.dart         # 日志工具
│   │   ├── status_bar_util.dart  # 状态栏工具
│   │   └── toast_util.dart       # Toast提示
│   └── widgets/                  # 基础组件
│       ├── base_page.dart        # 基础页面封装
│       ├── custom_app_bar.dart   # 自定义导航栏
│       └── custom_alert.dart     # 自定义弹窗容器
├── pages/                        # 页面层
│   ├── details/                  # 详情页
│   ├── main_tabs/                # 主标签页
│   └── settings/                 # 设置页
└── shared/                       # 共享资源
    └── app_text_style.dart       # 全局文本样式
```

## 技术栈

| 用途 | 技术 | 版本 |
|------|------|------|
| 路由管理 | go_router | ^17.1.0 |
| 状态管理 | flutter_bloc | ^9.1.1 |
| 网络请求 | dio | ^5.7.0 |

## 命名规范

- **文件/目录**: `snake_case` (例: `loading_util.dart`)
- **类名**: `PascalCase` (例: `LoadingUtil`)
- **方法/变量**: `snake_case` (例: `showToast()`)
- **常量**: `UPPER_SNAKE_CASE` (例: `MAX_COUNT`)
- **私有类**: 前缀下划线 (例: `_LoadingWidget`)

## 路由系统

### 添加新路由

1. 在 `lib/app/router/app_routes.dart` 枚举中添加路径
2. 在 `lib/app/router/app_router.dart` 配置路由

```dart
// app_routes.dart
enum AppRoute {
  newPage('/new-page'),
  // ...
}
```

### 页面跳转

```dart
// 使用 GoRouter
context.go(AppRoute.details.path);

// 带参数跳转
context.go('${AppRoute.details.path}?id=123');
```

## 工具类使用

### Toast 提示

```dart
// 纯文本 Toast（居中，黑色半透明背景，默认2秒）
ToastUtil.show('这是一条消息');

// 自定义持续时间
ToastUtil.show('消息', duration: Duration(seconds: 3));
```

### 自定义 Widget Toast

```dart
ToastUtil.showCustom(
  child: YourCustomWidget(),
  position: ToastPosition.center, // top/center/bottom
  duration: Duration(seconds: 2),
  dismissOnTap: true,
);
```

### Loading 遮罩

```dart
// 显示
LoadingUtil.show();

// 隐藏
LoadingUtil.hide();
```

### 自定义弹窗

```dart
// Dialog 形式
CustomAlert.showCustomDialog(
  blurAmount: 5,
  child: Builder(
    builder: (context) => YourContent(),
  ),
);

// BottomSheet 形式
CustomAlert.showCustomBottom(
  fixedHeight: 300,  // 可选：固定高度
  child: Builder(
    builder: (context) => YourContent(),
  ),
);
```

### 日志输出

```dart
// 普通日志
LogUtil.d('调试信息');
LogUtil.e('错误信息');

// API 请求日志（ApiService 内部自动调用）
LogUtil.apiRequest(url: '/api/test', method: 'GET', data: {});
LogUtil.apiResponse(url: '/api/test', response: data, duration: Duration(milliseconds: 500));
```

### 状态栏设置

```dart
// 设置为浅色内容（深色背景）
StatusBarUtil.setDarkStyle();

// 设置为深色内容（浅色背景）
StatusBarUtil.setLightStyle();
```

## 组件使用

### BasePage

所有页面应使用 `BasePage` 包装，保证统一风格：

```dart
class MyPage extends StatelessWidget {
  const MyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BasePage(
      appBar: const CustomAppBar(
        title: '页面标题',
        showBackButton: true,
      ),
      body: YourContent(),
    );
  }
}
```

### CustomAppBar

```dart
CustomAppBar(
  title: '标题',
  showBackButton: true,  // 自动判断是否可返回
  actions: [
    IconButton(onPressed: () {}, icon: Icon(Icons.more_vert)),
  ],
)
```

### AppTextStyle

```dart
Text(
  '文本',
  style: AppTextStyle.getStyle(
    fontFamily: 'Roboto',
    fontSize: 16,
    color: Colors.black,
    fontWeight: FontWeight.w500,  // 可选
  ),
)
```

## 网络请求

使用 `ApiService` 进行统一的网络请求：

```dart
final response = await ApiService.get('/api/endpoint');
final response = await ApiService.post('/api/endpoint', data: {...});
```

## 状态管理

### 创建新 Cubit

```dart
class MyCubit extends Cubit<MyState> {
  MyCubit() : super(InitialState());

  void doSomething() {
    emit(LoadingState());
    // ...
    emit(SuccessState());
  }
}
```

### 在页面中使用

```dart
// 在 build 方法中
final myCubit = context.watch<MyCubit>();
final state = myCubit.state;

// 调用方法
context.read<MyCubit>().doSomething();
```

## 测试

### 运行所有测试

```bash
flutter test
```

### 运行特定测试

```bash
flutter test test/core/utils/toast_util_test.dart
```

## 代码风格

- 遵循官方 Flutter Lint 规则
- 使用单引号字符串
- 工具类使用私有构造函数实现单例模式
- 组件优先使用 `const` 构造函数

## 常见任务

### 添加新页面

1. 在 `lib/pages/` 下创建页面文件
2. 在 `app_routes.dart` 添加路由枚举
3. 在 `app_router.dart` 配置路由
4. 如需在底部标签显示，在 `StatefulShellRoute.indexedStack` 添加 `StatefulShellBranch`

### 添加新工具类

1. 在 `lib/core/utils/` 创建文件
2. 使用私有构造函数实现单例
3. 添加对应的测试文件在 `test/core/utils/`

### 添加新组件

1. 在 `lib/core/widgets/` 创建文件
2. 继承 `StatelessWidget` 或 `StatefulWidget`
3. 添加文档注释说明用途
