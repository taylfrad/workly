import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:job_tinder/themes/app_theme.dart';
import 'providers/auth_provider.dart';
import 'screens/auth_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/job_swipe_screen.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase with platform-specific options
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  runApp(const WorklyApp());
}

class WorklyApp extends StatelessWidget {
  const WorklyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<AuthProvider>(
      create: (context) => AuthProvider(),
      child: MaterialApp(
        title: 'Workly',
        theme: AppTheme.lightTheme,
        home: const AuthWrapper(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  @override
  void initState() {
    super.initState();
    // Listen to auth changes and force rebuild
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      authProvider.addListener(_onAuthStateChanged);
    });
  }
  
  void _onAuthStateChanged() {
    if (mounted) {
      setState(() {});
    }
  }
  
  @override
  void dispose() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    authProvider.removeListener(_onAuthStateChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        
        // Show loading screen while checking auth state
        if (authProvider.isLoading && !authProvider.hasUser) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        // If user is signed in (Google or guest), check if profile is complete
        if (authProvider.hasUser) {
          
          // If profile is complete, go directly to job swipe screen
          if (authProvider.currentUser?.phoneNumber.isNotEmpty == true && 
              authProvider.currentUser?.location.isNotEmpty == true) {
            return JobSwipeScreen(key: ValueKey('jobswipe_${authProvider.currentUser?.userId}'));
          } else {
            // Profile not complete, go to profile screen
            return ProfileScreen(key: ValueKey('profile_${authProvider.currentUser?.userId}'));
          }
        }

        // Otherwise, show auth screen
        return const AuthScreen();
      },
    );
  }
}