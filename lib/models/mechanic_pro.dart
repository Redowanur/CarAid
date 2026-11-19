class MechanicPro {
  final String id;
  final String name;
  final String garage;
  final double rating;
  final int reviews;
  final int experienceYears;
  final List<String> specialties;
  final String phone;
  final bool isOnline;
  final double lat;
  final double lng;
  final int jobsDone;
  final double baseDistanceKm;

  const MechanicPro({
    required this.id,
    required this.name,
    required this.garage,
    required this.rating,
    required this.reviews,
    required this.experienceYears,
    required this.specialties,
    required this.phone,
    required this.lat,
    required this.lng,
    required this.jobsDone,
    this.isOnline = true,
    this.baseDistanceKm = 2.4,
  });

  String get firstName => name.split(' ').first;

  String get experienceLabel => '$experienceYears yrs exp';
}
