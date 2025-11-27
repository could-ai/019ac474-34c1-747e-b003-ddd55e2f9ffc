import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:couldai_user_app/providers/transaction_provider.dart';
import 'package:couldai_user_app/screens/home_screen.dart';
import 'package:couldai_user_app/screens/profile_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => TransactionProvider(),
      child: MaterialApp(
        title: 'Khata - Expense Tracker',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
          useMaterial3: true,
          fontFamily: 'Inter',
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.white,
            elevation: 1,
            shadowColor: Colors.black26,
            titleTextStyle: TextStyle(
              color: Colors.black87,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
            iconTheme: IconThemeData(color: Colors.black87),
          ),
          scaffoldBackgroundColor: const Color(0xFFF7F9FC),
          cardTheme: CardTheme(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
              side: BorderSide(color: Colors.grey.shade200),
            ),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.indigo,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),
        debugShowCheckedModeBanner: false,
        initialRoute: '/',
        routes: {
          '/': (context) => const HomeScreen(),
          ProfileScreen.routeName: (context) => const ProfileScreen(),
        },
      ),
    );
  }
}
