import 'package:cloud_firestore/cloud_firestore.dart';

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

  // Factory constructor to create a Transaction from a Firestore DocumentSnapshot
  factory Transaction.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Transaction(
      id: doc.id,
      description: data['description'] ?? '',
      paidBy: data['paidBy'] ?? '',
      amount: (data['amount'] ?? 0).toDouble(),
      splitMembers: List<String>.from(data['splitMembers'] ?? []),
      timestamp: (data['timestamp'] as Timestamp).toDate(),
    );
  }

  // Method to convert Transaction to a Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'description': description,
      'paidBy': paidBy,
      'amount': amount,
      'splitMembers': splitMembers,
      'timestamp': Timestamp.fromDate(timestamp),
    };
  }
}
