import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // ---------------------------------------------------------------------------
  // ⚠️ CRITICAL CONFIGURATION REQUIRED BEFORE PUBLISHING ⚠️
  // ---------------------------------------------------------------------------
  // You must replace the values below with your actual Supabase project details.
  // 1. Go to https://supabase.com/dashboard/project/_/settings/api
  // 2. Copy "Project URL" and "anon" public key
  // ---------------------------------------------------------------------------
  const String supabaseUrl = 'https://your-project-url.supabase.co';
  const String supabaseAnonKey = 'your-anon-key';

  // Safety check to warn developers in the console
  if (supabaseUrl.contains('your-project-url')) {
    debugPrint('🔴 ERROR: Supabase credentials are not configured in lib/main.dart');
    debugPrint('🔴 Database features (History, Auth) will NOT work until updated.');
  }

  await Supabase.initialize(
    url: supabaseUrl,
    anonKey: supabaseAnonKey,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tingwu Translator',
      debugShowCheckedModeBanner: false,
      // Define the initial route explicitly for web/deep-linking safety
      initialRoute: '/',
      routes: {
        '/': (context) => const HomeScreen(),
      },
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
    );
  }
}
