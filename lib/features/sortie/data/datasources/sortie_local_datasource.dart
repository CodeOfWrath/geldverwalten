import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/sortie_model.dart';

abstract class SortieLocalDataSource {
  Future<List<SortieModel>> getCachedSorties();
  Future<void> cacheSorties(List<SortieModel> list);
  Future<void> addLocalSortie(SortieModel sortie);
}

class SortieLocalDataSourceImpl implements SortieLocalDataSource {
  final SharedPreferences sharedPreferences;
  static const String CACHED_SORTIES_KEY = 'CACHED_SORTIES_KEY';

  SortieLocalDataSourceImpl({required this.sharedPreferences});

  @override
  Future<List<SortieModel>> getCachedSorties() async {
    final jsonString = sharedPreferences.getString(CACHED_SORTIES_KEY);
    if (jsonString != null) {
      final List<dynamic> jsonList = jsonDecode(jsonString);
      return jsonList.map((item) => SortieModel.fromJson(item)).toList();
    }
    return [];
  }

  @override
  Future<void> cacheSorties(List<SortieModel> list) async {
    final jsonString = jsonEncode(list.map((e) => e.toJson()).toList());
    await sharedPreferences.setString(CACHED_SORTIES_KEY, jsonString);
  }

  @override
  Future<void> addLocalSortie(SortieModel sortie) async {
    final list = await getCachedSorties();
    list.add(sortie);
    await cacheSorties(list);
  }
}
