import 'package:baloga_ar_rescue/core/network/api_client.dart';
import 'package:baloga_ar_rescue/data/models/species_model.dart';

class SpeciesService {
  Future<List<SpeciesModel>> getAllSpecies({String? category}) async {
    final params = <String, dynamic>{};
    if (category != null) params['category'] = category;
    final res = await ApiClient.instance.get('/species', queryParameters: params);
    final list = res.data['data'] as List;
    return list.map((e) => SpeciesModel.fromJson(e)).toList();
  }

  Future<SpeciesModel> getSpeciesDetail(int id) async {
    final res = await ApiClient.instance.get('/species/$id');
    return SpeciesModel.fromJson(res.data['data']);
  }
}

