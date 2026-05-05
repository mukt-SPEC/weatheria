import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:weatheria/core/utils/platform_helpers.dart';

void main() {
  group('LayoutBreakpoint', () {
    test('compact for widths below 600', () {
      expect(LayoutBreakpoint.fromWidth(320), LayoutBreakpoint.compact);
      expect(LayoutBreakpoint.fromWidth(375), LayoutBreakpoint.compact);
      expect(LayoutBreakpoint.fromWidth(414), LayoutBreakpoint.compact);
      expect(LayoutBreakpoint.fromWidth(599), LayoutBreakpoint.compact);
    });

    test('medium for widths 600–839', () {
      expect(LayoutBreakpoint.fromWidth(600), LayoutBreakpoint.medium);
      expect(LayoutBreakpoint.fromWidth(700), LayoutBreakpoint.medium);
      expect(LayoutBreakpoint.fromWidth(839), LayoutBreakpoint.medium);
    });

    test('expanded for widths 840 and above', () {
      expect(LayoutBreakpoint.fromWidth(840), LayoutBreakpoint.expanded);
      expect(LayoutBreakpoint.fromWidth(1024), LayoutBreakpoint.expanded);
      expect(LayoutBreakpoint.fromWidth(1440), LayoutBreakpoint.expanded);
      expect(LayoutBreakpoint.fromWidth(1920), LayoutBreakpoint.expanded);
    });
  });

  group('metricsColumnCount', () {
    test('returns 2 for compact', () {
      expect(metricsColumnCount(LayoutBreakpoint.compact), 2);
    });

    test('returns 3 for medium', () {
      expect(metricsColumnCount(LayoutBreakpoint.medium), 3);
    });

    test('returns 4 for expanded', () {
      expect(metricsColumnCount(LayoutBreakpoint.expanded), 4);
    });
  });

  group('Adaptive layout widget tests', () {
    // Verifies that LayoutBuilder-based content adapts to different widths.
    // This tests the breakpoint logic used by the weather screen.

    Widget buildTestWidget(double width) {
      return MaterialApp(
        home: SizedBox(
          width: width,
          height: 800,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final breakpoint =
                  LayoutBreakpoint.fromWidth(constraints.maxWidth);
              return Center(
                child: Text(
                  breakpoint.name,
                  key: const Key('breakpoint_label'),
                ),
              );
            },
          ),
        ),
      );
    }

    testWidgets('compact layout at phone width', (tester) async {
      // Simulate a 360px phone screen
      tester.view.physicalSize = const Size(360, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(buildTestWidget(360));
      final finder = find.byKey(const Key('breakpoint_label'));
      expect(finder, findsOneWidget);
      expect((tester.widget<Text>(finder)).data, 'compact');
    });

    testWidgets('medium layout at tablet width', (tester) async {
      tester.view.physicalSize = const Size(700, 1000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(buildTestWidget(700));
      final finder = find.byKey(const Key('breakpoint_label'));
      expect(finder, findsOneWidget);
      expect((tester.widget<Text>(finder)).data, 'medium');
    });

    testWidgets('expanded layout at desktop width', (tester) async {
      tester.view.physicalSize = const Size(1200, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(buildTestWidget(1200));
      final finder = find.byKey(const Key('breakpoint_label'));
      expect(finder, findsOneWidget);
      expect((tester.widget<Text>(finder)).data, 'expanded');
    });
  });
}
