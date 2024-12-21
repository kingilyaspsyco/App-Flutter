import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/AppTransaction.dart';

class SearchTransactionsScreen extends StatefulWidget {
  const SearchTransactionsScreen({Key? key}) : super(key: key);

  @override
  State<SearchTransactionsScreen> createState() =>
      _SearchTransactionsScreenState();
}

class _SearchTransactionsScreenState extends State<SearchTransactionsScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<AppTransaction> _allTransactions = [];
  List<AppTransaction> _filteredTransactions = [];

  @override
  void initState() {
    super.initState();
    _fetchTransactions();
    _searchController.addListener(_filterTransactions);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchTransactions() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) return;

    final snapshot = await FirebaseFirestore.instance
        .collection('transactions')
        .where('userId', isEqualTo: user.uid)
        .get();

    setState(() {
      _allTransactions = snapshot.docs
          .map((doc) =>
              AppTransaction.fromFirestore(doc.data(), doc.id)) // Pass doc.id
          .toList();
      _filteredTransactions = _allTransactions;
    });
  }

  void _filterTransactions() {
    final query = _searchController.text.toLowerCase();

    setState(() {
      _filteredTransactions = _allTransactions.where((transaction) {
        return transaction.category.toLowerCase().contains(query) ||
            transaction.note.toLowerCase().contains(query);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search Transactions'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                labelText: 'Search',
                prefixIcon: Icon(Icons.search),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _filteredTransactions.isEmpty
                  ? const Center(child: Text('No transactions found.'))
                  : ListView.builder(
                      itemCount: _filteredTransactions.length,
                      itemBuilder: (context, index) {
                        final transaction = _filteredTransactions[index];
                        return ListTile(
                          title: Text(transaction.category),
                          subtitle: Text(transaction.note),
                          trailing: Text(transaction.amount.toStringAsFixed(2)),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
