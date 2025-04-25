import 'package:cloud_firestore/cloud_firestore.dart' as firestore;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/transaction.dart';

final transactionProvider = StreamProvider<List<Transaction>>((ref) {
  return firestore.FirebaseFirestore.instance
      .collection('transactions')
      .orderBy('date', descending: true)
      .snapshots()
      .map((snapshot) => snapshot.docs
          .map((doc) => Transaction.fromFirestore(doc))
          .toList());
});

final transactionRepositoryProvider = Provider((ref) => TransactionRepository());

class TransactionRepository {
  final _firestore = firestore.FirebaseFirestore.instance;

  Future<void> addTransaction({
    required String title,
    required double amount,
    required String type,
    String? imageUrl,
  }) async {
    await _firestore.collection('transactions').add({
      'title': title,
      'amount': amount,
      'date': firestore.Timestamp.now(),
      'type': type,
      'imageUrl': imageUrl,
    });
  }

  String formatDate(DateTime date) {
    final now = DateTime.now();
    final yesterday = DateTime(now.year, now.month, now.day - 1);
    final transactionDate = DateTime(date.year, date.month, date.day);

    if (transactionDate == DateTime(now.year, now.month, now.day)) {
      return 'Today';
    } else if (transactionDate == yesterday) {
      return 'Yesterday';
    } else {
      return '${date.day} ${_getMonthName(date.month)} ${date.year}';
    }
  }

  String _getMonthName(int month) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return months[month - 1];
  }
} 