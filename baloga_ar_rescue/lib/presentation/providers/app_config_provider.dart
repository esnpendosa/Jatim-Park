import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:baloga_ar_rescue/core/network/api_client.dart';
import 'package:baloga_ar_rescue/data/models/app_config_model.dart';

final appConfigProvider = StateNotifierProvider<AppConfigNotifier, AppConfigModel>((ref) {
  return AppConfigNotifier();
});

class AppConfigNotifier extends StateNotifier<AppConfigModel> {
  AppConfigNotifier()
      : super(AppConfigModel(
          appName: 'Baloga AR Rescue',
          appTagline: 'Penjaga Ekosistem Baloga',
          appLogoUrl: null,
          apiDomain: 'https://balago.rozitech.co.id',
        ));

  Future<void> fetchConfig() async {
    try {
      final res = await ApiClient.instance.get('/app-config');
      if (res.data != null) {
        state = AppConfigModel.fromJson(res.data);
      }
    } catch (_) {}
  }
}
