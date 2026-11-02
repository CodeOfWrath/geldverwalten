import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/entree_model.dart';

abstract class EntreeLocalDataSource {
  Future<List<EntreeModel>> getCachedEntrees();
  Future<void> cacheEntrees(List<EntreeModel> list);
  Future<void> addLocalEntree(EntreeModel entree);
}

class EntreeLocalDataSourceImpl implements EntreeLocalDataSource {
  final SharedPreferences sharedPreferences;
  static const String CACHED_ENTREES_KEY = 'CACHED_ENTREES_KEY';

  EntreeLocalDataSourceImpl({required this.sharedPreferences});

  @override
  Future<List<EntreeModel>> getCachedEntrees() async {
    final jsonString = sharedPreferences.getString(CACHED_ENTREES_KEY);
    if (jsonString != null) {
      final List<dynamic> jsonList = jsonDecode(jsonString);
      return jsonList.map((item) => EntreeModel.fromJson(item)).toList();
    }
    return [];
  }

  @override
  Future<void> cacheEntrees(List<EntreeModel> list) async {
    final jsonString = jsonEncode(list.map((e) => e.toJson()).toList());
    await sharedPreferences.setString(CACHED_ENTREES_KEY, jsonString);
  }

  @override
  Future<void> addLocalEntree(EntreeModel entree) async {
    final list = await getCachedEntrees();
    list.add(entree);
    await cacheEntrees(list);
  }
}
