import 'package:cloud_firestore/cloud_firestore.dart';

class TransactionModel {
  String id;
  TransactionType type;
  String description;
  String category;
  String paymentMethod;
  DateTime date;
  bool isFixed;
  bool isInstallment;
  double amount;

  TransactionModel({
    required this.id,
    required this.type,
    required this.description,
    required this.category,
    required this.paymentMethod,
    required this.date,
    required this.isFixed,
    required this.isInstallment,
    required this.amount,
  });

  // Factory constructor for fromFirestore
  factory TransactionModel.fromFirestore(DocumentSnapshot doc) {
    // <--- Corrected
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return TransactionModel(
      id: doc.id,
      type: _getTypeFromString(data['type']),
      description: data['description'],
      category: data['category'],
      paymentMethod: data['paymentMethod'],
      date: (data['date'] as Timestamp).toDate(),
      isFixed: data['isFixed'],
      isInstallment: data['isInstallment'],
      amount: (data['amount'] as num).toDouble(), // Safe cast to double
    );
  }

  static TransactionType _getTypeFromString(String type) {
    return TransactionType.values.firstWhere((e) => e.toString().split('.').last == type);
  }

  Map<String, dynamic> toFirestore() {
    return {
      'type': type.toString().split('.').last,
      'description': description,
      'category': category,
      'paymentMethod': paymentMethod,
      'date': date,
      'isFixed': isFixed,
      'isInstallment': isInstallment,
      'amount': amount,
    };
  }
}

enum TransactionType {
  receita,
  despesa,
  transferencia
}
