import 'dart:convert';

enum TransactionType {
  receita,
  despesa,
  transferencia;

  String toJson() => name;

  static TransactionType fromJson(String value) => TransactionType.values.firstWhere(
        (e) => e.name == value,
        orElse: () => throw ArgumentError('Tipo de transação inválido: $value'),
      );
}

class TransactionModel {
  final String? id;
  final String? userId;
  final String title;
  final String value;
  final String? paymentDay;
  final int? category;
  final String? iconPath;
  final TransactionType type;
  final String? paymentType;
  TransactionModel({
    this.id,
    this.userId,
    required this.title,
    required this.value,
    this.paymentDay,
    this.category,
    this.iconPath,
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
    String? iconPath,
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
      iconPath: iconPath ?? this.iconPath,
      type: type ?? this.type,
      paymentType: paymentType ?? this.paymentType,
    );
  }

  Map<String, dynamic> toMap() {
    final result = <String, dynamic>{};

    if (id != null) {
      result.addAll({
        'id': id
      });
    }
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
    if (paymentDay != null) {
      result.addAll({
        'paymentDay': paymentDay
      });
    }
    if (category != null) {
      result.addAll({
        'category': category
      });
    }
    if (iconPath != null) {
      result.addAll({
        'iconPath': iconPath
      });
    }
    result.addAll({
      'type': type.toJson()
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
      id: map['id'],
      userId: map['userId'],
      title: map['title'] ?? '',
      value: map['value'] ?? '',
      paymentDay: map['paymentDay'],
      category: map['category']?.toInt(),
      iconPath: map['iconPath'],
      type: TransactionType.fromJson(map['type']),
      paymentType: map['paymentType'],
    );
  }

  String toJson() => json.encode(toMap());

  factory TransactionModel.fromJson(String source) => TransactionModel.fromMap(json.decode(source));

  @override
  String toString() {
    return 'TransactionModel(id: $id, userId: $userId, title: $title, value: $value, paymentDay: $paymentDay, category: $category, iconPath: $iconPath, type: $type, paymentType: $paymentType)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is TransactionModel && other.id == id && other.userId == userId && other.title == title && other.value == value && other.paymentDay == paymentDay && other.category == category && other.iconPath == iconPath && other.type == type && other.paymentType == paymentType;
  }

  @override
  int get hashCode {
    return id.hashCode ^ userId.hashCode ^ title.hashCode ^ value.hashCode ^ paymentDay.hashCode ^ category.hashCode ^ iconPath.hashCode ^ type.hashCode ^ paymentType.hashCode;
  }
}
