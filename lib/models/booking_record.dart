class BookingRecord {
  final String id;
  final String hostelName;
  final String area;
  final String roomType;
  final int monthlyRent;
  final String studentName;
  final String phoneNumber;
  final String checkInDate;
  final String paymentMethod;
  final String status;
  final DateTime createdAt;

  const BookingRecord({
    required this.id,
    required this.hostelName,
    required this.area,
    required this.roomType,
    required this.monthlyRent,
    required this.studentName,
    required this.phoneNumber,
    required this.checkInDate,
    required this.paymentMethod,
    required this.status,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'hostelName': hostelName,
    'area': area,
    'roomType': roomType,
    'monthlyRent': monthlyRent,
    'studentName': studentName,
    'phoneNumber': phoneNumber,
    'checkInDate': checkInDate,
    'paymentMethod': paymentMethod,
    'status': status,
    'createdAt': createdAt.toIso8601String(),
  };

  factory BookingRecord.fromJson(Map<String, dynamic> json) {
    return BookingRecord(
      id: json['id'] as String,
      hostelName: json['hostelName'] as String,
      area: json['area'] as String,
      roomType: json['roomType'] as String,
      monthlyRent: json['monthlyRent'] as int,
      studentName: json['studentName'] as String,
      phoneNumber: json['phoneNumber'] as String,
      checkInDate: json['checkInDate'] as String,
      paymentMethod: json['paymentMethod'] as String,
      status: json['status'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}
