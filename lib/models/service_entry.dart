import '../core/utils/geo.dart';
import 'vehicle_type.dart';

class ServiceEntry {
  final String id;
  final String vehicleId;
  final String name;
  final String note;
  final int minPrice;
  final int maxPrice;
  final int durationMins;
  final bool popular;

  const ServiceEntry({
    required this.id,
    required this.vehicleId,
    required this.name,
    required this.note,
    required this.minPrice,
    required this.maxPrice,
    required this.durationMins,
    this.popular = false,
  });

  /// Typical quote used in bookings and bills (BDT).
  int get quote => quoteFor(minPrice, maxPrice);

  String get rangeLabel => '৳${_format(minPrice)} – ৳${_format(maxPrice)}';

  static String _format(int value) {
    final s = value.toString();
    if (s.length <= 3) return s;
    final head = s.substring(0, s.length - 3);
    final tail = s.substring(s.length - 3);
    return '$head,$tail';
  }
}

/// A single line on a customer's bill.
class BillLine {
  final String serviceId;
  final String name;
  final int amount;
  bool done;

  BillLine({
    required this.serviceId,
    required this.name,
    required this.amount,
    this.done = true,
  });
}

class VehicleOption {
  const VehicleOption(this.type, this.services);

  final VehicleType type;
  final List<ServiceEntry> services;

  List<ServiceEntry> get popularServices =>
      services.where((s) => s.popular).toList();
}
