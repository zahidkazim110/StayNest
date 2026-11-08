import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'hostel.dart';

class HostelActivityStorage {
  static const String _favoritesKey = 'staynest_favorite_hostels';
  static const String _recentKey = 'staynest_recent_hostels';

  static String idFor(Hostel hostel) {
    return '${hostel.name.trim().toLowerCase()}|${hostel.area.trim().toLowerCase()}';
  }

  static Map<String, dynamic> _toMap(Hostel hostel) {
    return {
      'name': hostel.name,
      'area': hostel.area,
      'monthlyRent': hostel.monthlyRent,
      'distanceKm': hostel.distanceKm,
      'rating': hostel.rating,
      'roomTypes': hostel.roomTypes.toList(),
      'facilities': hostel.facilities.toList(),
      'googleMapsUrl': hostel.googleMapsUrl,
      'contactPhone': hostel.contactPhone,
      'description': hostel.description,
      'availableBeds': hostel.availableBeds,
      'isOwnerListing': hostel.isOwnerListing,
      'roomPrices': hostel.roomPrices,
      'roomAvailability': hostel.roomAvailability,
    };
  }

  static Hostel _fromMap(Map<String, dynamic> map) {
    return Hostel(
      name: map['name']?.toString() ?? '',
      area: map['area']?.toString() ?? '',
      monthlyRent: (map['monthlyRent'] as num?)?.toInt() ?? 0,
      distanceKm: (map['distanceKm'] as num?)?.toDouble() ?? 0,
      rating: (map['rating'] as num?)?.toDouble() ?? 0,
      roomTypes: Set<String>.from(map['roomTypes'] ?? []),
      facilities: Set<String>.from(map['facilities'] ?? []),
      googleMapsUrl: map['googleMapsUrl']?.toString(),
      contactPhone: map['contactPhone']?.toString(),
      description: map['description']?.toString(),
      availableBeds: (map['availableBeds'] as num?)?.toInt(),
      isOwnerListing: map['isOwnerListing'] == true,
      roomPrices: map['roomPrices'] == null
          ? null
          : Map<String, int>.from(map['roomPrices'] as Map),
      roomAvailability: map['roomAvailability'] == null
          ? null
          : Map<String, int>.from(map['roomAvailability'] as Map),
    );
  }

  static Future<List<Hostel>> _readList(String key) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(key);

    if (raw == null || raw.isEmpty) return [];

    final decoded = jsonDecode(raw) as List<dynamic>;

    return decoded
        .map((item) => _fromMap(
              Map<String, dynamic>.from(item as Map),
            ))
        .toList();
  }

  static Future<void> _writeList(
    String key,
    List<Hostel> hostels,
  ) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(
      key,
      jsonEncode(hostels.map(_toMap).toList()),
    );
  }

  static Future<List<Hostel>> getFavorites() {
    return _readList(_favoritesKey);
  }

  static Future<List<Hostel>> getRecentlyViewed() {
    return _readList(_recentKey);
  }

  static Future<bool> isFavorite(Hostel hostel) async {
    final favorites = await getFavorites();
    return favorites.any((item) => idFor(item) == idFor(hostel));
  }

  static Future<void> toggleFavorite(Hostel hostel) async {
    final favorites = await getFavorites();
    final id = idFor(hostel);

    final exists = favorites.any((item) => idFor(item) == id);

    if (exists) {
      favorites.removeWhere((item) => idFor(item) == id);
    } else {
      favorites.insert(0, hostel);
    }

    await _writeList(_favoritesKey, favorites);
  }

  static Future<void> removeFavorite(Hostel hostel) async {
    final favorites = await getFavorites();
    favorites.removeWhere((item) => idFor(item) == idFor(hostel));
    await _writeList(_favoritesKey, favorites);
  }

  static Future<void> addRecentlyViewed(Hostel hostel) async {
    final recent = await getRecentlyViewed();
    final id = idFor(hostel);

    recent.removeWhere((item) => idFor(item) == id);
    recent.insert(0, hostel);

    if (recent.length > 10) {
      recent.removeRange(10, recent.length);
    }

    await _writeList(_recentKey, recent);
  }
}
