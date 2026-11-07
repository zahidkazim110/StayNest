import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'booking_record.dart';

class BookingStorage {
  static const String _storageKey = 'staynest_bookings';

  static Future<List<BookingRecord>> getBookings() async {
    final prefs = await SharedPreferences.getInstance();
    final savedData = prefs.getString(_storageKey);

    if (savedData == null || savedData.isEmpty) {
      return [];
    }

    final List<dynamic> decoded = jsonDecode(savedData);

    return decoded
        .map((item) => BookingRecord.fromJson(
              Map<String, dynamic>.from(item as Map),
            ))
        .toList();
  }

  static Future<void> saveBooking(BookingRecord booking) async {
    final bookings = await getBookings();
    bookings.insert(0, booking);

    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(
      _storageKey,
      jsonEncode(bookings.map((item) => item.toJson()).toList()),
    );
  }
}
