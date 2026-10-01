// This is a widget test for the registration form.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:app/main.dart';

void main() {
  testWidgets('Registration form validation test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verify that the form fields are present
    expect(find.text('Full Name'), findsOneWidget);
    expect(find.text('Shakha'), findsOneWidget);
    expect(find.text('Mobile Number'), findsOneWidget);
    expect(find.text('Register and Get QR'), findsOneWidget);

    // Wait for shakhas to load
    await tester.pumpAndSettle(const Duration(seconds: 2));

    // Select a shakha (required for form validation)
    await tester.tap(find.byType(DropdownButtonFormField<String>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Bijwasan').first);
    await tester.pumpAndSettle();

    // Enter invalid mobile number (not 10 digits)
    await tester.enterText(find.byType(TextFormField).at(0), 'John Doe');
    await tester.enterText(find.byType(TextFormField).at(1), '12345'); // Only 5 digits

    // Tap the register button
    await tester.tap(find.text('Register and Get QR'));
    await tester.pump();

    // Should show validation error for mobile number
    expect(find.text('Please enter a valid 10-digit mobile number'), findsOneWidget);

    // Enter valid data
    await tester.enterText(find.byType(TextFormField).at(0), 'John Doe');
    await tester.enterText(find.byType(TextFormField).at(1), '1234567890'); // 10 digits

    // Tap the register button
    await tester.tap(find.text('Register and Get QR'));
    await tester.pumpAndSettle();

    // Should show success screen with QR code
    expect(find.text('Registration Successful!'), findsOneWidget);
    expect(find.text('Register Another'), findsOneWidget);
  });
}
