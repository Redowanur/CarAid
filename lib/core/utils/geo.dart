import 'dart:math' as math;

/// Great-circle distance in kilometres between two coordinates.
double haversineKm(double lat1, double lon1, double lat2, double lon2) {
  const earthRadiusKm = 6371.0;
  final dLat = _rad(lat2 - lat1);
  final dLon = _rad(lon2 - lon1);
  final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
      math.cos(_rad(lat1)) *
          math.cos(_rad(lat2)) *
          math.sin(dLon / 2) *
          math.sin(dLon / 2);
  final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
  return earthRadiusKm * c;
}

double _rad(double deg) => deg * math.pi / 180.0;

/// Linearly interpolates between two coordinates.
({double lat, double lng}) interpolatePoint(
  double fromLat,
  double fromLng,
  double toLat,
  double toLng,
  double t,
) {
  final clamped = t.clamp(0.0, 1.0);
  return (
    lat: fromLat + (toLat - fromLat) * clamped,
    lng: fromLng + (toLng - fromLng) * clamped,
  );
}

/// Rough city-traffic ETA for a distance in km.
int etaMinutesFor(double km) {
  const averageSpeedKmph = 22.0;
  return math.max(1, (km / averageSpeedKmph * 60).ceil());
}

/// Travel fee shown to customers: base fare + per-km rate, rounded to ৳5.
int travelFeeFor(double km) {
  final raw = 60 + 18 * km;
  return (raw / 5).ceil() * 5;
}

/// A deterministic quote inside a service's price range.
int quoteFor(int min, int max) {
  final raw = min + (max - min) * 0.35;
  return (raw / 10).ceil() * 10;
}
