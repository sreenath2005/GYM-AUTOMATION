class AttendanceModel {
  final String id;
  final String userId;
  final String? userName;
  final DateTime date;
  final String status;

  AttendanceModel({
    required this.id,
    required this.userId,
    this.userName,
    required this.date,
    required this.status,
  });

  factory AttendanceModel.fromJson(Map<String, dynamic> json) {
    return AttendanceModel(
      id: json['_id'] ?? json['id'] ?? '',
      userId: json['userId'] is Map
          ? json['userId']['_id'] ?? json['userId']['id'] ?? ''
          : json['userId'] ?? '',
      userName: json['userId'] is Map ? json['userId']['name'] : null,
      date: json['date'] != null
          ? DateTime.parse(json['date'])
          : DateTime.now(),
      status: json['status'] ?? 'present',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'userId': userId,
      'date': date.toIso8601String(),
      'status': status,
    };
  }
}
