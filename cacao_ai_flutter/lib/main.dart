import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'data/services/supabase_service.dart';
import 'providers/auth_provider.dart';
import 'providers/dashboard_provider.dart';
import 'providers/chat_provider.dart';
import 'providers/disease_provider.dart';
import 'providers/tips_provider.dart';
import 'providers/alert_provider.dart';
import 'providers/weather_provider.dart';
import 'ui/theme/app_theme.dart';
import 'ui/screens/auth/login_screen.dart';
import 'ui/screens/main_navigation_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase and configurations
  final supabaseService = SupabaseService();
  await supabaseService.initialize();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => DashboardProvider()),
        ChangeNotifierProvider(create: (_) => ChatProvider()),
        ChangeNotifierProvider(create: (_) => DiseaseProvider()),
        ChangeNotifierProvider(create: (_) => TipsProvider()),
        ChangeNotifierProvider(create: (_) => AlertProvider()),
        ChangeNotifierProvider(create: (_) => WeatherProvider()),
      ],
      child: const AzurApp(),
    ),
  );
}

class AzurApp extends StatelessWidget {
  const AzurApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final supabaseService = SupabaseService();
    // Exclude routing checks if Supabase is not fully initialized with real keys
    final bool sessionActive = supabaseService.currentUser != null;

    return MaterialApp(
      title: 'Azur',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      // If user session is active, go to dashboard, else show login
      home: sessionActive ? const MainNavigationScreen() : const LoginScreen(),
    );
  }
}
