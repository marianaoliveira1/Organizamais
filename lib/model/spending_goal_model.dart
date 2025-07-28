class SpendingGoalModel {
  final String? id;
  final String name;
  final double limitValue;
  final int categoryId;
  final int month;
  final int year;
  final String? userId;
  final DateTime createdAt;
  final bool isActive;

  SpendingGoalModel({
    this.id,
    required this.name,
    required this.limitValue,
    required this.categoryId,
    required this.month,
    required this.year,
    this.userId,
    DateTime? createdAt,
    this.isActive = true,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'limitValue': limitValue,
      'categoryId': categoryId,
      'month': month,
      'year': year,
      'userId': userId,
      'createdAt': createdAt.toIso8601String(),
      'isActive': isActive,
    };
  }

  factory SpendingGoalModel.fromMap(Map<String, dynamic> map) {
    return SpendingGoalModel(
      id: map['id'],
      name: map['name'] ?? '',
      limitValue: (map['limitValue'] ?? 0.0).toDouble(),
      categoryId: map['categoryId'] ?? 0,
      month: map['month'] ?? DateTime.now().month,
      year: map['year'] ?? DateTime.now().year,
      userId: map['userId'],
      createdAt: map['createdAt'] != null 
          ? DateTime.parse(map['createdAt'])
          : DateTime.now(),
      isActive: map['isActive'] ?? true,
    );
  }

  SpendingGoalModel copyWith({
    String? id,
    String? name,
    double? limitValue,
    int? categoryId,
    int? month,
    int? year,
    String? userId,
    DateTime? createdAt,
    bool? isActive,
  }) {
    return SpendingGoalModel(
      id: id ?? this.id,
      name: name ?? this.name,
      limitValue: limitValue ?? this.limitValue,
      categoryId: categoryId ?? this.categoryId,
      month: month ?? this.month,
      year: year ?? this.year,
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
      isActive: isActive ?? this.isActive,
    );
  }

  @override
  String toString() {
    return 'SpendingGoalModel(id: $id, name: $name, limitValue: $limitValue, categoryId: $categoryId, month: $month, year: $year, isActive: $isActive)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SpendingGoalModel &&
        other.id == id &&
        other.name == name &&
        other.limitValue == limitValue &&
        other.categoryId == categoryId &&
        other.month == month &&
        other.year == year &&
        other.userId == userId &&
        other.isActive == isActive;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        name.hashCode ^
        limitValue.hashCode ^
        categoryId.hashCode ^
        month.hashCode ^
        year.hashCode ^
        userId.hashCode ^
        isActive.hashCode;
  }
} 