import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/transaction_provider.dart';
import 'package:intl/intl.dart';
import '../models/transaction.dart';
import 'package:cloud_firestore/cloud_firestore.dart' as firestore;

class TransactionScreen extends ConsumerStatefulWidget {
  const TransactionScreen({super.key});

  @override
  ConsumerState<TransactionScreen> createState() => _TransactionScreenState();
}

class _TransactionScreenState extends ConsumerState<TransactionScreen> {
  int _currentTransactionIndex = 0;

  final List<Map<String, dynamic>> sampleTransactions = [
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

  void _addNextTransaction() async {
    if (_currentTransactionIndex >= sampleTransactions.length) {
      // Show a snackbar when all transactions have been added
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('All sample transactions have been added!'),
            duration: Duration(seconds: 2),
          ),
        );
      }
      return;
    }

    final transaction = sampleTransactions[_currentTransactionIndex];
    final now = DateTime.now();
    final date = now.subtract(Duration(days: transaction['daysAgo'] as int));

    final repository = ref.read(transactionRepositoryProvider);
    await repository.addTransaction(
      title: transaction['title'] as String,
      amount: transaction['amount'] as double,
      type: transaction['type'] as String,
      imageUrl: null,
    );

    setState(() {
      _currentTransactionIndex++;
    });

    // Show which transaction was added
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Added ${transaction['title']}'),
          duration: const Duration(seconds: 1),
        ),
      );
    }
  }

  Future<void> _clearTransactions() async {
    final collection = firestore.FirebaseFirestore.instance.collection('transactions');
    final snapshots = await collection.get();
    final batch = firestore.FirebaseFirestore.instance.batch();
    
    for (final doc in snapshots.docs) {
      batch.delete(doc.reference);
    }
    
    await batch.commit();
    
    // Reset the transaction index
    setState(() {
      _currentTransactionIndex = 0;
    });

    // Show confirmation
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('All transactions cleared'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final transactionsAsyncValue = ref.watch(transactionProvider);
    final currencyFormat = NumberFormat.currency(symbol: '\$');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Transactions'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _clearTransactions,
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
                  if (_currentTransactionIndex < sampleTransactions.length)
                    Text(
                      '${_currentTransactionIndex + 1}/${sampleTransactions.length}',
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 16,
                      ),
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
      floatingActionButton: FloatingActionButton(
        onPressed: _addNextTransaction,
        child: const Icon(Icons.add),
      ),
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