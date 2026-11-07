class StudentProfile {
  final String fullName;
  final String email;
  final String phoneNumber;
  final String occupation;
  final String universityName;
  final String cnic;

  const StudentProfile({
    required this.fullName,
    required this.email,
    required this.phoneNumber,
    required this.occupation,
    required this.universityName,
    required this.cnic,
  });

  Map<String, dynamic> toJson() {
    return {
      'fullName': fullName,
      'email': email,
      'phoneNumber': phoneNumber,
      'occupation': occupation,
      'universityName': universityName,
    };
  }

  factory StudentProfile.fromJson(
    Map<String, dynamic> json, {
    String cnic = '',
  }) {
    return StudentProfile(
      fullName: json['fullName'] ?? '',
      email: json['email'] ?? '',
      phoneNumber: json['phoneNumber'] ?? '',
      occupation: json['occupation'] ?? 'Student',
      universityName: json['universityName'] ?? '',
      cnic: cnic,
    );
  }
}
