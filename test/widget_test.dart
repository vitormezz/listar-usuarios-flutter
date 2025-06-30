// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:lista_usuarios_app/main.dart';

void main() {
  testWidgets('User List App smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(UserListApp());

    // Verify that our app loads
    expect(find.text('Lista de Usuários'), findsOneWidget);
    
    // Wait for any async operations
    await tester.pumpAndSettle();
    
    // Verify search field is present
    expect(find.byType(TextField), findsOneWidget);
  });
}
