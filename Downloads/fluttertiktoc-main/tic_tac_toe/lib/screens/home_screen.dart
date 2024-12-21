import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tic_tac_toe/screens/search_transactions_screen.dart';
import '../models/AppTransaction.dart';
import '../widgets/balance_card.dart';
import '../widgets/transaction_item.dart';
import 'add_transaction_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool isLoading = false;

  Stream<List<AppTransaction>> getTransactionsStream() {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      print("No user is currently logged in.");
      return const Stream.empty();
    }

    print("Fetching transactions for user: ${user.uid}");

    return FirebaseFirestore.instance
        .collection('transactions')
        .where('userId', isEqualTo: user.uid)
        .snapshots()
        .map((snapshot) {
      print("Transaction documents fetched: ${snapshot.docs.length}");

      return snapshot.docs.map((doc) {
        final data = doc.data();
        print("Document data for ID ${doc.id}: $data");

        try {
          // Pass the document ID to `fromFirestore` factory method
          return AppTransaction.fromFirestore(data, doc.id); // Pass doc.id here
        } catch (e) {
          print("Error parsing document ${doc.id}: $e");
          throw Exception("Invalid transaction data in document ${doc.id}: $e");
        }
      }).toList();
    });
  }

  void _editTransaction(AppTransaction transaction) {
    final categoryController =
        TextEditingController(text: transaction.category);
    final amountController =
        TextEditingController(text: transaction.amount.toString());
    final noteController = TextEditingController(text: transaction.note);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Transaction'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: categoryController,
                decoration: const InputDecoration(labelText: 'Category'),
              ),
              TextField(
                controller: amountController,
                decoration: const InputDecoration(labelText: 'Amount'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: noteController,
                decoration: const InputDecoration(labelText: 'Note'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                try {
                  final updatedTransaction = {
                    'category': categoryController.text,
                    'amount': double.parse(amountController.text),
                    'note': noteController.text,
                  };

                  await FirebaseFirestore.instance
                      .collection('transactions')
                      .doc(transaction.docId) // Use the document ID to update
                      .update(updatedTransaction);

                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Transaction updated successfully!')),
                  );
                } catch (e) {
                  print('Error updating transaction: $e');
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Failed to update transaction.')),
                  );
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _deleteTransaction(String id) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      print("No authenticated user found.");
      return;
    }

    print("Current user ID: ${user.uid}");
    print("Attempting to delete transaction with ID: $id");

    try {
      await FirebaseFirestore.instance
          .collection('transactions')
          .doc(id)
          .delete()
          .then((_) => print('Transaction deleted'))
          .catchError((error) => print('Error deleting transaction: $error'));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Transaction deleted successfully!')),
      );
    } catch (e) {
      print('Error deleting transaction: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to delete transaction.')),
      );
    }
  }

  void _addTransaction(String category, String note, double amount,
      DateTime date, bool isIncome) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) return;

    final adjustedAmount = isIncome ? amount : -amount;

    final transaction = {
      'category': category,
      'note': note,
      'amount': adjustedAmount,
      'date': date.toIso8601String(),
      'userId': user.uid,
    };

    try {
      await FirebaseFirestore.instance
          .collection('transactions')
          .add(transaction);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Transaction ajoutée avec succès !')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors de l\'ajout : $e')),
      );
    }
  }

  Future<void> _signOut() async {
    setState(() {
      isLoading = true;
    });

    try {
      await FirebaseAuth.instance.signOut();
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/');
      }
    } catch (e) {
      print("Sign-out error: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors de la déconnexion : $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false; // Stop loading indicator
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacementNamed(context, '/');
      });
      return const Scaffold(); // Return an empty screen temporarily
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestion des Dépenses'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _signOut, // Sign-out button
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : StreamBuilder<List<AppTransaction>>(
              stream: getTransactionsStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  print('StreamBuilder Error: ${snapshot.error}');
                  return Center(
                    child: Text(
                        'Erreur de récupération des données : ${snapshot.error}'),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                    child: Text('Aucune transaction disponible.'),
                  );
                }

                final transactions = snapshot.data!;

                return Column(
                  children: [
                    BalanceCard(transactions: transactions),
                    Expanded(
                      child: ListView.builder(
                        itemCount: transactions.length,
                        itemBuilder: (context, index) {
                          final transaction = transactions[index];
                          return TransactionItem(
                            transaction: transaction,
                            onEdit: (updatedTransaction) {
                              _editTransaction(updatedTransaction);
                            },
                            onDelete: (transactionId) {
                              _deleteTransaction(transactionId);
                            },
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
      floatingActionButton: Stack(
        children: [
          // Search Button (Bottom Left)
          Align(
            alignment: Alignment.bottomLeft, // Correct alignment for the left
            child: Padding(
              padding: const EdgeInsets.only(
                  left: 42, bottom: 16.0), // Mirror padding
              child: FloatingActionButton(
                heroTag: 'searchButton',
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const SearchTransactionsScreen(),
                    ),
                  );
                },
                backgroundColor:
                    const Color.fromARGB(255, 211, 112, 229), // Match the style
                child: const Icon(Icons.search),
              ),
            ),
          ),
          // Add Button (Bottom Right)
          Align(
            alignment: Alignment.bottomRight, // Correct alignment for the right
            child: Padding(
              padding: const EdgeInsets.only(
                  right: 16.0, bottom: 16.0), // Mirror padding
              child: FloatingActionButton(
                heroTag: 'addButton',
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => AddTransactionScreen(
                        onAddTransaction: _addTransaction,
                      ),
                    ),
                  );
                },
                backgroundColor:
                    const Color.fromARGB(255, 242, 144, 64), // Match the style
                child: const Icon(Icons.add),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
