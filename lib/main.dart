import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/theme.dart';
import 'data/app_state.dart';
import 'features/auth/auth_screens.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => AppState(),
      child: const LimitaApp(),
    ),
  );
}

class LimitaApp extends StatelessWidget {
  const LimitaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Limita',
      debugShowCheckedModeBanner: false,
      theme: buildTheme(),
      home: const SignInScreen(),
    );
  }
}
