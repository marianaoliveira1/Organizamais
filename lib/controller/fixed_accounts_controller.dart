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

  FixedAccount({
    this.id,
    this.userId,
    required this.title,
    required this.value,
    required this.category,
    required this.paymentDay,
  });

  FixedAccount copyWith({
    String? id,
    String? userId,
    String? title,
    String? value,
    int? category,
    String? paymentDay,
  }) {
    return FixedAccount(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      value: value ?? this.value,
      category: category ?? this.category,
      paymentDay: paymentDay ?? this.paymentDay,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'userId': userId,
      'title': title,
      'value': value,
      'category': category,
      'paymentDay': paymentDay,
    };
  }

  factory FixedAccount.fromMap(Map<String, dynamic> map) {
    return FixedAccount(
      id: map['id'] != null ? map['id'] as String : null,
      userId: map['userId'] != null ? map['userId'] as String : null,
      title: map['title'] as String,
      value: map['value'] as String,
      category: map['category'] as int,
      paymentDay: map['paymentDay'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory FixedAccount.fromJson(String source) => FixedAccount.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'FixedAccount(id: $id, userId: $userId, title: $title, value: $value, category: $category, paymentDay: $paymentDay)';
  }

  @override
  bool operator ==(covariant FixedAccount other) {
    if (identical(this, other)) return true;
  
    return 
      other.id == id &&
      other.userId == userId &&
      other.title == title &&
      other.value == value &&
      other.category == category &&
      other.paymentDay == paymentDay;
  }

  @override
  int get hashCode {
    return id.hashCode ^
      userId.hashCode ^
      title.hashCode ^
      value.hashCode ^
      category.hashCode ^
      paymentDay.hashCode;
  }
}

class FixedAccountsController extends GetxController {
  var fixedAccounts = <FixedAccount>[].obs; 
  late StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? fixedAccountsStream;


  // init sync fixed accounts
  @override
  void onInit() {
    super.onInit();
    getFixedAccounts();
  }

  void getFixedAccounts() {
    fixedAccountsStream = FirebaseFirestore.instance.collection('fixedAccounts')
    .where(
      'userId',
      isEqualTo: Get.find<AuthController>().firebaseUser.value?.uid,
    )
    .snapshots()
    .listen((snapshot) {
      fixedAccounts.value = snapshot.docs.map((e) => FixedAccount.fromMap(e.data())).toList();
    });
  }

  Future<void> addFixedAccount(FixedAccount fixedAccount) async {
    var fixedAccountWithUserId = fixedAccount.copyWith(userId: Get.find<AuthController>().firebaseUser.value?.uid);
     await FirebaseFirestore.instance.collection('fixedAccounts').add(fixedAccountWithUserId.toMap());
    Get.snackbar('Sucesso', 'Conta fixa adicionada com sucesso');
  }

}
