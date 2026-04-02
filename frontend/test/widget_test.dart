import 'package:flutter_test/flutter_test.dart';
import 'package:sattva_ai/main.dart';

void main() {
  testWidgets('SattvaApp smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const SattvaApp());
    expect(find.byType(SattvaApp), findsOneWidget);
  });
}
