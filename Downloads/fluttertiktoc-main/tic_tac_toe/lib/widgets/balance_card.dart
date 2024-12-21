import 'package:flutter/material.dart';
import '../models/AppTransaction.dart';

class BalanceCard extends StatelessWidget {
  final List<AppTransaction> transactions;

  const BalanceCard({super.key, required this.transactions});

double _calculateIncome() {
  return transactions
      .where((t) => t.amount > 0)
      .fold(0.0, (sum, t) => sum + t.amount);
}

double _calculateExpenses() {
  return transactions
      .where((t) => t.amount < 0)
      .fold(0.0, (sum, t) => sum + t.amount.abs());
}

double _calculateTotalBalance() {
  return _calculateIncome() - _calculateExpenses();
}


  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      margin: const EdgeInsets.all(16),
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Colors.purple, Colors.orange],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(15),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Total Balance',
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
            const SizedBox(height: 10),
            Text(
              '\$${_calculateTotalBalance().toStringAsFixed(2)}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 36,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Income',
                      style: TextStyle(color: Colors.white70, fontSize: 16),
                    ),
                    Text(
                      '\$${_calculateIncome().toStringAsFixed(2)}',
                      style: const TextStyle(color: Colors.white, fontSize: 18),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Expenses',
                      style: TextStyle(color: Colors.white70, fontSize: 16),
                    ),
                    Text(
                      '\$${_calculateExpenses().toStringAsFixed(2)}',
                      style: const TextStyle(color: Colors.white, fontSize: 18),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
