import 'package:flutter/foundation.dart';

class Transaction {
  final String id;
  final String description;
  final String paidBy;
  final double amount;
  final List<String> splitMembers;
  final DateTime timestamp;

  Transaction({
    required this.id,
    required this.description,
    required this.paidBy,
    required this.amount,
    required this.splitMembers,
    required this.timestamp,
  });
}
