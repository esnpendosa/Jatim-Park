import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:baloga_ar_rescue/presentation/providers/auth_provider.dart';
import 'package:baloga_ar_rescue/presentation/providers/location_provider.dart';
import '../screens/splash/splash_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/map/map_screen.dart';
import '../screens/capture/capture_screen.dart';
import '../screens/encyclopedia/encyclopedia_screen.dart';
import '../screens/missions/missions_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../screens/inventory/inventory_screen.dart';
import '../screens/home/home_shell.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/splash',
    routes: [
      GoRoute(path: '/splash', builder: (ctx, state) => const SplashScreen()),
      GoRoute(path: '/login', builder: (ctx, state) => const LoginScreen()),
      GoRoute(path: '/register', builder: (ctx, state) => const RegisterScreen()),
      ShellRoute(
        builder: (ctx, state, child) => HomeShell(child: child),
        routes: [
          GoRoute(path: '/map', builder: (ctx, state) => const MapScreen()),
          GoRoute(path: '/encyclopedia', builder: (ctx, state) => const EncyclopediaScreen()),
          GoRoute(path: '/missions', builder: (ctx, state) => const MissionsScreen()),
          GoRoute(path: '/profile', builder: (ctx, state) => const ProfileScreen()),
          GoRoute(path: '/inventory', builder: (ctx, state) => const InventoryScreen()),
        ],
      ),
      GoRoute(
        path: '/capture/:spawnPointId',
        builder: (ctx, state) {
          final id = int.parse(state.pathParameters['spawnPointId']!);
          final extra = state.extra as Map<String, dynamic>?;
          return CaptureScreen(spawnPointId: id, extra: extra);
        },
      ),
    ],
  );
});

