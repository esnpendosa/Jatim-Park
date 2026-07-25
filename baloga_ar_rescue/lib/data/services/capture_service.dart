import 'package:baloga_ar_rescue/core/network/api_client.dart';

class CaptureService {
  Future<Map<String, dynamic>> attemptCapture({
    required int spawnPointId,
    required double lat,
    required double lng,
    required int itemId,
  }) async {
    final res = await ApiClient.instance.post('/captures/attempt', data: {
      'spawn_point_id': spawnPointId,
      'lat': lat,
      'lng': lng,
      'item_id': itemId,
    });
    return Map<String, dynamic>.from(res.data);
  }
}

