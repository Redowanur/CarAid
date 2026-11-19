import 'package:geolocator/geolocator.dart';

class LocationService {
  LocationService._();

  /// Returns the device position, or null when permission/ GPS is unavailable.
  static Future<({double lat, double lng})?> current() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return null;

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return null;
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      ).timeout(const Duration(seconds: 6));

      return (lat: position.latitude, lng: position.longitude);
    } catch (_) {
      return null;
    }
  }
}
