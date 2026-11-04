class Hostel {
  final String name;
  final String area;
  final int monthlyRent;
  final double distanceKm;
  final double rating;
  final Set<String> roomTypes;
  final Set<String> facilities;

  const Hostel({
    required this.name,
    required this.area,
    required this.monthlyRent,
    required this.distanceKm,
    required this.rating,
    required this.roomTypes,
    required this.facilities,
  });

  String? operator [](String key) {
    switch (key) {
      case 'name':
        return name;
      case 'area':
        return area;
      case 'price':
        return 'PKR ${monthlyRent.toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')} / month';
      case 'distance':
        return '${distanceKm.toStringAsFixed(1)} km away';
      case 'rating':
        return rating.toStringAsFixed(1);
      default:
        return null;
    }
  }
}
