import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wills_generic_app/main.dart';

void main() {
  testWidgets('App shell displays applet grid', (WidgetTester tester) async {
    await tester.pumpWidget(const GenericApp());

    expect(find.text('Applets'), findsOneWidget);
    expect(find.text('Example'), findsOneWidget);
    expect(find.byIcon(Icons.star), findsOneWidget);
  });
}
