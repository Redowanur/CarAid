import 'package:caraid/car_aid_app.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('app boots into the auth screen', (WidgetTester tester) async {
    await tester.pumpWidget(const CarAidApp());
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();

    expect(find.text('Welcome back'), findsOneWidget);
    expect(find.text('Explore as Customer'), findsOneWidget);
    expect(find.text('Explore as Mechanic'), findsOneWidget);
  });
}
