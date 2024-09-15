import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter/material.dart';

import 'package:myapp/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();



  group('end-to-end-test', () {
    testWidgets('create and delete account',
        (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(milliseconds: 500));

      Finder signUpButton = find.widgetWithText(InkWell, 'Sign up');
      expect(signUpButton, findsOneWidget);
      await tester.tap(signUpButton);
      await tester.pumpAndSettle(const Duration(milliseconds: 500));
      Finder firstNameInput = find.widgetWithText(TextFormField, 'First Name');
      Finder lastNameInput = find.widgetWithText(TextFormField, 'Last Name');
      Finder emailInput = find.widgetWithText(TextFormField, 'Email');
      Finder passwordInput = find.widgetWithText(TextFormField, 'Password');
      await tester.enterText(firstNameInput, 'Tester');
      await tester.enterText(lastNameInput, 'Tester');
      await tester.enterText(emailInput, 'tester@tester.de');
      await tester.enterText(passwordInput, 'tester');
      await tester.pumpAndSettle(const Duration(milliseconds: 500));
      Finder signUpConfirm = find.widgetWithText(ElevatedButton, 'Sign Up');
      expect(signUpConfirm, findsOneWidget);
      await tester.tap(signUpConfirm);
      await tester.pumpAndSettle(const Duration(milliseconds: 1000));
      Finder skipSurveyButton = find.widgetWithText(ElevatedButton, 'Skip Survey');
      await tester.tap(skipSurveyButton);
      await tester.pumpAndSettle(const Duration(milliseconds: 4000));
      Finder settingsButton = find.byIcon(Icons.settings);
      await tester.tap(settingsButton);
      await tester.pumpAndSettle(const Duration(milliseconds: 500));
      Finder accountButton = find.widgetWithText(ElevatedButton, 'Account');
      await tester.tap(accountButton);
      await tester.pumpAndSettle(const Duration(milliseconds: 500));
      Finder deleteAccountButton = find.widgetWithText(ElevatedButton, 'Delete Account');
      await tester.tap(deleteAccountButton);
      await tester.pumpAndSettle(const Duration(milliseconds: 1000));
      Finder passwordValidation = find.widgetWithText(TextFormField, 'Password');
      await tester.enterText(passwordValidation, 'tester');
      await tester.pumpAndSettle(const Duration(milliseconds: 500));
      Finder deleteAccountConfirm = find.widgetWithText(ElevatedButton, 'Delete Account');
      await tester.tap(deleteAccountConfirm);
      await tester.pumpAndSettle(const Duration(milliseconds: 500));
      Finder signUpTest = find.widgetWithText(InkWell, 'Sign up');
      Finder loginTest = find.widgetWithText(ElevatedButton, 'Log In');
      expect(signUpTest, findsOneWidget);
      expect(loginTest, findsOneWidget);
        });
  });
}