import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/projet_model.dart';

abstract class ProjetLocalDataSource {
  Future<List<ProjetModel>> getCachedProjets();
  Future<void> cacheProjets(List<ProjetModel> list);
  Future<void> addLocalProjet(ProjetModel projet);
}

class ProjetLocalDataSourceImpl implements ProjetLocalDataSource {
  final SharedPreferences sharedPreferences;
  static const String CACHED_PROJETS_KEY = 'CACHED_PROJETS_KEY';

  ProjetLocalDataSourceImpl({required this.sharedPreferences});

  @override
  Future<List<ProjetModel>> getCachedProjets() async {
    final jsonString = sharedPreferences.getString(CACHED_PROJETS_KEY);
    if (jsonString != null) {
      final List<dynamic> jsonList = jsonDecode(jsonString);
      return jsonList.map((item) => ProjetModel.fromJson(item)).toList();
    }
    return [];
  }

  @override
  Future<void> cacheProjets(List<ProjetModel> list) async {
    final jsonString = jsonEncode(list.map((e) => e.toJson()).toList());
    await sharedPreferences.setString(CACHED_PROJETS_KEY, jsonString);
  }

  @override
  Future<void> addLocalProjet(ProjetModel projet) async {
    final list = await getCachedProjets();
    list.add(projet);
    await cacheProjets(list);
  }
}
