// model/cards_model.dart
class CardsModel {
  final String? id;
  final String name;
  final double? limit;
  final String? iconPath;
  final String? bankName;
  final String? userId;
  final int? closingDay;
  final int? paymentDay;

  CardsModel({
    this.id,
    required this.name,
    this.limit,
    this.iconPath,
    this.bankName,
    this.userId,
    this.closingDay,
    this.paymentDay,
  });

  factory CardsModel.fromMap(Map<String, dynamic> map) {
    return CardsModel(
      name: map['name'] ?? '',
      limit: (map['limit'] ?? 0.0).toDouble(),
      iconPath: map['iconPath'],
      bankName: map['bankName'],
      userId: map['userId'],
      closingDay:
          map['closingDay'] != null ? (map['closingDay'] as num).toInt() : null,
      paymentDay:
          map['paymentDay'] != null ? (map['paymentDay'] as num).toInt() : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'limit': limit,
      'iconPath': iconPath,
      'bankName': bankName,
      'userId': userId,
      'closingDay': closingDay,
      'paymentDay': paymentDay,
    };
  }

  CardsModel copyWith({
    String? id,
    String? name,
    double? limit,
    String? iconPath,
    String? bankName,
    String? userId,
    int? closingDay,
    int? paymentDay,
  }) {
    return CardsModel(
      id: id ?? this.id,
      name: name ?? this.name,
      limit: limit ?? this.limit,
      iconPath: iconPath ?? this.iconPath,
      bankName: bankName ?? this.bankName,
      userId: userId ?? this.userId,
      closingDay: closingDay ?? this.closingDay,
      paymentDay: paymentDay ?? this.paymentDay,
    );
  }
}
