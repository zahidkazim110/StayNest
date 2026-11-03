import 'package:flutter_test/flutter_test.dart';
import 'package:staynest/main.dart';

void main() {
  testWidgets('StayNest app launches', (WidgetTester tester) async {
    await tester.pumpWidget(const StayNestApp());

    expect(find.text('StayNest'), findsOneWidget);
    expect(find.text('Get Started'), findsOneWidget);
  });
}
