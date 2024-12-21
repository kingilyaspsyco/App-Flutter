import 'package:flutter/material.dart';
import '../widgets/add_transaction_form.dart';

class AddTransactionScreen extends StatelessWidget {
  final Function(String, String, double, DateTime, bool) onAddTransaction;

  const AddTransactionScreen({super.key, required this.onAddTransaction});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ajouter une transaction'),
      ),
      body: AddTransactionForm(
        onAddTransaction: onAddTransaction,
      ),
    );
  }
}
