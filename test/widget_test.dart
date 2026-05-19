import 'package:flutter_test/flutter_test.dart';
import 'package:test_app/main.dart';

void main() {
  testWidgets('DayDesk shows splash before the onboarding screen',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('DayDesk'), findsOneWidget);
    expect(find.text('Master your time and wealth.'), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 1500));
    await tester.pumpAndSettle();

    expect(find.text('Tell us about yourself'), findsOneWidget);
    expect(find.text('Step 1 of 4'), findsOneWidget);
    expect(find.text('Next'), findsOneWidget);
  });
}
