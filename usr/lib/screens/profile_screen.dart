import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:couldai_user_app/providers/transaction_provider.dart';

class ProfileScreen extends StatelessWidget {
  static const routeName = '/profile';

  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final member = ModalRoute.of(context)!.settings.arguments as String;
    final transactionProvider = Provider.of<TransactionProvider>(context);
    final members = transactionProvider.members;

    double totalOwedToMember = 0;
    final List<Widget> balanceWidgets = [];

    for (var otherMember in members) {
      if (member == otherMember) continue;

      final netAmount = transactionProvider.getNetOwedAmount(member, otherMember);
      totalOwedToMember += netAmount;

      String statusText;
      Color statusColor;
      String amountText;

      if (netAmount > 0.01) {
        statusText = '$otherMember owes you';
        statusColor = Colors.green;
        amountText = '₹${netAmount.toStringAsFixed(2)}';
      } else if (netAmount < -0.01) {
        statusText = 'You owe $otherMember';
        statusColor = Colors.red;
        amountText = '₹${(-netAmount).toStringAsFixed(2)}';
      } else {
        continue; // Don't show balanced members
      }

      balanceWidgets.add(
        Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          child: ListTile(
            title: Text(otherMember, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(statusText, style: TextStyle(color: statusColor)),
            trailing: Text(
              amountText,
              style: TextStyle(color: statusColor, fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        )
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("$member's Profile"),
      ),
      body: Column(
        children: [
          Expanded(
            child: balanceWidgets.isEmpty
                ? const Center(child: Text('All balances are settled!'))
                : ListView(
                    children: balanceWidgets,
                  ),
          ),
          Container(
            padding: const EdgeInsets.all(20),
            width: double.infinity,
            color: Colors.grey[200],
            child: Column(
              children: [
                Text(
                  'TOTAL NET BALANCE',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  '${totalOwedToMember >= 0 ? "Owed to you" : "You owe"}: ₹${totalOwedToMember.abs().toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: totalOwedToMember >= 0 ? Colors.green.shade700 : Colors.red.shade700,
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
