import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_app/app.dart';

void main() {
  testWidgets('ElectroChem AI app loads successfully', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const ElectroChemAIApp());

    expect(find.text('ElectroChem AI'), findsOneWidget);
  });
}
