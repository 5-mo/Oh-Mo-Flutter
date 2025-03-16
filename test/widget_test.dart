import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ohmo/main.dart';

void main() {
  testWidgets('Hello World text is displayed', (WidgetTester tester) async {
    await tester.pumpWidget(MyApp());

    expect(find.text('hello World'), findsOneWidget);
  });
}
