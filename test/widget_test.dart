import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gps_tracker/main.dart';

void main() {
  testWidgets('Radar radius increment and override test', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const GpsTrackerApp());

    expect(find.textContaining('Current Radius: 0.0 m'), findsOneWidget);

    await tester.enterText(find.byType(TextField), '100');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pump();

    expect(find.textContaining('100.0 m'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'avada kedavra');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pump();

    expect(find.text('TRACKER OFFLINE'), findsOneWidget);
    expect(find.textContaining('0.0 m'), findsOneWidget);
  });
}
