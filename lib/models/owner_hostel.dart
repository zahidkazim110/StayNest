import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class HostelRoom {
  final String id;
  final String roomName;
  final String roomType;
  final int monthlyRent;
  final int capacity;
  final int availableBeds;
  final Set<String> facilities;

  const HostelRoom({
    required this.id,
    required this.roomName,
    required this.roomType,
    required this.monthlyRent,
    required this.capacity,
    required this.availableBeds,
    required this.facilities,
  });

  HostelRoom copyWith({String? roomName, String? roomType, int? monthlyRent,
    int? capacity, int? availableBeds, Set<String>? facilities}) => HostelRoom(
      id: id, roomName: roomName ?? this.roomName,
      roomType: roomType ?? this.roomType, monthlyRent: monthlyRent ?? this.monthlyRent,
      capacity: capacity ?? this.capacity, availableBeds: availableBeds ?? this.availableBeds,
      facilities: facilities ?? this.facilities,
    );

  Map<String, dynamic> toMap() => {
    'id': id, 'roomName': roomName, 'roomType': roomType,
    'monthlyRent': monthlyRent, 'capacity': capacity,
    'availableBeds': availableBeds, 'facilities': facilities.toList(),
  };

  factory HostelRoom.fromMap(Map<String, dynamic> map) => HostelRoom(
    id: map['id']?.toString() ?? DateTime.now().microsecondsSinceEpoch.toString(),
    roomName: map['roomName']?.toString() ?? 'Room',
    roomType: map['roomType']?.toString() ?? 'Shared',
    monthlyRent: (map['monthlyRent'] as num?)?.toInt() ?? 0,
    capacity: (map['capacity'] as num?)?.toInt() ?? 1,
    availableBeds: (map['availableBeds'] as num?)?.toInt() ?? 1,
    facilities: Set<String>.from(map['facilities'] ?? const []),
  );
}

class OwnerHostel {
  final String id;
  final String name;
  final String address;
  final String city;
  final String description;
  final String contactPhone;
  final String googleMapsUrl;
  final double? latitude;
  final double? longitude;
  final Set<String> facilities;
  final List<HostelRoom> rooms;
  final List<String> imagePaths;
  final DateTime createdAt;

  const OwnerHostel({
    required this.id, required this.name, required this.address,
    required this.city, required this.description, required this.contactPhone,
    required this.googleMapsUrl, this.latitude, this.longitude,
    required this.facilities, required this.rooms,
    this.imagePaths = const [], required this.createdAt,
  });

  OwnerHostel copyWith({String? name, String? address, String? city,
    String? description, String? contactPhone, String? googleMapsUrl,
    double? latitude, double? longitude, Set<String>? facilities,
    List<HostelRoom>? rooms, List<String>? imagePaths}) => OwnerHostel(
      id: id, name: name ?? this.name, address: address ?? this.address,
      city: city ?? this.city, description: description ?? this.description,
      contactPhone: contactPhone ?? this.contactPhone,
      googleMapsUrl: googleMapsUrl ?? this.googleMapsUrl,
      latitude: latitude ?? this.latitude, longitude: longitude ?? this.longitude,
      facilities: facilities ?? this.facilities, rooms: rooms ?? this.rooms,
      imagePaths: imagePaths ?? this.imagePaths, createdAt: createdAt,
    );

  Map<String, dynamic> toMap() => {
    'id': id, 'name': name, 'address': address, 'city': city,
    'description': description, 'contactPhone': contactPhone,
    'googleMapsUrl': googleMapsUrl, 'latitude': latitude, 'longitude': longitude,
    'facilities': facilities.toList(), 'rooms': rooms.map((r) => r.toMap()).toList(),
    'imagePaths': imagePaths, 'createdAt': createdAt.toIso8601String(),
  };

  factory OwnerHostel.fromMap(Map<String, dynamic> map) => OwnerHostel(
    id: map['id']?.toString() ?? DateTime.now().microsecondsSinceEpoch.toString(),
    name: map['name']?.toString() ?? '',
    address: map['address']?.toString() ?? '',
    city: map['city']?.toString() ?? 'Islamabad',
    description: map['description']?.toString() ?? '',
    contactPhone: map['contactPhone']?.toString() ?? '',
    googleMapsUrl: map['googleMapsUrl']?.toString() ?? '',
    latitude: (map['latitude'] as num?)?.toDouble(),
    longitude: (map['longitude'] as num?)?.toDouble(),
    facilities: Set<String>.from(map['facilities'] ?? const []),
    rooms: (map['rooms'] as List? ?? const [])
      .map((item) => HostelRoom.fromMap(Map<String, dynamic>.from(item as Map))).toList(),
    imagePaths: List<String>.from(map['imagePaths'] ?? const []),
    createdAt: DateTime.tryParse(map['createdAt']?.toString() ?? '') ?? DateTime.now(),
  );
}

class OwnerHostelStorage {
  static const _key = 'staynest_owner_hostel_listings_v1';

  static Future<List<OwnerHostel>> getHostels() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null || raw.isEmpty) return [];
    try {
      final decoded = jsonDecode(raw) as List<dynamic>;
      return decoded.map((item) => OwnerHostel.fromMap(
        Map<String, dynamic>.from(item as Map))).toList();
    } catch (_) {
      return [];
    }
  }

  static Future<void> _save(List<OwnerHostel> hostels) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(hostels.map((h) => h.toMap()).toList()));
  }

  static Future<void> saveHostel(OwnerHostel hostel) async {
    final hostels = await getHostels();
    final index = hostels.indexWhere((h) => h.id == hostel.id);
    if (index == -1) {
      hostels.insert(0, hostel);
    } else {
      hostels[index] = hostel;
    }
    await _save(hostels);
  }

  static Future<void> deleteHostel(String id) async {
    final hostels = await getHostels();
    hostels.removeWhere((h) => h.id == id);
    await _save(hostels);
  }

  static Future<void> saveRoom(String hostelId, HostelRoom room) async {
    final hostels = await getHostels();
    final index = hostels.indexWhere((h) => h.id == hostelId);
    if (index == -1) return;
    final hostel = hostels[index];
    final rooms = [...hostel.rooms];
    final roomIndex = rooms.indexWhere((r) => r.id == room.id);
    if (roomIndex == -1) {
      rooms.add(room);
    } else {
      rooms[roomIndex] = room;
    }
    hostels[index] = hostel.copyWith(rooms: rooms);
    await _save(hostels);
  }

  static Future<void> deleteRoom(String hostelId, String roomId) async {
    final hostels = await getHostels();
    final index = hostels.indexWhere((h) => h.id == hostelId);
    if (index == -1) return;
    hostels[index] = hostels[index].copyWith(
      rooms: hostels[index].rooms.where((r) => r.id != roomId).toList(),
    );
    await _save(hostels);
  }
}
