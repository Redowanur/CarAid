import 'package:call_mechanic/core/utils/geo.dart';
import 'package:call_mechanic/data/demo_data.dart';
import 'package:call_mechanic/models/booking.dart';
import 'package:call_mechanic/models/payment_method.dart';
import 'package:call_mechanic/models/service_entry.dart';
import 'package:call_mechanic/models/vehicle_type.dart';
import 'package:call_mechanic/state/app_state.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  setUp(() => appState.resetAll());

  group('session and subscriptions', () {
    test('demo customer starts on the free plan', () {
      appState.signInDemo(UserRole.customer);

      expect(appState.isSignedIn, isTrue);
      expect(appState.isCustomer, isTrue);
      expect(appState.firstName, 'Ayaan');
      expect(appState.hasAccess, isFalse);
    });

    test('trial unlocks premium for the active role only', () {
      appState.signInDemo(UserRole.customer);
      appState.startTrial();

      expect(appState.customerHasAccess, isTrue);
      expect(appState.mechanicHasAccess, isFalse);
      expect(appState.accessLabel, contains('Free trial'));
    });

    test('plans are role specific', () {
      expect(plansForRole(UserRole.customer).first.id, 'cust-monthly');
      expect(plansForRole(UserRole.mechanic).first.id, 'mech-monthly');
    });
  });

  group('customer booking journey', () {
    test('vehicle selection resets stale services', () {
      appState.signInDemo(UserRole.customer);
      appState.toggleService('car-oil');
      expect(appState.servicesEstimate, greaterThan(0));

      appState.chooseVehicle(vehicleTypes[1]);
      expect(appState.selectedServices, isEmpty);
    });

    test('tracking, checklist, bill and payment produce a paid record', () {
      appState.signInDemo(UserRole.customer);
      appState.toggleService('car-oil');

      appState.startBooking(demoMechanics.first);
      expect(appState.status, BookingStatus.searching);
      expect(appState.chat, isNotEmpty);

      appState.skipToArrival();
      expect(appState.status, BookingStatus.arrived);
      expect(appState.progress, 1.0);

      appState.startService();
      expect(appState.status, BookingStatus.inProgress);
      expect(appState.billLines, isNotEmpty);

      final lines = List.of(appState.billLines);
      lines.last.done = false; // only the first line is actually completed
      final expectedService =
          lines.where((line) => line.done).fold(0, (sum, l) => sum + l.amount);
      appState.completeService(lines);

      expect(appState.status, BookingStatus.completed);
      expect(appState.currentBooking, isNotNull);
      expect(appState.currentBooking!.total,
          expectedService + appState.travelFee);
      expect(appState.doneLines, hasLength(lines.length - 1));

      appState.pay(PaymentMethod.bkash);
      expect(appState.status, BookingStatus.paid);
      expect(appState.history.first.method, PaymentMethod.bkash);
      expect(appState.history.first.txn, isNotEmpty);
      expect(appState.history.first.total, appState.currentBooking!.total);
    });

    test('travel fee follows base + per-km formula', () {
      expect(travelFeeFor(0), 60);
      expect(travelFeeFor(2), 100);
      expect(travelFeeFor(5), 150);
    });
  });

  group('mechanic workspace', () {
    test('accepting and completing a job updates earnings', () {
      appState.signInDemo(UserRole.mechanic);
      final request = appState.requests.first;
      final before = appState.todayEarnings;

      appState.acceptRequest(request);
      expect(appState.activeRequest, same(request));
      expect(appState.requests, isNot(contains(request)));

      final lines = [
        BillLine(serviceId: 'car-brake', name: 'Brake Pad', amount: 2750),
      ];
      appState.completeMechanicJob(lines, 95);

      expect(appState.activeRequest, isNull);
      expect(appState.todayEarnings, before + 2845);
      expect(appState.payouts.first.travelFee, 95);
      expect(appState.payouts.first.total, 2845);
    });

    test('online toggle is reflected in state', () {
      appState.signInDemo(UserRole.mechanic);
      appState.setOnline(false);
      expect(appState.online, isFalse);
    });
  });
}
