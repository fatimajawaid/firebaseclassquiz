import 'package:cloud_firestore/cloud_firestore.dart' as firestore;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/transaction.dart';

// Add a provider for the Firestore instance
final firestoreProvider = Provider((ref) => firestore.FirebaseFirestore.instance);

final transactionProvider = StreamProvider<List<Transaction>>((ref) {
  final firestore = ref.watch(firestoreProvider);
  return firestore
      .collection('transactions')
      .orderBy('date', descending: true)
      .snapshots()
      .map((snapshot) {
        print('Received ${snapshot.docs.length} transactions from Firestore'); // Debug print
        return snapshot.docs.map((doc) {
          print('Processing transaction: ${doc.data()['title']}'); // Debug print
          return Transaction.fromFirestore(doc);
        }).toList();
      });
});

final transactionRepositoryProvider = Provider((ref) => TransactionRepository(ref));

class TransactionRepository {
  final ProviderRef _ref;
  late final firestore.FirebaseFirestore _firestore;

  TransactionRepository(this._ref) {
    _firestore = _ref.read(firestoreProvider);
  }

  Future<void> addTransaction({
    required String title,
    required double amount,
    required String type,
    DateTime? date,
    String? imageUrl,
  }) async {
    print('Adding transaction to Firestore: $title'); // Debug print
    try {
      await _firestore.collection('transactions').add({
        'title': title,
        'amount': amount,
        'type': type,
        'date': firestore.Timestamp.fromDate(date ?? DateTime.now()),
        'imageUrl': imageUrl,
      });
      print('Successfully added transaction to Firestore: $title'); // Debug print
    } catch (e) {
      print('Error adding transaction to Firestore: $e'); // Debug print
      rethrow;
    }
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