import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:baloga_ar_rescue/presentation/providers/auth_provider.dart';
import 'package:baloga_ar_rescue/presentation/providers/location_provider.dart';
import 'package:baloga_ar_rescue/presentation/providers/app_config_provider.dart';
import 'package:baloga_ar_rescue/core/theme/app_theme.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _fadeAnim;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200));
    _fadeAnim = CurvedAnimation(parent: _ctrl, curve: Curves.easeIn);
    _scaleAnim = Tween<double>(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.elasticOut),
    );
    _ctrl.forward();
    _initApp();
  }

  Future<void> _initApp() async {
    await ref.read(appConfigProvider.notifier).fetchConfig();
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    final loggedIn = await ref.read(authProvider.notifier).loadUser();
    if (!mounted) return;
    if (loggedIn) {
      await ref.read(locationProvider.notifier).init();
      if (mounted) context.go('/map');
    } else {
      if (mounted) context.go('/login');
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appConfig = ref.watch(appConfigProvider);

    return Scaffold(
      backgroundColor: AppColors.bgDark,
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnim,
          child: ScaleTransition(
            scale: _scaleAnim,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Dynamic Logo
                Container(
                  width: 130,
                  height: 130,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        AppColors.primaryGlow.withOpacity(0.3),
                        AppColors.primary.withOpacity(0.1),
                        Colors.transparent,
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryGlow.withOpacity(0.4),
                        blurRadius: 40,
                        spreadRadius: 10,
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: appConfig.appLogoUrl != null
                        ? CachedNetworkImage(
                            imageUrl: appConfig.appLogoUrl!,
                            fit: BoxFit.cover,
                            placeholder: (c, u) => const Icon(Icons.eco_rounded, size: 80, color: AppColors.primaryGlow),
                            errorWidget: (c, u, e) => const Icon(Icons.eco_rounded, size: 80, color: AppColors.primaryGlow),
                          )
                        : const Icon(Icons.eco_rounded, size: 80, color: AppColors.primaryGlow),
                  ),
                ),
                const SizedBox(height: 28),
                // Dynamic App Name
                Text(
                  appConfig.appName.toUpperCase(),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontFamily: 'Outfit',
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                    color: AppColors.primaryGlow,
                    letterSpacing: 3,
                  ),
                ),
                const SizedBox(height: 8),
                // Dynamic App Tagline
                Text(
                  appConfig.appTagline,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontFamily: 'Outfit',
                    fontSize: 14,
                    color: AppColors.textSecondary,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 50),
                SizedBox(
                  width: 36,
                  height: 36,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryGlow.withOpacity(0.7)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
