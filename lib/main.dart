import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart'; // Import the generated options
import 'providers/auth_provider.dart';
import 'providers/product_provider.dart';
import 'screens/auth/auth_wrapper.dart';
import 'screens/splash_screen.dart';
import 'screens/admin_panel.dart'; // Import the admin panel screen
import 'screens/home_screen.dart'; // Import the home screen
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Initialize Firebase with platform-specific options
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await Supabase.initialize(
    url: 'https://ayuzdcrlxocbamqgeagy.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImF5dXpkY3JseG9jYmFtcWdlYWd5Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDgyMzI0NjcsImV4cCI6MjA2MzgwODQ2N30.T5OE222xOKzTM1_njYq8-hGMUxep2ZRc8IfrsTbPkig',
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ProductProvider()),
      ],
      child: MaterialApp(
        title: 'Tech Hub App',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueAccent),
          useMaterial3: true,
        ),
        home: const SplashScreen(),
        // Add a route for the admin panel (example):
        routes: {
          '/admin': (context) => const AdminPanelScreen(),
          '/home': (context) => const HomeScreen(), // <-- Add this route
        },
        // Or add a button somewhere in your app to navigate to AdminPanelScreen
      ),
    );
  }
}
