import 'dart:convert';

enum TransactionType {
  receita,
  despesa,
  transferencia
}

class TransactionModel {
  final String? id;
  final String? userId;
  final String title;
  final String value;
  final String paymentDay;
  final int category;
  final TransactionType type;
  final String? paymentType;

  TransactionModel({
    this.id,
    this.userId,
    required this.title,
    required this.value,
    required this.paymentDay,
    required this.category,
    required this.type,
    this.paymentType,
  });

  TransactionModel copyWith({
    String? id,
    String? userId,
    String? title,
    String? value,
    String? paymentDay,
    int? category,
    TransactionType? type,
    String? paymentType,
  }) {
    return TransactionModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      value: value ?? this.value,
      paymentDay: paymentDay ?? this.paymentDay,
      category: category ?? this.category,
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
      'value': value
    });
    result.addAll({
      'paymentDay': paymentDay
    });
    result.addAll({
      'category': category
    });
    result.addAll({
      'type': type.toString()
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
      value: map['value'] ?? '',
      paymentDay: map['paymentDay'] ?? '',
      category: map['category']?.toInt() ?? 0,
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
    return 'TransactionModel(id: $id, userId: $userId, title: $title, value: $value, paymentDay: $paymentDay, category: $category, type: $type, paymentType: $paymentType)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is TransactionModel && other.id == id && other.userId == userId && other.title == title && other.value == value && other.paymentDay == paymentDay && other.category == category && other.type == type && other.paymentType == paymentType;
  }

  @override
  int get hashCode {
    return id.hashCode ^ userId.hashCode ^ title.hashCode ^ value.hashCode ^ paymentDay.hashCode ^ category.hashCode ^ type.hashCode ^ paymentType.hashCode;
  }
}
