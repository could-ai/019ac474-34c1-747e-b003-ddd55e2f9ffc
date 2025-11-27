import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import 'package:couldai_user_app/providers/transaction_provider.dart';
import 'package:couldai_user_app/screens/profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _amountController = TextEditingController();
  String? _selectedPayer;
  final Map<String, bool> _splitMembers = {};

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final members = Provider.of<TransactionProvider>(context, listen: false).members;
    for (var member in members) {
      _splitMembers[member] = false;
    }
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  void _submitTransaction() {
    if (_formKey.currentState!.validate()) {
      final description = _descriptionController.text;
      final amount = double.tryParse(_amountController.text);
      final payer = _selectedPayer;
      final selectedSplitMembers = _splitMembers.entries
          .where((entry) => entry.value)
          .map((entry) => entry.key)
          .toList();

      if (amount == null ||
          amount <= 0 ||
          payer == null ||
          selectedSplitMembers.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please fill all fields and select at least one split member.'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      Provider.of<TransactionProvider>(context, listen: false)
          .addTransaction(description, payer, amount, selectedSplitMembers);

      // Reset form
      _formKey.currentState!.reset();
      _descriptionController.clear();
      _amountController.clear();
      setState(() {
        _selectedPayer = null;
        _splitMembers.updateAll((key, value) => false);
      });
      FocusScope.of(context).unfocus();
       ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Transaction added successfully!'),
            backgroundColor: Colors.green,
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final transactionProvider = Provider.of<TransactionProvider>(context);
    final members = transactionProvider.members;
    final transactions = transactionProvider.transactions;

    return Scaffold(
      appBar: AppBar(
        title: const Text('KHATA'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Member Icons
            SizedBox(
              height: 80,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: members.length,
                itemBuilder: (ctx, index) {
                  final member = members[index];
                  return GestureDetector(
                    onTap: () => Navigator.of(context).pushNamed(
                      ProfileScreen.routeName,
                      arguments: member,
                    ),
                    child: Container(
                      width: 80,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircleAvatar(
                            radius: 25,
                            child: Text(member[0]),
                          ),
                          const SizedBox(height: 4),
                          Text(member, style: const TextStyle(fontSize: 12), overflow: TextOverflow.ellipsis,),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),

            // Transaction Form
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Record New Transaction', style: Theme.of(context).textTheme.titleLarge),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _descriptionController,
                        decoration: const InputDecoration(labelText: 'Description'),
                        validator: (value) => (value == null || value.isEmpty)
                            ? 'Please enter a description'
                            : null,
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        value: _selectedPayer,
                        decoration: const InputDecoration(labelText: 'Paid By'),
                        items: members
                            .map((m) => DropdownMenuItem(value: m, child: Text(m)))
                            .toList(),
                        onChanged: (value) => setState(() => _selectedPayer = value),
                        validator: (value) =>
                            (value == null) ? 'Please select a payer' : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _amountController,
                        decoration: const InputDecoration(labelText: 'Amount (₹)'),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) return 'Please enter an amount';
                          if (double.tryParse(value) == null || double.parse(value) <= 0) return 'Please enter a valid amount';
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      const Text('Split With', style: TextStyle(fontWeight: FontWeight.bold)),
                      Wrap(
                        spacing: 8.0,
                        children: members.map((member) {
                          return ChoiceChip(
                            label: Text(member),
                            selected: _splitMembers[member]!,
                            onSelected: (selected) {
                              setState(() {
                                _splitMembers[member] = selected;
                              });
                            },
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _submitTransaction,
                          child: const Text('Add Expense'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Recent History
            Text('Recent History', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 10),
            transactions.isEmpty
                ? const Text('No transactions yet.')
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: transactions.length,
                    itemBuilder: (ctx, index) {
                      final tx = transactions[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        child: ListTile(
                          title: Text(tx.description),
                          subtitle: Text('₹${tx.amount.toStringAsFixed(2)} paid by ${tx.paidBy}\nSplit with ${tx.splitMembers.join(", ")} on ${DateFormat.yMMMd().format(tx.timestamp)}'),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () {
                              Provider.of<TransactionProvider>(context, listen: false).deleteTransaction(tx.id);
                               ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Transaction deleted.'),
                                  backgroundColor: Colors.orange,
                                ),
                              );
                            },
                          ),
                        ),
                      );
                    },
                  ),
          ],
        ),
      ),
    );
  }
}
