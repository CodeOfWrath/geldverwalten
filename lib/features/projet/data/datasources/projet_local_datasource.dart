import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/projet_model.dart';

abstract class ProjetLocalDataSource {
  Future<List<ProjetModel>> getCachedProjets();
  Future<void> cacheProjets(List<ProjetModel> list);
  Future<void> addLocalProjet(ProjetModel projet);
  Future<void> updateProjetMontant(int idProjet, int deltaMontant);
}

class ProjetLocalDataSourceImpl implements ProjetLocalDataSource {
  final SharedPreferences sharedPreferences;
  static const String cachedProjetsKey = 'CACHED_PROJETS_KEY';

  ProjetLocalDataSourceImpl({required this.sharedPreferences});

  @override
  Future<List<ProjetModel>> getCachedProjets() async {
    final jsonString = sharedPreferences.getString(cachedProjetsKey);
    if (jsonString != null) {
      final List<dynamic> jsonList = jsonDecode(jsonString);
      return jsonList.map((item) => ProjetModel.fromJson(item)).toList();
    }
    return [];
  }

  @override
  Future<void> cacheProjets(List<ProjetModel> list) async {
    final jsonString = jsonEncode(list.map((e) => e.toJson()).toList());
    await sharedPreferences.setString(cachedProjetsKey, jsonString);
  }

  @override
  Future<void> addLocalProjet(ProjetModel projet) async {
    final list = await getCachedProjets();
    list.add(projet);
    await cacheProjets(list);
  }

  @override
  Future<void> updateProjetMontant(int idProjet, int deltaMontant) async {
    final list = await getCachedProjets();
    for (int i = 0; i < list.length; i++) {
      if (list[i].id == idProjet) {
        final current = list[i];
        list[i] = ProjetModel(
          id: current.id,
          idUser: current.idUser,
          statut: current.statut,
          nomProjet: current.nomProjet,
          montantCible: current.montantCible,
          montantActuel: (current.montantActuel + deltaMontant).clamp(0, current.montantCible * 10),
        );
        break;
      }
    }
    await cacheProjets(list);
  }
}
