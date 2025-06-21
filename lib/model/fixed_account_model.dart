import 'dart:convert';

class FixedAccountModel {
  final String? id;
  final String? userId;
  final String title;
  final String value;
  final int category;
  final String paymentDay;
  final String? paymentType;
  final int? startMonth;
  final int? startYear;
  final DateTime? deactivatedAt;

  FixedAccountModel({
    this.id,
    this.userId,
    required this.title,
    required this.value,
    required this.category,
    required this.paymentDay,
    required this.paymentType,
    this.startMonth,
    this.startYear,
    this.deactivatedAt,
  });

  FixedAccountModel copyWith({
    String? id,
    String? userId,
    String? title,
    String? value,
    int? category,
    String? paymentDay,
    String? paymentType,
    int? startMonth,
    int? startYear,
    DateTime? deactivatedAt,
  }) {
    return FixedAccountModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      value: value ?? this.value,
      category: category ?? this.category,
      paymentDay: paymentDay ?? this.paymentDay,
      paymentType: paymentType ?? this.paymentType,
      startMonth: startMonth ?? this.startMonth,
      startYear: startYear ?? this.startYear,
      deactivatedAt: deactivatedAt ?? this.deactivatedAt,
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
    result.addAll({
      'category': category
    });
    result.addAll({
      'paymentDay': paymentDay
    });
    if (paymentType != null) {
      result.addAll({
        'paymentType': paymentType
      });
    }
    if (startMonth != null) {
      result.addAll({
        'startMonth': startMonth
      });
    }
    if (startYear != null) {
      result.addAll({
        'startYear': startYear
      });
    }
    if (deactivatedAt != null) {
      result.addAll({
        'deactivatedAt': deactivatedAt!.toIso8601String()
      });
    }

    return result;
  }

  factory FixedAccountModel.fromMap(Map<String, dynamic> map) {
    return FixedAccountModel(
      id: map['id'],
      userId: map['userId'],
      title: map['title'] ?? '',
      value: map['value'] ?? '',
      category: map['category']?.toInt() ?? 0,
      paymentDay: map['paymentDay'] ?? '',
      paymentType: map['paymentType'],
      startMonth: map['startMonth']?.toInt(),
      startYear: map['startYear']?.toInt(),
      deactivatedAt: map['deactivatedAt'] != null ? DateTime.parse(map['deactivatedAt']) : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory FixedAccountModel.fromJson(String source) => FixedAccountModel.fromMap(json.decode(source));

  @override
  String toString() {
    return 'FixedAccount(id: $id, userId: $userId, title: $title, value: $value, category: $category, paymentDay: $paymentDay, paymentType: $paymentType, startMonth: $startMonth, startYear: $startYear, deactivatedAt: $deactivatedAt)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is FixedAccountModel && other.id == id && other.userId == userId && other.title == title && other.value == value && other.category == category && other.paymentDay == paymentDay && other.paymentType == paymentType && other.startMonth == startMonth && other.startYear == startYear && other.deactivatedAt == deactivatedAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^ userId.hashCode ^ title.hashCode ^ value.hashCode ^ category.hashCode ^ paymentDay.hashCode ^ paymentType.hashCode ^ startMonth.hashCode ^ startYear.hashCode ^ deactivatedAt.hashCode;
  }
}
