import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:couldai_user_app/models/transaction_model.dart' as model;

class TransactionProvider with ChangeNotifier {
  final List<String> _members = ['Bibash', 'Sandesh', 'Janak', 'Ranjit'];
  List<model.Transaction> _transactions = [];
  Map<String, Map<String, double>> _balances = {};

  List<String> get members => _members;
  List<model.Transaction> get transactions => [..._transactions];
  Map<String, Map<String, double>> get balances => _balances;

  TransactionProvider() {
    _initFirestoreListener();
  }

  void _initFirestoreListener() {
    FirebaseFirestore.instance
        .collection('transactions')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .listen((snapshot) {
      _transactions = snapshot.docs.map((doc) {
        return model.Transaction.fromFirestore(doc);
      }).toList();
      
      _calculateBalances();
      notifyListeners();
    }, onError: (error) {
      debugPrint("Error listening to transactions: $error");
    });
  }

  Future<void> addTransaction(String description, String paidBy, double amount, List<String> splitMembers) async {
    try {
      await FirebaseFirestore.instance.collection('transactions').add({
        'description': description,
        'paidBy': paidBy,
        'amount': amount,
        'splitMembers': splitMembers,
        'timestamp': FieldValue.serverTimestamp(),
      });
      // No need to manually update _transactions or notifyListeners, 
      // the snapshot listener will handle it automatically.
    } catch (e) {
      debugPrint("Error adding transaction: $e");
      rethrow;
    }
  }

  Future<void> deleteTransaction(String id) async {
    try {
      await FirebaseFirestore.instance.collection('transactions').doc(id).delete();
    } catch (e) {
      debugPrint("Error deleting transaction: $e");
      rethrow;
    }
  }

  void _calculateBalances() {
    Map<String, Map<String, double>> newBalances = {};
    for (var payer in _members) {
      newBalances[payer] = {};
      for (var debtor in _members) {
        if (payer != debtor) {
          newBalances[payer]![debtor] = 0;
        }
      }
    }

    for (var t in _transactions) {
      if (t.amount > 0 && t.splitMembers.isNotEmpty) {
        final share = t.amount / t.splitMembers.length;
        for (var debtor in t.splitMembers) {
          if (debtor != t.paidBy) {
            newBalances[t.paidBy]![debtor] = (newBalances[t.paidBy]![debtor] ?? 0) + share;
          }
        }
      }
    }
    _balances = newBalances;
  }

  double getNetOwedAmount(String memberA, String memberB) {
    final owedToA = _balances[memberA]?[memberB] ?? 0;
    final owedToB = _balances[memberB]?[memberA] ?? 0;
    return owedToA - owedToB;
  }
}
