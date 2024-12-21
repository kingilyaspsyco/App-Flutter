import 'package:cloud_firestore/cloud_firestore.dart';

class AppTransaction {
  String docId;
  final String category;
  final String note;
  final double amount;
  final DateTime date;
  final bool isIncome; // Include isIncome field
  final String userId;

  AppTransaction({
    required this.docId,
    required this.category,
    required this.note,
    required this.amount,
    required this.date,
    required this.isIncome,
    required this.userId,
  });

  // Factory method to create an instance from Firestore data
  factory AppTransaction.fromFirestore(
      Map<String, dynamic> data, String documentId) {
    // Safeguard against unexpected data formats
    DateTime parseDate(dynamic date) {
      if (date is Timestamp) {
        return date.toDate();
      } else if (date is String) {
        return DateTime.tryParse(date) ??
            DateTime.now(); // Fallback to current time
      }
      throw Exception("Invalid date format: $date");
    }

    return AppTransaction(
      docId: documentId, // Assign the documentId as docId
      category: data['category'] ?? 'Unknown',
      note: data['note'] ?? '',
      amount: (data['amount'] as num?)?.toDouble() ?? 0.0,
      date: parseDate(data['date']), // Use the helper function
      isIncome: data['isIncome'] ?? false,
      userId: data['userId'] ?? '',
    );
  }
}
