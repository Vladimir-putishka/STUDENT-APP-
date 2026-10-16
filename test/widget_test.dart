import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:student_assistant/main.dart';
import 'package:flutter/foundation.dart';

void main() {
  testWidgets(
    'Student Assistant Registration Screen Test',
        (WidgetTester tester) async {
      await tester.pumpWidget(const StudentAssistantApp());

      expect(
        find.text('Student Registration'),
        findsOneWidget,
      );

      expect(
        find.text('Create Your Account'),
        findsOneWidget,
      );

      expect(
        find.byType(TextFormField),
        findsNWidgets(4),
      );

      expect(
        find.text('Register'),
        findsOneWidget,
      );
    },
  );
}