// test/widget_test.dart
// Replaces the default `flutter create` counter-app test, which referenced
// a MyApp/counter widget that doesn't exist in DIYHub. This is a minimal
// smoke test just to confirm the app builds without crashing.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:diyhub/main.dart';

void main() {
  testWidgets('DIYHub app builds without crashing', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    // MyApp loads onboarding/theme state from shared_preferences asynchronously
    // before showing its real home, so give it a moment to settle.
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.byType(MaterialApp), findsOneWidget);
  });
}