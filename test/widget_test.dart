import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:grimorio/main.dart';

void main() {
  testWidgets('GrimorioApp usa o tema escuro', (tester) async {
    await tester.pumpWidget(const GrimorioApp());

    final app = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(app.themeMode, ThemeMode.dark);
    expect(app.theme?.brightness, Brightness.dark);
  });
}
