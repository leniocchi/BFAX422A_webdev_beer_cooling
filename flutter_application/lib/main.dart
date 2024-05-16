import 'package:flutter/material.dart';
import 'package:openapi/api.dart';
import 'package:provider/provider.dart';
import 'homepage.dart';



void main() {
  var apiClient = ApiClient(basePath: 'http://127.0.0.1:8080');
  var api = ChatApi(apiClient);
  runApp(
    Provider<ChatApi>(
      create: (_) => api,
      child: const AiApp(),
    ),
  );
}

class AiApp extends StatelessWidget {
  const AiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chat Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Color.fromARGB(255, 209, 170, 32)),
        useMaterial3: true,
      ),
      home: SplashScreen(),
    );
  }
}