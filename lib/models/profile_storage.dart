import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'student_profile.dart';

class ProfileStorage {
  static const String _profileKey = 'staynest_student_profile';
  static const String _cnicKey = 'staynest_student_cnic';

  static const FlutterSecureStorage _secureStorage =
      FlutterSecureStorage();

  static Future<void> saveProfile(StudentProfile profile) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(
      _profileKey,
      jsonEncode(profile.toJson()),
    );

    if (profile.cnic.trim().isNotEmpty) {
      await _secureStorage.write(
        key: _cnicKey,
        value: profile.cnic.trim(),
      );
    } else {
      await _secureStorage.delete(key: _cnicKey);
    }
  }

  static Future<StudentProfile?> getProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final savedData = prefs.getString(_profileKey);

    if (savedData == null || savedData.isEmpty) {
      return null;
    }

    final decoded = jsonDecode(savedData) as Map<String, dynamic>;
    final cnic = await _secureStorage.read(key: _cnicKey) ?? '';

    return StudentProfile.fromJson(
      decoded,
      cnic: cnic,
    );
  }

  static Future<void> clearProfile() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove(_profileKey);
    await _secureStorage.delete(key: _cnicKey);
  }
}
