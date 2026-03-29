import 'package:apidash_design_system/widgets/list_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget wrap(Widget child) {
    return MaterialApp(
      home: Scaffold(body: child),
    );
  }

  group('ADListTile', () {
    testWidgets('renders switchOnOff and triggers callback',
            (WidgetTester tester) async {
          bool? changedValue;

          await tester.pumpWidget(
            wrap(
              ADListTile(
                type: ListTileType.switchOnOff,
                title: 'Switch Tile',
                value: false,
                onChanged: (value) {
                  changedValue = value;
                },
              ),
            ),
          );

          expect(find.text('Switch Tile'), findsOneWidget);
          expect(find.byType(SwitchListTile), findsOneWidget);

          await tester.tap(find.byType(Switch));
          await tester.pumpAndSettle();

          expect(changedValue, isNotNull);
        });

    testWidgets('renders checkbox and triggers callback',
            (WidgetTester tester) async {
          bool? changedValue;

          await tester.pumpWidget(
            wrap(
              ADListTile(
                type: ListTileType.checkbox,
                title: 'Checkbox Tile',
                value: false,
                onChanged: (value) {
                  changedValue = value;
                },
              ),
            ),
          );

          expect(find.text('Checkbox Tile'), findsOneWidget);
          expect(find.byType(CheckboxListTile), findsOneWidget);

          await tester.tap(find.byType(Checkbox));
          await tester.pumpAndSettle();

          expect(changedValue, isNotNull);
        });

    testWidgets('renders button and triggers callback on tap',
            (WidgetTester tester) async {
          bool? changedValue;

          await tester.pumpWidget(
            wrap(
              ADListTile(
                type: ListTileType.button,
                title: 'Button Tile',
                value: true,
                onChanged: (value) {
                  changedValue = value;
                },
              ),
            ),
          );

          expect(find.text('Button Tile'), findsOneWidget);
          expect(find.byType(ListTile), findsOneWidget);

          await tester.tap(find.byType(ListTile));
          await tester.pumpAndSettle();

          expect(changedValue, true);
        });
  });
}