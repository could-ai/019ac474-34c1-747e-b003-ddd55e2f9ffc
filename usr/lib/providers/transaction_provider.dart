import 'package:flutter/material.dart';
import 'package:couldai_user_app/models/transaction_model.dart';
import 'dart:math';

class TransactionProvider with ChangeNotifier {
  final List<String> _members = ['Bibash', 'Sandesh', 'Janak', 'Ranjit'];
  List<Transaction> _transactions = [];
  Map<String, Map<String, double>> _balances = {};

  List<String> get members => _members;
  List<Transaction> get transactions => [..._transactions];
  Map<String, Map<String, double>> get balances => _balances;

  TransactionProvider() {
    _addInitialData();
    _calculateBalances();
  }

  void _addInitialData() {
    _transactions = [
      Transaction(id: 't1', description: 'Lunch at Restaurant', paidBy: 'Bibash', amount: 1200, splitMembers: ['Bibash', 'Sandesh', 'Janak', 'Ranjit'], timestamp: DateTime.now().subtract(const Duration(days: 1))),
      Transaction(id: 't2', description: 'Movie Tickets', paidBy: 'Sandesh', amount: 800, splitMembers: ['Sandesh', 'Ranjit'], timestamp: DateTime.now().subtract(const Duration(hours: 5))),
      Transaction(id: 't3', description: 'Groceries', paidBy: 'Janak', amount: 1500, splitMembers: ['Janak', 'Bibash'], timestamp: DateTime.now().subtract(const Duration(days: 2))),
    ];
    _transactions.sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }

  void addTransaction(String description, String paidBy, double amount, List<String> splitMembers) {
    final newTransaction = Transaction(
      id: 't${Random().nextInt(1000)}',
      description: description,
      paidBy: paidBy,
      amount: amount,
      splitMembers: splitMembers,
      timestamp: DateTime.now(),
    );
    _transactions.insert(0, newTransaction);
    _calculateBalances();
    notifyListeners();
  }

  void deleteTransaction(String id) {
    _transactions.removeWhere((tx) => tx.id == id);
    _calculateBalances();
    notifyListeners();
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
