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
  // Frequency of the fixed account: 'mensal' (default), 'quinzenal', 'semanal'
  final String? frequency;
  // For 'quinzenal': list of two days in month (1-28)
  final List<int>? biweeklyDays;
  // For 'semanal': weekday number (1=Mon .. 7=Sun)
  final int? weeklyWeekday;

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
    this.frequency,
    this.biweeklyDays,
    this.weeklyWeekday,
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
    String? frequency,
    List<int>? biweeklyDays,
    int? weeklyWeekday,
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
      frequency: frequency ?? this.frequency,
      biweeklyDays: biweeklyDays ?? this.biweeklyDays,
      weeklyWeekday: weeklyWeekday ?? this.weeklyWeekday,
    );
  }

  Map<String, dynamic> toMap() {
    final result = <String, dynamic>{};

    if (id != null) {
      result.addAll({'id': id});
    }
    if (userId != null) {
      result.addAll({'userId': userId});
    }
    result.addAll({'title': title});
    result.addAll({'value': value});
    result.addAll({'category': category});
    result.addAll({'paymentDay': paymentDay});
    if (paymentType != null) {
      result.addAll({'paymentType': paymentType});
    }
    if (startMonth != null) {
      result.addAll({'startMonth': startMonth});
    }
    if (startYear != null) {
      result.addAll({'startYear': startYear});
    }
    if (deactivatedAt != null) {
      result.addAll({'deactivatedAt': deactivatedAt!.toIso8601String()});
    }
    if (frequency != null) {
      result.addAll({'frequency': frequency});
    }
    if (biweeklyDays != null) {
      result.addAll({'biweeklyDays': biweeklyDays});
    }
    if (weeklyWeekday != null) {
      result.addAll({'weeklyWeekday': weeklyWeekday});
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
      deactivatedAt: map['deactivatedAt'] != null
          ? DateTime.parse(map['deactivatedAt'])
          : null,
      frequency: map['frequency'],
      biweeklyDays: map['biweeklyDays'] != null
          ? List<int>.from(
              (map['biweeklyDays'] as List).map((e) => (e as num).toInt()))
          : null,
      weeklyWeekday: map['weeklyWeekday']?.toInt(),
    );
  }

  String toJson() => json.encode(toMap());

  factory FixedAccountModel.fromJson(String source) =>
      FixedAccountModel.fromMap(json.decode(source));

  @override
  String toString() {
    return 'FixedAccount(id: $id, userId: $userId, title: $title, value: $value, category: $category, paymentDay: $paymentDay, paymentType: $paymentType, startMonth: $startMonth, startYear: $startYear, deactivatedAt: $deactivatedAt, frequency: $frequency, biweeklyDays: $biweeklyDays, weeklyWeekday: $weeklyWeekday)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is FixedAccountModel &&
        other.id == id &&
        other.userId == userId &&
        other.title == title &&
        other.value == value &&
        other.category == category &&
        other.paymentDay == paymentDay &&
        other.paymentType == paymentType &&
        other.startMonth == startMonth &&
        other.startYear == startYear &&
        other.deactivatedAt == deactivatedAt &&
        other.frequency == frequency &&
        _listEquals(other.biweeklyDays, biweeklyDays) &&
        other.weeklyWeekday == weeklyWeekday;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        userId.hashCode ^
        title.hashCode ^
        value.hashCode ^
        category.hashCode ^
        paymentDay.hashCode ^
        paymentType.hashCode ^
        startMonth.hashCode ^
        startYear.hashCode ^
        deactivatedAt.hashCode ^
        frequency.hashCode ^
        (biweeklyDays == null ? 0 : biweeklyDays.hashCode) ^
        weeklyWeekday.hashCode;
  }

  // Simple list equality to avoid depending on collection package
  static bool _listEquals(List<int>? a, List<int>? b) {
    if (identical(a, b)) return true;
    if (a == null || b == null) return false;
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}
