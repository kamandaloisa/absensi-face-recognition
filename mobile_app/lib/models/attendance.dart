class Attendance {
  final int? id;
  final int userId;
  final DateTime date;
  final DateTime? checkInTime;
  final double? checkInLatitude;
  final double? checkInLongitude;
  final String? checkInPhoto;
  final DateTime? checkOutTime;
  final double? checkOutLatitude;
  final double? checkOutLongitude;
  final String? checkOutPhoto;
  final String status;
  final String? notes;

  Attendance({
    this.id,
    required this.userId,
    required this.date,
    this.checkInTime,
    this.checkInLatitude,
    this.checkInLongitude,
    this.checkInPhoto,
    this.checkOutTime,
    this.checkOutLatitude,
    this.checkOutLongitude,
    this.checkOutPhoto,
    required this.status,
    this.notes,
  });

  factory Attendance.fromJson(Map<String, dynamic> json) {
    return Attendance(
      id: json['id'],
      userId: json['user_id'],
      date: DateTime.parse(json['date']),
      checkInTime: json['check_in_time'] != null 
          ? DateTime.parse('${json['date']} ${json['check_in_time']}')
          : null,
      checkInLatitude: json['check_in_latitude'] != null 
          ? double.parse(json['check_in_latitude'].toString())
          : null,
      checkInLongitude: json['check_in_longitude'] != null
          ? double.parse(json['check_in_longitude'].toString())
          : null,
      checkInPhoto: json['check_in_photo'],
      checkOutTime: json['check_out_time'] != null
          ? DateTime.parse('${json['date']} ${json['check_out_time']}')
          : null,
      checkOutLatitude: json['check_out_latitude'] != null
          ? double.parse(json['check_out_latitude'].toString())
          : null,
      checkOutLongitude: json['check_out_longitude'] != null
          ? double.parse(json['check_out_longitude'].toString())
          : null,
      checkOutPhoto: json['check_out_photo'],
      status: json['status'],
      notes: json['notes'],
    );
  }

  bool get hasCheckedIn => checkInTime != null;
  bool get hasCheckedOut => checkOutTime != null;
  bool get isPresent => status == 'hadir';
}
