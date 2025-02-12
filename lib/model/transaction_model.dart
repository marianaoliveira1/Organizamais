enum TransactionType {
  receita,
  despesa,
  transferencia
}

class TransactionModel {
  final String id;
  final String description;
  final double amount;
  final DateTime date;
  final String categoryId;
  final TransactionType type;
  final String accountId;
  final bool isRecurring;
  final bool isInstallment;

  TransactionModel({
    required this.id,
    required this.description,
    required this.amount,
    required this.date,
    required this.categoryId,
    required this.type,
    required this.accountId,
    this.isRecurring = false,
    this.isInstallment = false,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'description': description,
        'amount': amount,
        'date': date.toIso8601String(),
        'categoryId': categoryId,
        'type': type.toString(),
        'accountId': accountId,
        'isRecurring': isRecurring,
        'isInstallment': isInstallment,
      };

  factory TransactionModel.fromJson(Map<String, dynamic> json) => TransactionModel(
        id: json['id'],
        description: json['description'],
        amount: json['amount'],
        date: DateTime.parse(json['date']),
        categoryId: json['categoryId'],
        type: TransactionType.values.firstWhere(
          (e) => e.toString() == json['type'],
        ),
        accountId: json['accountId'],
        isRecurring: json['isRecurring'],
        isInstallment: json['isInstallment'],
      );
}
