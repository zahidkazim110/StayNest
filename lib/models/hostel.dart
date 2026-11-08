class Hostel {
  final String name;
  final String area;
  final int monthlyRent;
  final double distanceKm;
  final double rating;
  final Set<String> roomTypes;
  final Set<String> facilities;
  final String? googleMapsUrl;
  final String? contactPhone;
  final String? description;
  final int? availableBeds;
  final bool isOwnerListing;

  const Hostel({
    required this.name,
    required this.area,
    required this.monthlyRent,
    required this.distanceKm,
    required this.rating,
    required this.roomTypes,
    required this.facilities,
    this.googleMapsUrl,
    this.contactPhone,
    this.description,
    this.availableBeds,
    this.isOwnerListing = false,
  });

  String? operator [](String key) {
    switch (key) {
      case 'name':
        return name;
      case 'area':
        return area;
      case 'price':
        return 'PKR ${monthlyRent.toString().replaceAllMapped(RegExp(r'(\\d)(?=(\\d{3})+(?!\\d))'), (m) => '${m[1]},')} / month';
      case 'distance':
        return distanceKm > 0 ? '${distanceKm.toStringAsFixed(1)} km away' : 'Location listed';
      case 'rating':
        return rating > 0 ? rating.toStringAsFixed(1) : 'New';
      default:
        return null;
    }
  }
}
