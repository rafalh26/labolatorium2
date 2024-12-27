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
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

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
