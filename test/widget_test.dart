import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wallpapersthemes/app.dart';

void main() {
  testWidgets('App launches without crashing', (WidgetTester tester) async {
    await tester.pumpWidget(const WcWallpapersApp());
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}