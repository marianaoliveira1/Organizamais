// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

import 'package:organizamais/controller/auth_controller.dart';

class FixedAccount {
  final String? id;
  final String? userId;
  final String title;
  final String value;
  final int category;
  final String paymentDay;
  final String? paymentType;

  FixedAccount({
    this.id,
    this.userId,
    required this.title,
    required this.value,
    required this.category,
    required this.paymentDay,
    required this.paymentType,
  });

  FixedAccount copyWith({
    String? id,
    String? userId,
    String? title,
    String? value,
    int? category,
    String? paymentDay,
    String? paymentType,
  }) {
    return FixedAccount(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      value: value ?? this.value,
      category: category ?? this.category,
      paymentDay: paymentDay ?? this.paymentDay,
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

    return result;
  }

  factory FixedAccount.fromMap(Map<String, dynamic> map) {
    return FixedAccount(
      id: map['id'],
      userId: map['userId'],
      title: map['title'] ?? '',
      value: map['value'] ?? '',
      category: map['category']?.toInt() ?? 0,
      paymentDay: map['paymentDay'] ?? '',
      paymentType: map['paymentType'],
    );
  }

  String toJson() => json.encode(toMap());

  factory FixedAccount.fromJson(String source) => FixedAccount.fromMap(json.decode(source));

  @override
  String toString() {
    return 'FixedAccount(id: $id, userId: $userId, title: $title, value: $value, category: $category, paymentDay: $paymentDay, paymentType: $paymentType)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is FixedAccount && other.id == id && other.userId == userId && other.title == title && other.value == value && other.category == category && other.paymentDay == paymentDay && other.paymentType == paymentType;
  }

  @override
  int get hashCode {
    return id.hashCode ^ userId.hashCode ^ title.hashCode ^ value.hashCode ^ category.hashCode ^ paymentDay.hashCode ^ paymentType.hashCode;
  }
}

class FixedAccountsController extends GetxController {
  var fixedAccounts = <FixedAccount>[].obs;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? fixedAccountsStream;

  @override
  void onInit() {
    super.onInit();
    getFixedAccounts();
  }

  void getFixedAccounts() {
    fixedAccountsStream = FirebaseFirestore.instance
        .collection('fixedAccounts')
        .where(
          'userId',
          isEqualTo: Get.find<AuthController>().firebaseUser.value?.uid,
        )
        .snapshots()
        .listen((snapshot) {
      fixedAccounts.value = snapshot.docs
          .map(
            (e) => FixedAccount.fromMap(e.data()).copyWith(id: e.id),
          )
          .toList();
    });
  }

  Future<void> addFixedAccount(FixedAccount fixedAccount) async {
    var fixedAccountWithUserId = fixedAccount.copyWith(userId: Get.find<AuthController>().firebaseUser.value?.uid);
    await FirebaseFirestore.instance.collection('fixedAccounts').add(fixedAccountWithUserId.toMap());
    Get.snackbar('Sucesso', 'Conta fixa adicionada com sucesso');
  }

  Future<void> updateFixedAccount(FixedAccount fixedAccount) async {
    if (fixedAccount.id == null) return;
    await FirebaseFirestore.instance.collection('fixedAccounts').doc(fixedAccount.id).update(fixedAccount.toMap());
    Get.snackbar('Sucesso', 'Conta fixa atualizada com sucesso');
  }

  Future<void> deleteFixedAccount(String id) async {
    await FirebaseFirestore.instance.collection('fixedAccounts').doc(id).delete();
    Get.snackbar('Sucesso', 'Conta fixa removida com sucesso');
  }
}
