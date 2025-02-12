import 'dart:convert';

enum TransactionType {
  receita,
  despesa,
  transferencia
}

class TransactionModel {
  final String id;
  final String? userId;
  final String title;
  final double amount;
  final DateTime date;
  final int categoryId;
  final TransactionType type;
  final String? paymentType;
  TransactionModel({
    required this.id,
    this.userId,
    required this.title,
    required this.amount,
    required this.date,
    required this.categoryId,
    required this.type,
    this.paymentType,
  });

  TransactionModel copyWith({
    String? id,
    String? userId,
    String? title,
    double? amount,
    DateTime? date,
    int? categoryId,
    TransactionType? type,
    String? paymentType,
  }) {
    return TransactionModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      categoryId: categoryId ?? this.categoryId,
      type: type ?? this.type,
      paymentType: paymentType ?? this.paymentType,
    );
  }

  Map<String, dynamic> toMap() {
    final result = <String, dynamic>{};

    result.addAll({
      'id': id
    });
    if (userId != null) {
      result.addAll({
        'userId': userId
      });
    }
    result.addAll({
      'title': title
    });
    result.addAll({
      'amount': amount
    });
    result.addAll({
      'date': date.millisecondsSinceEpoch
    });
    result.addAll({
      'categoryId': categoryId
    });
    result.addAll({
      'type': type.toString(),
    });
    if (paymentType != null) {
      result.addAll({
        'paymentType': paymentType
      });
    }

    return result;
  }

  factory TransactionModel.fromMap(Map<String, dynamic> map) {
    return TransactionModel(
      id: map['id'] ?? '',
      userId: map['userId'],
      title: map['title'] ?? '',
      amount: map['amount']?.toDouble() ?? 0.0,
      date: DateTime.fromMillisecondsSinceEpoch(map['date']),
      categoryId: map['categoryId']?.toInt() ?? 0,
      type: TransactionType.values.firstWhere(
        (e) => e.toString() == map['type'],
        orElse: () => TransactionType.despesa,
      ),
      paymentType: map['paymentType'],
    );
  }

  String toJson() => json.encode(toMap());

  factory TransactionModel.fromJson(String source) => TransactionModel.fromMap(json.decode(source));

  @override
  String toString() {
    return 'TransactionModel(id: $id, userId: $userId, title: $title, amount: $amount, date: $date, categoryId: $categoryId, type: $type, paymentType: $paymentType)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is TransactionModel && other.id == id && other.userId == userId && other.title == title && other.amount == amount && other.date == date && other.categoryId == categoryId && other.type == type && other.paymentType == paymentType;
  }

  @override
  int get hashCode {
    return id.hashCode ^ userId.hashCode ^ title.hashCode ^ amount.hashCode ^ date.hashCode ^ categoryId.hashCode ^ type.hashCode ^ paymentType.hashCode;
  }
}
