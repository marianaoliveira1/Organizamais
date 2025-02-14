import 'dart:convert';

class CardsModel {
  final String? id;
  final String? userId;
  final String title;
  final int icon;
  final String limit;
  CardsModel({
    this.id,
    this.userId,
    required this.title,
    required this.icon,
    required this.limit,
  });

  CardsModel copyWith({
    String? id,
    String? userId,
    String? title,
    int? icon,
    String? limit,
  }) {
    return CardsModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      icon: icon ?? this.icon,
      limit: limit ?? this.limit,
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
      'icon': icon
    });
    result.addAll({
      'limit': limit
    });

    return result;
  }

  factory CardsModel.fromMap(Map<String, dynamic> map) {
    return CardsModel(
      id: map['id'],
      userId: map['userId'],
      title: map['title'] ?? '',
      icon: map['icon']?.toInt() ?? 0,
      limit: map['limit'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory CardsModel.fromJson(String source) => CardsModel.fromMap(json.decode(source));

  @override
  String toString() {
    return 'CardsModel(id: $id, userId: $userId, title: $title, icon: $icon, limit: $limit)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is CardsModel && other.id == id && other.userId == userId && other.title == title && other.icon == icon && other.limit == limit;
  }

  @override
  int get hashCode {
    return id.hashCode ^ userId.hashCode ^ title.hashCode ^ icon.hashCode ^ limit.hashCode;
  }
}
