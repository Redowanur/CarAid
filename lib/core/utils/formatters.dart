import 'package:intl/intl.dart';

final NumberFormat _comma = NumberFormat('#,##0');
final DateFormat _shortDate = DateFormat('d MMM, h:mm a');
final DateFormat _day = DateFormat('EEE, d MMM');

/// Formats a BDT amount, e.g. 1200 -> "৳1,200".
String money(num amount) => '৳${_comma.format(amount.round())}';

/// Formats a distance in km, showing metres below one kilometre.
String distance(double km) {
  if (km < 1) return '${(km * 1000).round()} m';
  return '${km.toStringAsFixed(1)} km';
}

String minutes(int mins) {
  if (mins <= 1) return '1 min';
  return '$mins mins';
}

String shortDate(DateTime date) => _shortDate.format(date);

String dayLabel(DateTime date) => _day.format(date);

String initials(String name) {
  final parts = name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty);
  if (parts.isEmpty) return '?';
  if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
  return (parts.first.substring(0, 1) + parts.last.substring(0, 1))
      .toUpperCase();
}

String greeting(DateTime now) {
  if (now.hour < 12) return 'Good morning';
  if (now.hour < 17) return 'Good afternoon';
  return 'Good evening';
}

/// Masked transaction id for receipts.
String txnId() {
  final stamp = DateTime.now().millisecondsSinceEpoch.toString();
  return 'CRD${stamp.substring(stamp.length - 8)}';
}
