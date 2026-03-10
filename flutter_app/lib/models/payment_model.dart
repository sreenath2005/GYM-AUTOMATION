class PaymentModel {
  final String id;
  final String userId;
  final String? userName;
  final double amount;
  final String status;
  final DateTime date;
  final String method;
  final String? description;

  PaymentModel({
    required this.id,
    required this.userId,
    this.userName,
    required this.amount,
    required this.status,
    required this.date,
    required this.method,
    this.description,
  });

  factory PaymentModel.fromJson(Map<String, dynamic> json) {
    return PaymentModel(
      id: json['_id'] ?? json['id'] ?? '',
      userId: json['userId'] is Map
          ? json['userId']['_id'] ?? json['userId']['id'] ?? ''
          : json['userId'] ?? '',
      userName: json['userId'] is Map ? json['userId']['name'] : null,
      amount: (json['amount'] ?? 0).toDouble(),
      status: json['status'] ?? 'pending',
      date: json['date'] != null
          ? DateTime.parse(json['date'])
          : DateTime.now(),
      method: json['method'] ?? 'cash',
      description: json['description'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'userId': userId,
      'amount': amount,
      'status': status,
      'date': date.toIso8601String(),
      'method': method,
      'description': description ?? '',
    };
  }
}
