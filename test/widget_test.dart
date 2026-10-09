import 'package:flutter/material.dart';
import 'package:kuliahumumfiks/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('SIM-KU app smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const SIMKUApp());
    // Verify dashboard or login loads without crash.
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
