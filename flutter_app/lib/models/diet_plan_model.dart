class DietPlanModel {
  final String id;
  final String userId;
  final String planDetails;
  final DateTime updatedAt;

  DietPlanModel({
    required this.id,
    required this.userId,
    required this.planDetails,
    required this.updatedAt,
  });

  factory DietPlanModel.fromJson(Map<String, dynamic> json) {
    return DietPlanModel(
      id: json['_id'] ?? json['id'] ?? '',
      userId: json['userId'] ?? '',
      planDetails: json['planDetails'] ?? '',
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'userId': userId,
      'planDetails': planDetails,
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}
