import '../core/theme/app_theme.dart';
import 'payment_method.dart';
import 'service_entry.dart';

enum BookingStatus {
  idle,
  searching,
  enRoute,
  arrived,
  inProgress,
  completed,
  paid,
  cancelled,
}

extension BookingStatusX on BookingStatus {
  String get label {
    switch (this) {
      case BookingStatus.idle:
        return 'Not booked';
      case BookingStatus.searching:
        return 'Finding a mechanic';
      case BookingStatus.enRoute:
        return 'On the way';
      case BookingStatus.arrived:
        return 'Arrived';
      case BookingStatus.inProgress:
        return 'Service in progress';
      case BookingStatus.completed:
        return 'Awaiting payment';
      case BookingStatus.paid:
        return 'Paid';
      case BookingStatus.cancelled:
        return 'Cancelled';
    }
  }

  int get step {
    switch (this) {
      case BookingStatus.idle:
      case BookingStatus.searching:
        return 0;
      case BookingStatus.enRoute:
        return 1;
      case BookingStatus.arrived:
        return 2;
      case BookingStatus.inProgress:
        return 3;
      case BookingStatus.completed:
      case BookingStatus.paid:
        return 4;
      case BookingStatus.cancelled:
        return 0;
    }
  }
}

class BookingRecord {
  final String id;
  final String title;
  final String vehicle;
  final String mechanicName;
  final DateTime date;
  final List<BillLine> lines;
  final int travelFee;
  final BookingStatus status;
  final PaymentMethod? method;
  final String? txn;

  const BookingRecord({
    required this.id,
    required this.title,
    required this.vehicle,
    required this.mechanicName,
    required this.date,
    required this.lines,
    required this.travelFee,
    required this.status,
    this.method,
    this.txn,
  });

  int get servicesTotal =>
      lines.where((l) => l.done).fold(0, (sum, l) => sum + l.amount);

  int get total => servicesTotal + travelFee;

  List<BillLine> get doneLines => lines.where((l) => l.done).toList();
}

class JobRequest {
  final String id;
  final String customerName;
  final String area;
  final String vehicle;
  final String problem;
  final double distanceKm;
  final int payout;
  final bool urgent;
  final DateTime createdAt;

  const JobRequest({
    required this.id,
    required this.customerName,
    required this.area,
    required this.vehicle,
    required this.problem,
    required this.distanceKm,
    required this.payout,
    required this.urgent,
    required this.createdAt,
  });

  String get etaLabel => distanceKm <= 1
      ? '${(distanceKm * 1000).round()} m away'
      : '${distanceKm.toStringAsFixed(1)} km away';
}

class ChatMessage {
  final String text;
  final bool mine;
  final DateTime time;

  ChatMessage({required this.text, required this.mine, DateTime? time})
      : time = time ?? DateTime.now();
}

class SubscriptionPlan {
  final String id;
  final String name;
  final int price;
  final String period;
  final int months;
  final List<String> perks;
  final bool popular;

  const SubscriptionPlan({
    required this.id,
    required this.name,
    required this.price,
    required this.period,
    required this.months,
    required this.perks,
    this.popular = false,
  });

  String get priceLabel => '৳$price';
}

class UserProfile {
  final String uid;
  final String name;
  final String email;
  final String phone;
  final String role;
  final bool isPremium;
  final DateTime? trialEndsAt;
  final String? planLabel;

  const UserProfile({
    required this.uid,
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
    this.isPremium = false,
    this.trialEndsAt,
    this.planLabel,
  });

  bool get hasAccess =>
      isPremium || (trialEndsAt?.isAfter(DateTime.now()) ?? false);

  static const empty = UserProfile(
    uid: '',
    name: '',
    email: '',
    phone: '',
    role: 'customer',
  );
}

class AppPalette {
  AppPalette._();
  static const success = AppColors.teal;
}
