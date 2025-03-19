import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class GoalModel {
  final String? id;
  final String? userId;
  final String name;
  final int categoryId;
  final String categoryName;
  final String categoryIcon;
  final Color categoryColor;
  final double targetAmount;
  final double currentAmount;
  final DateTime targetDate;
  final List<GoalTransaction>? transactions;
  GoalModel({
    this.id,
    this.userId,
    required this.name,
    required this.categoryId,
    required this.categoryName,
    required this.categoryIcon,
    required this.categoryColor,
    required this.targetAmount,
    required this.currentAmount,
    required this.targetDate,
    this.transactions,
  });

  GoalModel copyWith({
    String? id,
    String? userId,
    String? name,
    int? categoryId,
    String? categoryName,
    String? categoryIcon,
    Color? categoryColor,
    double? targetAmount,
    double? currentAmount,
    DateTime? targetDate,
    List<GoalTransaction>? transactions,
  }) {
    return GoalModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      categoryId: categoryId ?? this.categoryId,
      categoryName: categoryName ?? this.categoryName,
      categoryIcon: categoryIcon ?? this.categoryIcon,
      categoryColor: categoryColor ?? this.categoryColor,
      targetAmount: targetAmount ?? this.targetAmount,
      currentAmount: currentAmount ?? this.currentAmount,
      targetDate: targetDate ?? this.targetDate,
      transactions: transactions ?? this.transactions,
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
      'name': name
    });
    result.addAll({
      'categoryId': categoryId
    });
    result.addAll({
      'categoryName': categoryName
    });
    result.addAll({
      'categoryIcon': categoryIcon
    });
    result.addAll({
      'categoryColor': categoryColor.value
    });
    result.addAll({
      'targetAmount': targetAmount
    });
    result.addAll({
      'currentAmount': currentAmount
    });
    result.addAll({
      'targetDate': targetDate.millisecondsSinceEpoch
    });
    if (transactions != null) {
      result.addAll({
        'transactions': transactions!.map((x) => x.toMap()).toList()
      });
    }

    return result;
  }

  factory GoalModel.fromMap(Map<String, dynamic> map) {
    return GoalModel(
      id: map['id'],
      userId: map['userId'],
      name: map['name'] ?? '',
      categoryId: map['categoryId']?.toInt() ?? 0,
      categoryName: map['categoryName'] ?? '',
      categoryIcon: map['categoryIcon'] ?? '',
      categoryColor: Color(map['categoryColor']),
      targetAmount: map['targetAmount']?.toDouble() ?? 0.0,
      currentAmount: map['currentAmount']?.toDouble() ?? 0.0,
      targetDate: DateTime.fromMillisecondsSinceEpoch(map['targetDate']),
      transactions: map['transactions'] != null ? List<GoalTransaction>.from(map['transactions']?.map((x) => GoalTransaction.fromMap(x))) : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory GoalModel.fromJson(String source) => GoalModel.fromMap(json.decode(source));

  @override
  String toString() {
    return 'GoalModel(id: $id, userId: $userId, name: $name, categoryId: $categoryId, categoryName: $categoryName, categoryIcon: $categoryIcon, categoryColor: $categoryColor, targetAmount: $targetAmount, currentAmount: $currentAmount, targetDate: $targetDate, transactions: $transactions)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is GoalModel &&
        other.id == id &&
        other.userId == userId &&
        other.name == name &&
        other.categoryId == categoryId &&
        other.categoryName == categoryName &&
        other.categoryIcon == categoryIcon &&
        other.categoryColor == categoryColor &&
        other.targetAmount == targetAmount &&
        other.currentAmount == currentAmount &&
        other.targetDate == targetDate &&
        listEquals(
          other.transactions,
          transactions,
        );
  }

  @override
  int get hashCode {
    return id.hashCode ^ userId.hashCode ^ name.hashCode ^ categoryId.hashCode ^ categoryName.hashCode ^ categoryIcon.hashCode ^ categoryColor.hashCode ^ targetAmount.hashCode ^ currentAmount.hashCode ^ targetDate.hashCode ^ transactions.hashCode;
  }
}

class GoalTransaction {
  final String? id;
  final double amount;
  final DateTime date;
  final bool isDeposit; // true for deposit, false for withdrawal

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'amount': amount,
      'date': date.millisecondsSinceEpoch,
      'isDeposit': isDeposit,
    };
  }

  GoalTransaction({
    this.id,
    required this.amount,
    required this.date,
    required this.isDeposit,
  });

  factory GoalTransaction.fromJson(Map<String, dynamic> json) {
    return GoalTransaction(
      id: json['id'],
      amount: (json['amount'] ?? 0.0).toDouble(),
      date: (json['date'] as Timestamp).toDate(),
      isDeposit: json['isDeposit'] ?? true,
    );
  }

  factory GoalTransaction.fromMap(Map<String, dynamic> map) {
    return GoalTransaction(
      id: map['id'],
      amount: (map['amount'] ?? 0.0).toDouble(),
      date: DateTime.fromMillisecondsSinceEpoch(map['date']),
      isDeposit: map['isDeposit'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'amount': amount,
      'date': Timestamp.fromDate(date),
      'isDeposit': isDeposit,
    };
  }
}
