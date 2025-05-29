import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'firebase_options.dart';
import 'screens/shopping_screen.dart';
import 'bloc/shopping_bloc.dart';
import 'repositories/shopping_repository.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    print('Firebase initialization error: $e');
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ShoppingBloc(ShoppingRepository()),
      child: MaterialApp(
        title: 'Shopping App',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFE1BEE7)),
          useMaterial3: true,
        ),
        home: const ShoppingScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
} 