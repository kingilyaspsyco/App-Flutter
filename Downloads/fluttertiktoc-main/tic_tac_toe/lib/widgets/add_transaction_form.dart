import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AddTransactionForm extends StatefulWidget {
  final Function(String, String, double, DateTime, bool) onAddTransaction;

  const AddTransactionForm({super.key, required this.onAddTransaction});

  @override
  _AddTransactionFormState createState() => _AddTransactionFormState();
}

class _AddTransactionFormState extends State<AddTransactionForm> {
  final _categoryController = TextEditingController();
  final _noteController = TextEditingController();
  final _amountController = TextEditingController();
  bool _isIncome = true;

  void _submitData() async {
    final category = _categoryController.text.trim();
    final note = _noteController.text.trim();
    final amount = double.tryParse(_amountController.text);

    if (category.isEmpty || amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez entrer des données valides.')),
      );
      return;
    }

    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Utilisateur non connecté.')),
      );
      return;
    }

    print('Current User ID: ${user.uid}'); // Log user ID for debugging

    try {
      await FirebaseFirestore.instance.collection('transactions').add({
        'category': category,
        'note': note,
        'amount': _isIncome ? amount : -amount,
        'date': Timestamp.fromDate(DateTime.now()),
        'isIncome': _isIncome,
        'userId': user.uid, // Add the userId field
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Transaction ajoutée avec succès !')),
      );

      Navigator.of(context).pop();
    } catch (error) {
      print('Error adding transaction: $error'); // Log error for debugging
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur : $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _categoryController,
            decoration: const InputDecoration(labelText: 'Catégorie'),
          ),
          TextField(
            controller: _noteController,
            decoration: const InputDecoration(labelText: 'Note (optionnel)'),
          ),
          TextField(
            controller: _amountController,
            decoration: const InputDecoration(labelText: 'Montant'),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: RadioListTile<bool>(
                  title: const Text('Income'),
                  value: true,
                  groupValue: _isIncome,
                  onChanged: (value) {
                    setState(() {
                      _isIncome = value!;
                    });
                  },
                ),
              ),
              Expanded(
                child: RadioListTile<bool>(
                  title: const Text('Expense'),
                  value: false,
                  groupValue: _isIncome,
                  onChanged: (value) {
                    setState(() {
                      _isIncome = value!;
                    });
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _submitData,
            child: const Text('Ajouter'),
          ),
        ],
      ),
    );
  }
}
