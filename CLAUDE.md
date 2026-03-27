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
│   │   ├── api_service/          # 底层网络服务（禁止直接使用）
│   │   │   └── api_service.dart  # Dio封装
│   │   ├── api_client/           # 业务API客户端（使用此）
│   │   │   └── api_client.dart   # Token管理、缓存、请求封装
│   │   ├── secure_storage_service/ # 安全存储
│   │   │   └── secure_storage_service.dart # Token存储
│   │   └── storage_service/      # 本地存储
│   │       └── storage_service.dart # 普通数据、缓存
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
| 网络请求 | dio | ^5.9.2 |
| 证书固定 | dio_http2_adapter + crypto | ^2.7.0 + ^3.0.7 |
| 安全存储 | flutter_secure_storage | ^10.0.0 |
| 本地存储 | shared_preferences | ^2.5.5 |

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

## 本地存储

### Token 安全存储

使用 `SecureStorageService` 存储 Token（Keychain/Keystore）：

```dart
// 保存 Token
await secureStorageService.setAccessToken('xxx');
await secureStorageService.setRefreshToken('xxx');

// 获取 Token
final token = await secureStorageService.getAccessToken();
final refresh = await secureStorageService.getRefreshToken();

// 删除 Token
await secureStorageService.deleteToken(TokenType.accessToken);
await secureStorageService.clearAll();  // 清除所有
```

### 普通数据存储

使用 `StorageService` 存储普通数据（SharedPreferences）：

```dart
// String
storageService.setString(StorageKey.apiCache, 'data');
storageService.getString(StorageKey.apiCache);

// Bool
storageService.setBool(StorageKey.apiCache, true);
storageService.getBool(StorageKey.apiCache);

// 通用操作
storageService.containsKey(StorageKey.apiCache);
storageService.remove(StorageKey.apiCache);
storageService.clear();
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

### ⚠️ 重要说明

- **禁止直接使用 `ApiService`** - 这是底层网络服务封装
- **业务请求统一使用 `ApiClient`** - 提供 Token 管理、自动刷新、接口缓存等功能

### ApiClient 使用

```dart
// GET 请求
final response = await apiClient.request('/api/user/info');

// GET 请求（带参数）
await apiClient.request('/api/user/list', params: {'page': 1, 'size': 20});

// POST 请求
await apiClient.request(
  '/api/user/login',
  method: HttpMethod.post,
  data: {'username': 'xxx', 'password': 'xxx'},
);

// PUT 请求
await apiClient.request(
  '/api/user/profile',
  method: HttpMethod.put,
  data: {'name': '张三'},
);

// DELETE 请求
await apiClient.request('/api/user/123', method: HttpMethod.delete);

// GET 请求（使用缓存）
await apiClient.request(
  '/api/config',
  useCache: true,
  cacheMinutes: 10,
);
```

### Token 管理

`ApiClient` 自动处理 Token：

- 请求时自动携带 `Authorization: Bearer {token}` 头
- 401 响应自动刷新 Token 并重试请求
- 刷新失败自动清除 Token

```dart
// 配置刷新Token接口路径
apiClient.refreshTokenPath = '/auth/refresh';

// 登出（清除Token和缓存）
await apiClient.logout();
```

### 接口缓存

仅对 GET 请求有效：

```dart
// 使用缓存（默认5分钟）
await apiClient.request('/api/config', useCache: true);

// 自定义缓存时长
await apiClient.request('/api/config', useCache: true, cacheMinutes: 10);

// 清除所有缓存
await apiClient.clearCache();
```

### 响应处理

```dart
final response = await apiClient.request('/api/user/info');

if (response.isSuccess) {
  final data = response.data;
} else {
  final code = response.code;
  final message = response.message;
}
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

### 测试规范

1. **测试代码在测试通过后删除**
   - 测试仅用于验证功能正确性
   - 通过后删除测试文件，不保留在代码库中
   - 保留 `test/widget_test.dart` 作为示例

2. **添加测试文件**
   - 测试文件与源文件保持相同的目录结构
   - 测试文件命名：`{filename}_test.dart`

### 运行测试

```bash
# 运行所有测试
flutter test

# 运行特定测试
flutter test test/core/utils/toast_util_test.dart
```

## 代码风格

- 遵循官方 Flutter Lint 规则
- 使用单引号字符串
- 工具类使用私有构造函数实现单例模式
- 组件优先使用 `const` 构造函数

## 依赖管理

### ⚠️ 第三方库版本要求

**添加或更新第三方库时，必须使用最新稳定版本。**

#### 操作流程

1. **添加新依赖时**：
   ```bash
   # 搜索包并查看最新版本
   flutter pub add package_name
   # 或手动指定版本前（先确认 pub.dev 上的最新版本）
   ```

2. **定期更新依赖**：
   ```bash
   # 检查过时的包
   flutter pub outdated

   # 更新依赖（会更新到兼容约束内的最新版本）
   flutter pub upgrade

   # 升级特定包到最新版本（放宽版本约束）
   flutter pub upgrade --major-versions package_name
   ```

3. **添加前检查**：
   - 访问 [pub.dev](https://pub.dev) 确认该包的最新稳定版本
   - 查看该包的 **Last published** 时间，避免使用长期未维护的包
   - 查看平台的兼容性（Android/iOS/Web/Desktop）
   - 查看 Likes 和 Popularity 评分

4. **添加后验证**：
   ```bash
   # 确保所有依赖都是最新的
   flutter pub outdated
   ```
   - **直接依赖** 必须显示 `all up-to-date`
   - **传递依赖** 的旧版本若受 Flutter SDK 约束限制可忽略

#### 当前依赖版本

| 包 | 版本 | 用途 |
|---|---|---|
| go_router | ^17.1.0 | 路由管理 |
| flutter_bloc | ^9.1.1 | 状态管理 |
| dio | ^5.9.2 | 网络请求 |
| dio_http2_adapter | ^2.7.0 | HTTP/2 适配器（证书固定） |
| crypto | ^3.0.7 | 加密哈希（证书固定） |
| flutter_secure_storage | ^10.0.0 | 安全存储 |
| shared_preferences | ^2.5.5 | 本地存储 |

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
