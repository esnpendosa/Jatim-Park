import 'package:baloga_ar_rescue/core/network/api_client.dart';

class MissionService {
  Future<List<Map<String, dynamic>>> getMissions() async {
    final res = await ApiClient.instance.get('/missions');
    return List<Map<String, dynamic>>.from(res.data['data']);
  }

  Future<Map<String, dynamic>> claimMission(int missionId) async {
    final res = await ApiClient.instance.post('/missions/$missionId/claim');
    return Map<String, dynamic>.from(res.data);
  }
}

