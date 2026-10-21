import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';
import 'pages/login_page.dart';
import 'pages/central_jujutsu_page.dart';
import 'providers/auth_provider.dart';
import 'services/auth_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(
    ChangeNotifierProvider(
      create: (_) => AuthProvider(AuthService())..listenToAuthChanges(),
      child: const JujutsuApp(),
    ),
  );
}

class JujutsuApp extends StatelessWidget {
  const JujutsuApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Escola Jujutsu',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF7C3AED),
          brightness: Brightness.dark,
        ),
        scaffoldBackgroundColor: const Color(0xFF101018),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF171722),
          foregroundColor: Colors.white,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFF20202D),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
        ),
      ),
      home: Consumer<AuthProvider>(
        builder: (context, auth, _) {
          if (auth.isLoading) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          return auth.user == null
              ? const LoginPage()
              : const CentralJujutsuPage();
        },
      ),
    );
  }
}
