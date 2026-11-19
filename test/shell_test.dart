import 'package:call_mechanic/models/vehicle_type.dart';
import 'package:call_mechanic/screens/customer/customer_shell.dart';
import 'package:call_mechanic/screens/mechanic/mechanic_shell.dart';
import 'package:call_mechanic/state/app_state.dart';
import 'package:call_mechanic/widgets/app_nav_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Finder navLabel(String label) => find.descendant(
      of: find.byType(AppBottomNav),
      matching: find.text(label),
    );

void main() {
  setUp(() => appState.resetAll());

  testWidgets('customer shell renders all four tabs', (tester) async {
    appState.signInDemo(UserRole.customer);
    await tester.pumpWidget(const MaterialApp(home: CustomerShell()));
    await tester.pumpAndSettle();

    for (final label in ['Home', 'Mechanics', 'Jobs', 'Profile']) {
      expect(navLabel(label), findsOneWidget);
    }
    expect(tester.takeException(), isNull);
  });

  testWidgets('customer can visit every tab without errors', (tester) async {
    appState.signInDemo(UserRole.customer);
    await tester.pumpWidget(const MaterialApp(home: CustomerShell()));
    await tester.pumpAndSettle();

    for (final label in ['Mechanics', 'Jobs', 'Profile', 'Home']) {
      await tester.tap(navLabel(label));
      await tester.pumpAndSettle();
      expect(navLabel(label), findsOneWidget);
    }
    expect(tester.takeException(), isNull);
  });

  testWidgets('customer shell can open directly on the jobs tab', (tester) async {
    appState.signInDemo(UserRole.customer);
    await tester.pumpWidget(
      const MaterialApp(home: CustomerShell(initialTab: 2)),
    );
    await tester.pumpAndSettle();

    expect(find.text('Your jobs'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('mechanic shell renders all four tabs', (tester) async {
    appState.signInDemo(UserRole.mechanic);
    await tester.pumpWidget(const MaterialApp(home: MechanicShell()));
    await tester.pumpAndSettle();

    for (final label in ['Dashboard', 'Requests', 'Earnings', 'Profile']) {
      expect(navLabel(label), findsOneWidget);
    }
    expect(tester.takeException(), isNull);
  });

  testWidgets('mechanic can visit every tab without errors', (tester) async {
    appState.signInDemo(UserRole.mechanic);
    await tester.pumpWidget(const MaterialApp(home: MechanicShell()));
    await tester.pumpAndSettle();

    for (final label in ['Requests', 'Earnings', 'Profile', 'Dashboard']) {
      await tester.tap(navLabel(label));
      await tester.pumpAndSettle();
      expect(navLabel(label), findsOneWidget);
    }
    expect(tester.takeException(), isNull);
  });
}
