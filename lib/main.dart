import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // jika pakai Riverpod
import 'app/router.dart';

void main() {
  runApp(
    // Jika menggunakan Riverpod
    const ProviderScope(child: MyApp()),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'AI Offline ChatBot',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      routerConfig: AppRouter.router, // Routing diatur di app/router.dart
    );
  }
}
