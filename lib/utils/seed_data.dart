import 'package:flutter/material.dart';
import '../repositories/shopping_repository.dart';

class SeedDataScreen extends StatefulWidget {
  const SeedDataScreen({super.key});

  @override
  State<SeedDataScreen> createState() => _SeedDataScreenState();
}

class _SeedDataScreenState extends State<SeedDataScreen> {
  bool _isSeeding = false;
  String _message = '';

  Future<void> _seedData() async {
    setState(() {
      _isSeeding = true;
      _message = 'Seeding data...';
    });

    try {
      final repository = ShoppingRepository();
      await repository.seedData();
      setState(() {
        _message = 'Data seeded successfully!';
      });
    } catch (e) {
      setState(() {
        _message = 'Error seeding data: $e';
      });
    } finally {
      setState(() {
        _isSeeding = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Seed Data'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_isSeeding)
              const CircularProgressIndicator()
            else
              ElevatedButton(
                onPressed: _seedData,
                child: const Text('Seed Firestore Data'),
              ),
            const SizedBox(height: 20),
            Text(
              _message,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
} 