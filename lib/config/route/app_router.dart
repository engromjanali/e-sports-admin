import 'package:clean_boilerplate/features/competition/presentation/screens/competition_screen.dart';
import 'package:clean_boilerplate/features/faq/presentation/screens/faq_screen.dart';
import 'package:clean_boilerplate/features/tags/presentation/screens/tags_screen.dart';
import 'package:clean_boilerplate/features/home/presentation/screens/home_screen.dart';
import 'package:clean_boilerplate/features/match/screen.dart';
import 'package:clean_boilerplate/features/match/domain/entities/match_entity.dart';
import 'package:clean_boilerplate/features/match/presentation/screens/match_screen.dart';
import 'package:clean_boilerplate/features/match_entry/presentation/screens/match_entry_screen.dart';
import 'package:clean_boilerplate/features/player/presentation/screens/player_screen.dart';
import 'package:clean_boilerplate/features/season/presentation/screens/season_screen.dart';
import 'package:clean_boilerplate/features/splash/presentation/screens/splash_screeen.dart';
import 'package:clean_boilerplate/features/business_setup/presentation/screens/business_setup_screen.dart';
import 'package:clean_boilerplate/features/auth/presentation/screens/login_screen.dart';
import 'package:clean_boilerplate/features/settings/presentation/screens/settings_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// App route constants
class AppRoutes {
  // Private constructor to prevent instantiation
  AppRoutes._();

  // Authentication routes
  static const String _splash = '/splash';
  static const String _login = '/login';

  // Main routes
  static const String home = '/';
  static const String _init = '/';
  static const String _profile = '/profile';
  static const String settings = '/settings';
  static const String businessSetup = '/business-setup';

  // Data management routes
  static const String seasons = '/seasons';
  static const String players = '/players';
  static const String matches = '/matches';
  static const String matchEntries = '/matches/:matchId/entries';
  static const String faqs = '/faqs';
  static const String competitions = '/competitions';
  static const String tags = '/tags';

  // Player approval (placeholder workflow)
  static const String pendingPlayer = '/player/pending';
  static const String approvedPlayer = '/player/approved';
  static const String suspendedPlayer = '/player/suspended';

  // Helper methods for parameterized routes
  static String getProfileRoute({required String userId}) => '$_profile?userId=$userId';

  static String getSplashRoute() => _splash;

  static String getLoginRoute() => _login;

  static String getMatchEntriesRoute(String matchId) =>
      '/matches/$matchId/entries';
}

/// Router configuration using go_router
final router = GoRouter(
  initialLocation: AppRoutes._init,
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
      builder: (context, state) => const HomeScreen(),
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

    // Data management
    GoRoute(
      path: AppRoutes.seasons,
      name: 'seasons',
      builder: (context, state) => const SeasonScreen(),
    ),

    GoRoute(
      path: AppRoutes.players,
      name: 'players',
      builder: (context, state) => const PlayerScreen(),
    ),

    GoRoute(
      path: AppRoutes.tags,
      name: 'tags',
      builder: (context, state) => const TagsScreen(),
    ),

    GoRoute(
      path: AppRoutes.matches,
      name: 'matches',
      builder: (context, state) => const MatchScreen(),
    ),

    GoRoute(
      path: AppRoutes.faqs,
      name: 'faqs',
      builder: (context, state) => const FaqScreen(),
    ),

    GoRoute(
      path: AppRoutes.competitions,
      name: 'competitions',
      builder: (context, state) => const CompetitionScreen(),
    ),

    GoRoute(
      path: AppRoutes.matchEntries,
      name: 'matchEntries',
      builder: (context, state) {
        final matchId = state.pathParameters['matchId'] ?? '';
        final match = state.extra is MatchEntity
            ? state.extra as MatchEntity
            : null;
        return MatchEntryScreen(matchId: matchId, match: match);
      },
    ),

    GoRoute(
      path: AppRoutes.pendingPlayer,
      name: 'pendingPlayer',
      builder: (context, state) => const PlayerStatusScreen(statusType: PlayerStatusType.pending),
    ),

    GoRoute(
      path: AppRoutes.approvedPlayer,
      name: 'approvedPlayer',
      builder: (context, state) => const PlayerStatusScreen(statusType: PlayerStatusType.approved),
    ),

    GoRoute(
      path: AppRoutes.suspendedPlayer,
      name: 'suspendedPlayer',
      builder: (context, state) => const PlayerStatusScreen(statusType: PlayerStatusType.suspended),
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
