import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:safeguard_parental_control/screens/splash_screen.dart';
import 'providers/admin_provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'screens/welcome_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/dashboard/parent_dashboard.dart';
import 'screens/dashboard/child_dashboard.dart';
import 'utils/theme.dart';
import 'providers/app_provider.dart';
import 'screens/admin/admin_login_screen.dart';
import 'screens/admin/admin_dashboard.dart';
import 'screens/auth/user_type_selection_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppProvider()..initializeAuth()),
        ChangeNotifierProvider(create: (_) => AdminProvider()),
      ],
      child: MaterialApp(
        title: 'SafeGuard Parental Control',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        initialRoute: '/',
        routes: {
          '/': (context) => const SplashScreen(),
          '/user-type-selection': (context) => const UserTypeSelectionScreen(),
          '/welcome-screen': (context) => const WelcomeScreen(),
          '/login': (context) => const LoginScreen(),
          '/register': (context) => const RegisterScreen(),
          '/parent-dashboard': (context) => const ParentDashboard(),
          '/child-dashboard': (context) => const ChildDashboard(),
          '/admin-login': (context) => const AdminLoginScreen(),
          '/admin-dashboard': (context) => const AdminDashboard(),
        },
      ),
    );
  }
}
