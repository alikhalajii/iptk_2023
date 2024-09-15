// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:myapp/accountPages/signup_page.dart';
import 'package:myapp/accountPages/login_page.dart';
import 'package:myapp/homePages/entering_page.dart';

void main() {
  testWidgets('EnteringPage - Login Button Pressed',
      (WidgetTester tester) async {
    // Build the EnteringPage widget
    await tester.pumpWidget(MaterialApp(home: EnteringPage()));

    // Tap the login button
    await tester.tap(find.text('Log In'));
    await tester.pumpAndSettle();

    // Verify that LoginPage is pushed to the navigator
    expect(find.byType(LoginPage), findsOneWidget);
  });

  testWidgets('EnteringPage - Sign Up Text Tapped',
      (WidgetTester tester) async {
    // Build the EnteringPage widget
    await tester.pumpWidget(MaterialApp(home: EnteringPage()));

    // Tap the sign up text
    await tester.tap(find.text('Sign up'));
    await tester.pumpAndSettle();

    // Verify that SignUpPage is pushed to the navigator
    expect(find.byType(SignUpPage), findsOneWidget);
  });
}
