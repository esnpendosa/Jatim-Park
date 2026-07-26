import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:baloga_ar_rescue/presentation/providers/auth_provider.dart';
import 'package:baloga_ar_rescue/presentation/providers/location_provider.dart';
import 'package:baloga_ar_rescue/presentation/providers/app_config_provider.dart';
import 'package:baloga_ar_rescue/core/network/api_client.dart';
import 'package:baloga_ar_rescue/core/theme/app_theme.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    final ok = await ref.read(authProvider.notifier).login(_emailCtrl.text.trim(), _passCtrl.text);
    if (!mounted) return;
    if (ok) {
      await ref.read(locationProvider.notifier).init();
      context.go('/map');
    }
  }

  void _showServerSettingsDialog() {
    final urlCtrl = TextEditingController(text: ApiClient.currentUrl);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.bgCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.dns_rounded, color: AppColors.primaryGlow),
            SizedBox(width: 8),
            Text('Pengaturan Server API', style: TextStyle(fontFamily: 'Outfit', color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Pilih atau ketik URL Server API (HTTP / HTTPS):', style: TextStyle(fontFamily: 'Outfit', color: AppColors.textMuted, fontSize: 12)),
            const SizedBox(height: 12),
            TextField(
              controller: urlCtrl,
              style: const TextStyle(fontFamily: 'Outfit', color: AppColors.textPrimary, fontSize: 13),
              decoration: InputDecoration(
                hintText: 'https://balago.rozitech.co.id/api',
                hintStyle: TextStyle(color: AppColors.textMuted.withOpacity(0.5)),
                filled: true,
                fillColor: AppColors.bgDark,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(height: 12),
            const Text('Pilihan Cepat:', style: TextStyle(fontFamily: 'Outfit', color: AppColors.textMuted, fontSize: 11, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                _buildQuickChip('HTTPS Live', 'https://balago.rozitech.co.id/api', urlCtrl),
                _buildQuickChip('HTTP Live', 'http://balago.rozitech.co.id/api', urlCtrl),
                _buildQuickChip('Emulator', 'http://10.0.2.2:8000/api', urlCtrl),
                _buildQuickChip('Local PC', 'http://127.0.0.1:8000/api', urlCtrl),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('BATAL', style: TextStyle(color: AppColors.textMuted)),
          ),
          ElevatedButton(
            onPressed: () async {
              await ApiClient.updateBaseUrl(urlCtrl.text);
              await ref.read(appConfigProvider.notifier).fetchConfig();
              if (mounted) {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Server API diubah ke: ${ApiClient.currentUrl}'),
                    backgroundColor: AppColors.primaryLight,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryLight),
            child: const Text('SIMPAN', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickChip(String label, String url, TextEditingController ctrl) {
    return ActionChip(
      label: Text(label, style: const TextStyle(fontSize: 10, fontFamily: 'Outfit', color: AppColors.textPrimary)),
      backgroundColor: AppColors.bgDark,
      onPressed: () => ctrl.text = url,
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final appConfig = ref.watch(appConfigProvider);

    return Scaffold(
      backgroundColor: AppColors.bgDark,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Server URL Config Button Header
              Align(
                alignment: Alignment.topRight,
                child: IconButton(
                  onPressed: _showServerSettingsDialog,
                  icon: const Icon(Icons.settings_input_component_rounded, color: AppColors.primaryGlow, size: 22),
                  tooltip: 'Pengaturan Server API',
                ),
              ),

              // Dynamic Logo
              Center(
                child: Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.bgCard,
                    boxShadow: [
                      BoxShadow(color: AppColors.primaryGlow.withOpacity(0.25), blurRadius: 30, spreadRadius: 5),
                    ],
                  ),
                  child: ClipOval(
                    child: appConfig.appLogoUrl != null
                        ? CachedNetworkImage(
                            imageUrl: appConfig.appLogoUrl!,
                            fit: BoxFit.cover,
                            placeholder: (c, u) => const Icon(Icons.eco_rounded, size: 48, color: AppColors.primaryGlow),
                            errorWidget: (c, u, e) => const Icon(Icons.eco_rounded, size: 48, color: AppColors.primaryGlow),
                          )
                        : const Icon(Icons.eco_rounded, size: 48, color: AppColors.primaryGlow),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Center(
                child: Column(
                  children: [
                    Text(
                      appConfig.appName.toUpperCase(),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontFamily: 'Outfit',
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: AppColors.primaryGlow,
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      appConfig.appTagline,
                      textAlign: TextAlign.center,
                      style: TextStyle(fontFamily: 'Outfit', fontSize: 13, color: AppColors.textMuted),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              // Active Server Indicator Badge
              GestureDetector(
                onTap: _showServerSettingsDialog,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.bgCard,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.primaryGlow.withOpacity(0.2)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.wifi_rounded, size: 14, color: AppColors.primaryGlow),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Server: ${ApiClient.currentUrl}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontFamily: 'Outfit', fontSize: 11, color: AppColors.textMuted),
                        ),
                      ),
                      const Text('UBAH', style: TextStyle(fontFamily: 'Outfit', fontSize: 10, color: AppColors.primaryGlow, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Error banner
              if (authState.error != null)
                Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.danger.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.danger.withOpacity(0.4)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline, color: AppColors.danger, size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(authState.error!,
                            style: const TextStyle(color: AppColors.danger, fontFamily: 'Outfit', fontSize: 13)),
                      ),
                    ],
                  ),
                ),

              // Form
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    _buildField(
                      controller: _emailCtrl,
                      label: 'Email',
                      icon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                      validator: (v) => (v == null || !v.contains('@')) ? 'Email tidak valid' : null,
                    ),
                    const SizedBox(height: 16),
                    _buildField(
                      controller: _passCtrl,
                      label: 'Password',
                      icon: Icons.lock_outline,
                      obscure: _obscure,
                      suffixIcon: IconButton(
                        icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility, color: AppColors.textMuted),
                        onPressed: () => setState(() => _obscure = !_obscure),
                      ),
                      validator: (v) => (v == null || v.length < 8) ? 'Min 8 karakter' : null,
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: authState.isLoading ? null : _login,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryLight,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        child: authState.isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                              )
                            : const Text('MASUK', style: TextStyle(fontFamily: 'Outfit', fontSize: 16, fontWeight: FontWeight.w800, letterSpacing: 2)),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Belum punya akun?  ', style: TextStyle(fontFamily: 'Outfit', color: AppColors.textMuted, fontSize: 13)),
                        GestureDetector(
                          onTap: () => context.go('/register'),
                          child: const Text('Daftar Sekarang', style: TextStyle(fontFamily: 'Outfit', color: AppColors.primaryGlow, fontWeight: FontWeight.bold, fontSize: 13)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscure = false,
    Widget? suffixIcon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboardType,
      validator: validator,
      style: const TextStyle(fontFamily: 'Outfit', color: AppColors.textPrimary),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(fontFamily: 'Outfit', color: AppColors.textMuted),
        prefixIcon: Icon(icon, color: AppColors.textMuted, size: 20),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: AppColors.bgCard,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.bgSurface),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.textMuted.withOpacity(0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primaryGlow, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.danger),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.danger),
        ),
      ),
    );
  }
}
