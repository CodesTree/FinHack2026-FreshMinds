import 'package:flutter_test/flutter_test.dart';
import 'package:survivai/app.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const SurvivAIApp());
    expect(find.byType(SurvivAIApp), findsOneWidget);
  });
}
