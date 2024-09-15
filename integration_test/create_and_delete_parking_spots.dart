import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter/material.dart';
import 'package:myapp/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();



  group('end-to-end-test', ()
  {
        testWidgets('book a parking spot',
                (tester) async {
                  app.main();
                  await tester.pumpAndSettle(const Duration(milliseconds: 500));

                  Finder loginButton = find.widgetWithText(
                      ElevatedButton, 'Log In');
                  expect(loginButton, findsOneWidget);
                  await tester.tap(loginButton);
                  await tester.pumpAndSettle(const Duration(milliseconds: 500));
                  Finder emailInput = find.widgetWithText(
                      TextFormField, 'E-mail address');
                  Finder passwordInput = find.widgetWithText(
                      TextFormField, 'Password');
                  await tester.enterText(
                      emailInput, 'default.tester@tester.de');
                  await tester.enterText(passwordInput, 'default');
                  await tester.pumpAndSettle(const Duration(milliseconds: 500));
                  Finder loginConfirm = find.widgetWithText(
                      ElevatedButton, 'Log In');
                  await tester.tap(loginConfirm);
                  await tester.pumpAndSettle(
                      const Duration(milliseconds: 4000));
                  Finder settingsButton = find.byIcon(Icons.settings);
                  await tester.tap(settingsButton);
                  await tester.pumpAndSettle(const Duration(milliseconds: 1000));
                  Finder parkingSpotButton = find.widgetWithText(
                      ElevatedButton, 'My Parking Spots');
                  await tester.tap(parkingSpotButton);
                  await tester.pumpAndSettle(const Duration(milliseconds: 1000));
                  Finder addButton = find.widgetWithText(TextButton, 'Add new');
                  await tester.tap(addButton);
                  await tester.pumpAndSettle(const Duration(milliseconds: 1000));
                  Finder imageInput = find.byIcon(Icons.camera);
                  await tester.tap(imageInput);
                  await tester.pumpAndSettle(const Duration(milliseconds: 10000));

                  Finder nameField = find.widgetWithText(TextField, 'Name');
                  Finder addressField = find.widgetWithText(
                      TextField, 'Address');
                  Finder descriptionField = find.widgetWithText(
                      TextField, 'Description');
                  await tester.enterText(nameField, 'Testing');
                  await tester.enterText(
                      addressField, 'Ahastraße 22, 64285, Darmstadt');
                  await tester.enterText(descriptionField, 'Test');
                  await tester.pumpAndSettle(const Duration(milliseconds: 500));
                  await tester.drag(find.byType(Slider), const Offset(100, 0));
                  await tester.pumpAndSettle(const Duration(milliseconds: 500));
                  Finder createButton = find.widgetWithText(
                      ElevatedButton, 'Create');
                  await tester.tap(createButton);
                  await tester.pumpAndSettle(const Duration(milliseconds: 4000));
                  Finder newParkingSpot = find.widgetWithText(TextButton, 'Testing');
                  expect(newParkingSpot, findsOneWidget);
                  Finder deleteButton = find.byIcon(Icons.delete);
                  await tester.tap(deleteButton);
                  await tester.pumpAndSettle(const Duration(milliseconds: 1000));
                  Finder confirmButton = find.widgetWithText(
                      ElevatedButton, 'Yes');
                  await tester.tap(confirmButton);
                  await tester.pumpAndSettle(const Duration(milliseconds: 4000));
            });
  });
}