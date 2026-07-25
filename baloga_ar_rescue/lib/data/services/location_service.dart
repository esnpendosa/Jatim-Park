import 'package:baloga_ar_rescue/core/network/api_client.dart';
import 'package:baloga_ar_rescue/data/models/spawn_point_model.dart';

class LocationService {
  Future<List<Map<String, dynamic>>> getGameLocations() async {
    final res = await ApiClient.instance.get('/game-locations');
    return List<Map<String, dynamic>>.from(res.data['data']);
  }

  Future<List<SpawnPointModel>> getNearbySpawnPoints(double lat, double lng, {double radius = 1000}) async {
    final res = await ApiClient.instance.get('/spawn-points/nearby', queryParameters: {
      'lat': lat,
      'lng': lng,
      'radius': radius,
    });
    final list = res.data['data'] as List;
    return list.map((e) => SpawnPointModel.fromJson(e)).toList();
  }
}

