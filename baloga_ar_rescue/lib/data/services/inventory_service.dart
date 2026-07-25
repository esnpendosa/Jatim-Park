import 'package:baloga_ar_rescue/core/network/api_client.dart';

class InventoryService {
  Future<List<Map<String, dynamic>>> getInventory() async {
    final res = await ApiClient.instance.get('/inventory');
    return List<Map<String, dynamic>>.from(res.data['data']);
  }

  Future<List<Map<String, dynamic>>> getItems() async {
    final res = await ApiClient.instance.get('/items');
    return List<Map<String, dynamic>>.from(res.data['data']);
  }
}

