class AppConfigModel {
  final String appName;
  final String appTagline;
  final String? appLogoUrl;
  final String apiDomain;

  AppConfigModel({
    required this.appName,
    required this.appTagline,
    this.appLogoUrl,
    required this.apiDomain,
  });

  factory AppConfigModel.fromJson(Map<String, dynamic> json) => AppConfigModel(
        appName: json['app_name'] ?? 'Baloga AR Rescue',
        appTagline: json['app_tagline'] ?? 'Penjaga Ekosistem Baloga',
        appLogoUrl: json['app_logo_url'],
        apiDomain: json['api_domain'] ?? 'https://balago.rozitech.co.id',
      );
}
