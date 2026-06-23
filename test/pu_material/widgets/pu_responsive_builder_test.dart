import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pu_material/pu_material.dart';

Widget buildTestWidget(double width, void Function(String?) onResult) {
  return MaterialApp(
    home: Scaffold(
      body: Align(
        alignment: Alignment.topLeft,
        child: SizedBox(
          width: width,
          height: 600,
          child: PuResponsiveBuilder(
            builder: (context, info) {
              onResult(info.isMobile ? 'mobile' : info.isDesktop ? 'desktop' : 'tablet');
              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    ),
  );
}

void main() {
  group('PuResponsiveBuilder', () {
    testWidgets('isMobile when width below breakpoint', (WidgetTester tester) async {
      String? capturedMode;

      await tester.pumpWidget(buildTestWidget(400, (m) => capturedMode = m));
      await tester.pump();

      expect(capturedMode, 'mobile');
    });

    testWidgets('isDesktop when width above tablet breakpoint', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1400, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.physicalSize = const Size(800, 600);
        tester.view.devicePixelRatio = 1.0;
      });

      String? capturedMode;

      await tester.pumpWidget(buildTestWidget(1200, (m) => capturedMode = m));
      await tester.pump();

      expect(capturedMode, 'desktop');
    });

    testWidgets('isTablet between breakpoints', (WidgetTester tester) async {
      String? capturedMode;

      await tester.pumpWidget(buildTestWidget(800, (m) => capturedMode = m));
      await tester.pump();

      expect(capturedMode, 'tablet');
    });

    testWidgets('provides correct width value', (WidgetTester tester) async {
      double? capturedWidth;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Align(
              alignment: Alignment.topLeft,
              child: SizedBox(
                width: 800,
                height: 600,
                child: PuResponsiveBuilder(
                  builder: (context, info) {
                    capturedWidth = info.width;
                    return const SizedBox.shrink();
                  },
                ),
              ),
            ),
          ),
        ),
      );

      await tester.pump();
      expect(capturedWidth, 800.0);
    });
  });

  group('ResponsiveInfo data class', () {
    test('mobile flags', () {
      const info = ResponsiveInfo(width: 500, isMobile: true, isTablet: false, isDesktop: false);
      expect(info.isMobile, isTrue);
      expect(info.isTablet, isFalse);
      expect(info.isDesktop, isFalse);
    });

    test('tablet flags', () {
      const info = ResponsiveInfo(width: 800, isMobile: false, isTablet: true, isDesktop: false);
      expect(info.isMobile, isFalse);
      expect(info.isTablet, isTrue);
      expect(info.isDesktop, isFalse);
    });

    test('desktop flags', () {
      const info = ResponsiveInfo(width: 1200, isMobile: false, isTablet: false, isDesktop: true);
      expect(info.isMobile, isFalse);
      expect(info.isTablet, isFalse);
      expect(info.isDesktop, isTrue);
    });
  });
}
