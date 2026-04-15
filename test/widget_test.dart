import 'package:flutter_test/flutter_test.dart';

import 'package:sanjida_go/main.dart';

void main() {
  testWidgets('Home screen shows tool list', (WidgetTester tester) async {
    await tester.pumpWidget(const SanjidaGoApp());

    expect(find.text('Sanjida Go'), findsOneWidget);
    expect(find.text('String reversal'), findsOneWidget);
    expect(find.text('BMI'), findsOneWidget);
    expect(find.text('Temperature'), findsOneWidget);
    expect(find.text('Islamic inheritance'), findsOneWidget);
  });
}
