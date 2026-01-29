import 'package:flutter_test/flutter_test.dart';
import 'package:breath_timer/main.dart';

void main() {
  testWidgets('Breath Timer smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const BreathTimerApp());

    // Verify that our app starts at the Preset Library.
    expect(find.text('Preset Library'), findsOneWidget);
  });
}
