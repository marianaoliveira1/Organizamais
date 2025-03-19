class GoalModel {
  final String? id;
  final String name;
  final String value;
  final double currentValue;
  final String date;
  final int categoryId;
  final String? userId;

  GoalModel({
    this.id,
    required this.name,
    required this.value,
    required this.currentValue,
    required this.date,
    required this.categoryId,
    this.userId,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'value': value,
      'currentValue': currentValue,
      'date': date,
      'categoryId': categoryId,
      'userId': userId,
    };
  }

  factory GoalModel.fromMap(Map<String, dynamic> map) {
    return GoalModel(
      id: map['id'],
      name: map['name'],
      value: map['value'],
      currentValue: (map['currentValue'] as num).toDouble(),
      date: map['date'],
      categoryId: map['categoryId'],
      userId: map['userId'],
    );
  }

  GoalModel copyWith({
    String? id,
    String? name,
    String? value,
    double? currentValue,
    String? date,
    int? categoryId,
    String? userId,
  }) {
    return GoalModel(
      id: id ?? this.id,
      name: name ?? this.name,
      value: value ?? this.value,
      currentValue: currentValue ?? this.currentValue,
      date: date ?? this.date,
      categoryId: categoryId ?? this.categoryId,
      userId: userId ?? this.userId,
    );
  }
}
