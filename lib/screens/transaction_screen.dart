import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/transaction_provider.dart';
import 'package:intl/intl.dart';
import '../models/transaction.dart';
import 'package:cloud_firestore/cloud_firestore.dart' as firestore;

// Create a StateNotifier to manage the transaction adding state
class TransactionAddingNotifier extends StateNotifier<int> {
  TransactionAddingNotifier() : super(0);
  
  void increment() => state = state + 1;
  void reset() => state = 0;
}

final transactionIndexProvider = StateNotifierProvider<TransactionAddingNotifier, int>((ref) {
  return TransactionAddingNotifier();
});

class TransactionScreen extends ConsumerWidget {
  const TransactionScreen({super.key});

  static final sampleTransactions = [
    {
      'title': 'Shopping',
      'amount': -25.0,
      'type': 'shopping',
      'daysAgo': 0,
    },
    {
      'title': 'Grocery',
      'amount': -16.0,
      'type': 'grocery',
      'daysAgo': 1,
    },
    {
      'title': 'Transport',
      'amount': -52.0,
      'type': 'transport',
      'daysAgo': 1,
    },
    {
      'title': 'Mia Moore',
      'amount': 215.0,
      'type': 'payment',
      'daysAgo': 2,
    },
    {
      'title': 'Johnny Barnett',
      'amount': 152.0,
      'type': 'payment',
      'daysAgo': 2,
    },
    {
      'title': 'Payment',
      'amount': -147.0,
      'type': 'payment',
      'daysAgo': 3,
    },
  ];

  Future<void> _addNextTransaction(WidgetRef ref) async {
    final currentIndex = ref.read(transactionIndexProvider);
    print('Current index before adding: $currentIndex'); // Debug print

    if (currentIndex >= sampleTransactions.length) {
      print('All transactions added'); // Debug print
      return;
    }

    final transaction = sampleTransactions[currentIndex];
    print('Attempting to add transaction: ${transaction['title']} at index $currentIndex'); // Debug print

    final now = DateTime.now();
    final date = now.subtract(Duration(days: transaction['daysAgo'] as int));

    try {
      final repository = ref.read(transactionRepositoryProvider);
      await repository.addTransaction(
        title: transaction['title'] as String,
        amount: transaction['amount'] as double,
        type: transaction['type'] as String,
        date: date,
        imageUrl: null,
      );

      print('Successfully added transaction: ${transaction['title']}'); // Debug print
      
      // Increment the index using the StateNotifier
      ref.read(transactionIndexProvider.notifier).increment();
      print('New index after increment: ${ref.read(transactionIndexProvider)}'); // Debug print
    } catch (e) {
      print('Error adding transaction: $e'); // Debug print
    }
  }

  Future<void> _clearTransactions(WidgetRef ref) async {
    try {
      final collection = firestore.FirebaseFirestore.instance.collection('transactions');
      final snapshots = await collection.get();
      
      print('Clearing ${snapshots.docs.length} transactions'); // Debug print
      
      // Delete each document individually instead of using batch
      for (final doc in snapshots.docs) {
        await doc.reference.delete();
      }
      
      // Reset the index using the StateNotifier
      ref.read(transactionIndexProvider.notifier).reset();
      print('Successfully cleared all transactions and reset index'); // Debug print
    } catch (e) {
      print('Error clearing transactions: $e'); // Debug print
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactionsAsyncValue = ref.watch(transactionProvider);
    final currencyFormat = NumberFormat.currency(symbol: '\$');
    final currentIndex = ref.watch(transactionIndexProvider);

    print('Current index in build: $currentIndex'); // Debug print

    return Scaffold(
      appBar: AppBar(
        title: const Text('Transactions'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _clearTransactions(ref),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        DateFormat('EEEE').format(DateTime.now()),
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        '${DateFormat('d').format(DateTime.now())} ${DateFormat('MMM').format(DateTime.now())}',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  transactionsAsyncValue.when(
                    data: (List<Transaction> transactions) {
                      final total = transactions.fold<double>(
                        0,
                        (sum, Transaction transaction) => sum + transaction.amount,
                      );
                      return Text(
                        currencyFormat.format(total),
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      );
                    },
                    loading: () => const CircularProgressIndicator(),
                    error: (_, __) => const Text('Error loading balance'),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Transactions',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Added ${currentIndex}/${sampleTransactions.length}',
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Expanded(
                child: transactionsAsyncValue.when(
                  data: (transactions) => ListView.builder(
                    itemCount: transactions.length,
                    itemBuilder: (context, index) {
                      final transaction = transactions[index];
                      final repository = ref.read(transactionRepositoryProvider);
                      final formattedDate = repository.formatDate(transaction.date);
                      
                      return ListTile(
                        leading: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: transaction.imageUrl != null
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(
                                    transaction.imageUrl!,
                                    fit: BoxFit.cover,
                                  ),
                                )
                              : Icon(
                                  _getIconForType(transaction.type),
                                  color: Colors.blue,
                                ),
                        ),
                        title: Text(
                          transaction.title,
                          style: const TextStyle(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        subtitle: Text(formattedDate),
                        trailing: Text(
                          '${transaction.amount >= 0 ? '+' : '-'} ${currencyFormat.format(transaction.amount.abs())}',
                          style: TextStyle(
                            color: transaction.amount >= 0 ? Colors.green : Colors.red,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      );
                    },
                  ),
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (_, __) => const Center(child: Text('Error loading transactions')),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: currentIndex < sampleTransactions.length
          ? FloatingActionButton(
              onPressed: () => _addNextTransaction(ref),
              child: const Icon(Icons.add),
            )
          : null,
    );
  }

  IconData _getIconForType(String type) {
    switch (type.toLowerCase()) {
      case 'shopping':
        return Icons.shopping_bag;
      case 'grocery':
        return Icons.local_grocery_store;
      case 'transport':
        return Icons.directions_car;
      case 'payment':
        return Icons.payment;
      default:
        return Icons.attach_money;
    }
  }
} 