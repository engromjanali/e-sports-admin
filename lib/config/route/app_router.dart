import 'package:clean_boilerplate/features/splash/presentation/screens/splash_screeen.dart';
import 'package:clean_boilerplate/features/business_setup/presentation/screens/business_setup_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/settings/presentation/screens/settings_screen.dart';

/// App route constants
class AppRoutes {
  // Private constructor to prevent instantiation
  AppRoutes._();
  
  // Authentication routes
  static const String _splash = '/splash';
  static const String _login = '/login';
  static const String _register = '/register';
  
  // Main routes
  static const String _init = '/';
  static const String _profile = '/profile';
  static const String settings = '/settings';
  static const String businessSetup = '/business-setup';
  
  // Helper methods for parameterized routes
  static String getProfileRoute({required String userId}) => '$_profile?userId=$userId';

  static String getSplashRoute() => _splash;

  static String getLoginRoute() => _login;
}

/// Router configuration using go_router
final router = GoRouter(
  initialLocation: AppRoutes.businessSetup,
  routes: [

    GoRoute(
      path: AppRoutes._splash,
      name: 'splash',
      builder: (context, state) => const SplashScreen(),
    ),

    // Authentication routes
    GoRoute(
      path: AppRoutes._login,
      name: 'login',
      builder: (context, state) => const LoginScreen(),
    ),
    
    // Home route
    GoRoute(
      path: AppRoutes._init,
      name: 'home',
      builder: (context, state) => const Scaffold(
        body: Center(
          child: Text('Home Screen'),
        ),
      ),
    ),
    
    // Settings route
    GoRoute(
      path: AppRoutes.settings,
      name: 'settings',
      builder: (context, state) => const SettingsScreen(),
    ),

    GoRoute(
      path: AppRoutes.businessSetup,
      name: 'businessSetup',
      builder: (context, state) => const BusinessSetupScreen(),
    ),
    
    // Add more routes as your app grows
  ],
  
  // Error handling
  errorBuilder: (context, state) => Scaffold(
    body: Center(
      child: Text('Page not found: ${state.matchedLocation}'),
    ),
  ),
);
