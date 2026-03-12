import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_nerve_example/main.dart';

void main() {
  testWidgets('NerveExampleApp renders without crashing', (tester) async {
    await tester.pumpWidget(const NerveExampleApp());
    // The app should render at least one widget
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
