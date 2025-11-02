// Dairy Management System - Widget Test
// Basic test to verify app initialization

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:dairify/main.dart';

void main() {
  testWidgets('App initializes correctly', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const DairifyApp());

    // Verify that the app loads (splash screen or login should appear)
    await tester.pump();
    
    // Basic verification that the app widget tree is created
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
