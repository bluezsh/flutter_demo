import 'package:flutter_bloc/flutter_bloc.dart';

/// 路由状态类
class RouterState {
  final String currentPath;

  const RouterState({
    required this.currentPath,
  });

  RouterState copyWith({
    String? currentPath,
  }) {
    return RouterState(
      currentPath: currentPath ?? this.currentPath,
    );
  }
}

/// 路由监听 Cubit
class RouterCubit extends Cubit<RouterState> {
  RouterCubit() : super(const RouterState(currentPath: ''));

  /// 更新当前路径
  void updatePath(String path) {
    if (state.currentPath == path) return;

    emit(state.copyWith(
      currentPath: path,
    ));
  }
}
