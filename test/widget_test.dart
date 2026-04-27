import 'package:flutter_test/flutter_test.dart';

import 'package:cr_analyze_app/main.dart';

void main() {
  testWidgets('Home screen renders', (WidgetTester tester) async {
    await tester.pumpWidget(const CRAnalyzeApp());

    expect(find.text('CR Analyze — Anti-Deck'), findsOneWidget);
    expect(find.text('Analiz Et'), findsOneWidget);
  });
}
