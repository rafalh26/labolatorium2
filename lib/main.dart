import 'package:flutter/material.dart';
import 'package:labolatorium2/views/login.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: const BalanceApp(),
    ),
  );
}

class BalanceApp extends StatelessWidget {
  const BalanceApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return MaterialApp(
      title: 'Monthly Balance App',
      theme: themeProvider.themeData,
      home: LoginPage(),
    );
  }
}
