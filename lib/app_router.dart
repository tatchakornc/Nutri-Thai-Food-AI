import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'providers/auth_provider.dart';
import 'screens/splash_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/home/home_dashboard_screen.dart';
import 'screens/food_log/food_log_screen.dart';
import 'screens/food_log/ai_food_scan_screen.dart';
import 'screens/food_log/food_history_screen.dart';
import 'screens/food_log/quick_manual_log_screen.dart';
import 'screens/food_log/gram_based_calculation_screen.dart';
import 'screens/random_food/random_food_screen.dart';
import 'screens/water/water_tracker_screen.dart';
import 'screens/quest/quest_screen.dart';
import 'screens/profile/profile_screen.dart';
import 'screens/profile/profile_setup_screen.dart';
import 'screens/profile/settings_screen.dart';
import 'widgets/main_shell.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      final isLoggedIn = authState.valueOrNull != null;
      final isAuthRoute = state.matchedLocation == '/login' ||
          state.matchedLocation == '/register';
      final isSplash = state.matchedLocation == '/';

      if (isSplash) return null; // Splash handles its own redirect
      if (!isLoggedIn && !isAuthRoute) return '/login';
      if (isLoggedIn && isAuthRoute) return '/home';
      return null;
    },
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/profile-setup',
        builder: (context, state) => const ProfileSetupScreen(),
      ),
      GoRoute(
        path: '/profile-setup-edit',
        builder: (context, state) =>
            const ProfileSetupScreen(isEditing: true),
      ),

      // Main shell with bottom navigation
      ShellRoute(
        builder: (context, state, child) => MainShell(child: child),
        routes: [
          GoRoute(
            path: '/home',
            builder: (context, state) => const HomeDashboardScreen(),
          ),
          GoRoute(
            path: '/food-log',
            builder: (context, state) => const FoodLogScreen(),
          ),
          GoRoute(
            path: '/random',
            builder: (context, state) => const RandomFoodScreen(),
          ),
          GoRoute(
            path: '/water',
            builder: (context, state) => const WaterTrackerScreen(),
          ),
          GoRoute(
            path: '/profile',
            builder: (context, state) => const ProfileScreen(),
          ),
        ],
      ),

      // Modal / push routes
      GoRoute(
        path: '/ai-scan',
        builder: (context, state) => const AIFoodScanScreen(),
      ),
      GoRoute(
        path: '/food-history',
        builder: (context, state) => const FoodHistoryScreen(),
      ),
      GoRoute(
        path: '/quick-log',
        builder: (context, state) => const QuickManualLogScreen(),
      ),
      GoRoute(
        path: '/gram-based',
        builder: (context, state) => const GramBasedCalculationScreen(),
      ),
      GoRoute(
        path: '/quests',
        builder: (context, state) => const QuestScreen(),
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsScreen(),
      ),
    ],
  );
});
