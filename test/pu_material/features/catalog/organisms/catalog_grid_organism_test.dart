import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:pu_material/pu_material.dart';

class TestItem {
  final String name;
  const TestItem(this.name);
}

Widget buildTestApp({required List<TestItem> items, VoidCallback? onCreate}) {
  return MaterialApp(
    home: Scaffold(
      body: CatalogGridOrganism<TestItem>(
        items: items,
        constraints: const BoxConstraints(maxWidth: 800),
        emptyIcon: FluentIcons.folder_24_regular,
        emptyMessage: 'No items found',
        itemBuilder: (context, item, index) => ListTile(
          key: Key('item_$index'),
          title: Text(item.name),
        ),
        createButtonLabel: 'Add first item',
        onCreateItem: onCreate ?? () {},
      ),
    ),
  );
}

void main() {
  group('CatalogGridOrganism', () {
    testWidgets('shows empty state when items is empty', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestApp(items: []));
      await tester.pumpAndSettle();

      expect(find.text('No items found'), findsOneWidget);
      expect(find.text('Add first item'), findsOneWidget);
    });

    testWidgets('calls onCreateItem when button is pressed on empty state', (WidgetTester tester) async {
      bool wasCalled = false;
      await tester.pumpWidget(buildTestApp(
        items: [],
        onCreate: () => wasCalled = true,
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Add first item'));
      expect(wasCalled, isTrue);
    });

    testWidgets('shows items in grid when items is not empty', (WidgetTester tester) async {
      final items = [
        const TestItem('Item 1'),
        const TestItem('Item 2'),
        const TestItem('Item 3'),
      ];

      await tester.pumpWidget(buildTestApp(items: items));
      await tester.pumpAndSettle();

      expect(find.text('Item 1'), findsOneWidget);
      expect(find.text('Item 2'), findsOneWidget);
      expect(find.text('Item 3'), findsOneWidget);
    });
  });
}
