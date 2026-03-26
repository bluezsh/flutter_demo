import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_demo/core/utils/toast_util.dart';
import 'package:flutter_demo/main.dart';

void main() {
  group('ToastUtil', () {
    tearDown(() {
      // 确保每个测试后清理 Toast
      ToastUtil.hide();
    });

    testWidgets('show - 显示纯文本Toast', (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      ToastUtil.show('这是一条消息');
      await tester.pump();

      expect(find.text('这是一条消息'), findsOneWidget);

      await tester.pumpAndSettle(const Duration(seconds: 3));
    });

    testWidgets('show with custom duration - 自定义持续时间', (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      ToastUtil.show(
        '短时间消息',
        duration: const Duration(milliseconds: 500),
      );
      await tester.pump();

      expect(find.text('短时间消息'), findsOneWidget);

      // 等待超过duration时间
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pump();

      expect(find.text('短时间消息'), findsNothing);
    });

    testWidgets('showCustom - 显示自定义Widget Toast', (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      const testKey = Key('custom-toast-widget');

      ToastUtil.showCustom(
        child: Container(
          key: testKey,
          child: const Text('自定义Widget'),
        ),
        duration: const Duration(seconds: 2),
      );
      await tester.pump();

      expect(find.byKey(testKey), findsOneWidget);
      expect(find.text('自定义Widget'), findsOneWidget);

      await tester.pumpAndSettle(const Duration(seconds: 3));
    });

    testWidgets('hide - 手动隐藏Toast', (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      ToastUtil.show('应该被隐藏的消息');
      await tester.pump();

      expect(find.text('应该被隐藏的消息'), findsOneWidget);

      ToastUtil.hide();
      await tester.pump();

      expect(find.text('应该被隐藏的消息'), findsNothing);
    });

    testWidgets('多次调用show - 新Toast替换旧Toast', (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      ToastUtil.show('第一条消息');
      await tester.pump();
      expect(find.text('第一条消息'), findsOneWidget);

      ToastUtil.show('第二条消息');
      await tester.pump();
      expect(find.text('第一条消息'), findsNothing);
      expect(find.text('第二条消息'), findsOneWidget);

      await tester.pumpAndSettle(const Duration(seconds: 3));
    });

    testWidgets('showCustom position: top - Toast显示在顶部', (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      ToastUtil.showCustom(
        child: const Text('顶部消息'),
        position: ToastPosition.top,
      );
      await tester.pump();

      expect(find.text('顶部消息'), findsOneWidget);

      final positionedWidget = tester.widget<Positioned>(
        find.ancestor(
          of: find.text('顶部消息'),
          matching: find.byType(Positioned),
        ),
      );
      expect(positionedWidget.top, isNotNull);
      expect(positionedWidget.bottom, isNull);

      await tester.pumpAndSettle(const Duration(seconds: 3));
    });

    testWidgets('showCustom position: center - Toast显示在居中', (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      ToastUtil.showCustom(
        child: const Text('居中消息'),
        position: ToastPosition.center,
      );
      await tester.pump();

      expect(find.text('居中消息'), findsOneWidget);

      expect(
        find.ancestor(
          of: find.text('居中消息'),
          matching: find.byType(Center),
        ),
        findsOneWidget,
      );

      await tester.pumpAndSettle(const Duration(seconds: 3));
    });

    testWidgets('showCustom position: bottom - Toast显示在底部', (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      ToastUtil.showCustom(
        child: const Text('底部消息'),
        position: ToastPosition.bottom,
      );
      await tester.pump();

      expect(find.text('底部消息'), findsOneWidget);

      final positionedWidget = tester.widget<Positioned>(
        find.ancestor(
          of: find.text('底部消息'),
          matching: find.byType(Positioned),
        ),
      );
      expect(positionedWidget.bottom, isNotNull);
      expect(positionedWidget.top, isNull);

      await tester.pumpAndSettle(const Duration(seconds: 3));
    });

    testWidgets('showCustom dismissOnTap: false - 点击不关闭', (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      ToastUtil.showCustom(
        child: const Text('不可点击关闭'),
        dismissOnTap: false,
      );
      await tester.pump();

      expect(find.text('不可点击关闭'), findsOneWidget);

      await tester.tap(find.text('不可点击关闭'));
      await tester.pump();

      expect(find.text('不可点击关闭'), findsOneWidget);
    });

    testWidgets('showCustom dismissOnTap: true - 点击关闭', (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      ToastUtil.showCustom(
        child: const Text('可点击关闭'),
        dismissOnTap: true,
      );
      await tester.pump();

      expect(find.text('可点击关闭'), findsOneWidget);

      await tester.tap(find.text('可点击关闭'));
      await tester.pump();

      expect(find.text('可点击关闭'), findsNothing);
    });

    testWidgets('showCustom duration: null - Toast不自动消失', (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      ToastUtil.showCustom(
        child: const Text('持久Toast'),
        duration: null,
      );
      await tester.pump();

      expect(find.text('持久Toast'), findsOneWidget);

      await tester.pump(const Duration(seconds: 3));

      expect(find.text('持久Toast'), findsOneWidget);
    });

    testWidgets('纯文本Toast样式验证', (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      ToastUtil.show('样式测试');
      await tester.pump();

      final container = tester.widget<Container>(
        find.ancestor(
          of: find.text('样式测试'),
          matching: find.byType(Container),
        ),
      );

      final decoration = container.decoration as BoxDecoration;
      expect(decoration.color, Colors.black.withValues(alpha: 0.6));
      expect(decoration.borderRadius, BorderRadius.circular(8));

      await tester.pumpAndSettle(const Duration(seconds: 3));
    });
  });
}
