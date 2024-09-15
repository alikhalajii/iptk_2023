import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Show Filter Options Dialog', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (BuildContext context) {
              return ElevatedButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text('Filter Options'),
                        content: const Text('Filter options dialog content'),
                        actions: <Widget>[
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: const Text('Close'),
                          ),
                        ],
                      );
                    },
                  );
                },
                child: const Text('Show Dialog'),
              );
            },
          ),
        ),
      ),
    );

    // Tap the button to show the dialog
    await tester.tap(find.text('Show Dialog'));
    await tester.pumpAndSettle();

    // Verify that the dialog is shown
    expect(find.text('Filter Options'), findsOneWidget);
    expect(find.text('Filter options dialog content'), findsOneWidget);

    // Tap the close button to dismiss the dialog
    await tester.tap(find.text('Close'));
    await tester.pumpAndSettle();

    // Verify that the dialog is dismissed
    expect(find.text('Filter Options'), findsNothing);
    expect(find.text('Filter options dialog content'), findsNothing);
  });
}
