import 'package:flutter/material.dart';
import '../models/AppTransaction.dart';

class TransactionItem extends StatelessWidget {
  final AppTransaction transaction;
  final Function(AppTransaction) onEdit;
  final Function(String) onDelete;

  const TransactionItem({
    super.key,
    required this.transaction,
    required this.onEdit,
    required this.onDelete,
  });

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'food':
        return Icons.fastfood;
      case 'shopping':
        return Icons.shopping_bag;
      case 'entertainment':
        return Icons.movie;
      case 'travel':
        return Icons.flight;
      default:
        return Icons.category;
    }
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'food':
        return Colors.orange;
      case 'shopping':
        return Colors.purple;
      case 'entertainment':
        return Colors.red;
      case 'travel':
        return Colors.green;
      default:
        return Colors.blueGrey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getCategoryColor(transaction.category),
          child: Icon(
            _getCategoryIcon(transaction.category),
            color: Colors.white,
          ),
        ),
        title: Text(
          transaction.category,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(transaction.note.isEmpty
            ? transaction.date.toLocal().toString().split(' ')[0]
            : transaction.note),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.blue),
              onPressed: () {
                // Trigger the edit action
                onEdit(transaction);
              },
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () {
                // Trigger the delete action
                onDelete(transaction.docId);
              },
            ),
          ],
        ),
      ),
    );
  }
}