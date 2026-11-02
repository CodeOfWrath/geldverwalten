import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/solde_model.dart';
import '../../../entree/data/datasources/entree_local_datasource.dart';
import '../../../sortie/data/datasources/sortie_local_datasource.dart';

abstract class SoldeLocalDataSource {
  Future<List<SoldeModel>> getCachedSolde();
  Future<void> cacheSolde(List<SoldeModel> list);
}

class SoldeLocalDataSourceImpl implements SoldeLocalDataSource {
  final SharedPreferences sharedPreferences;
  static const String CACHED_SOLDE_KEY = 'CACHED_SOLDE_KEY';

  SoldeLocalDataSourceImpl({required this.sharedPreferences});

  @override
  Future<List<SoldeModel>> getCachedSolde() async {
    final jsonString = sharedPreferences.getString(CACHED_SOLDE_KEY);
    if (jsonString != null) {
      final List<dynamic> jsonList = jsonDecode(jsonString);
      return jsonList.map((item) => SoldeModel.fromJson(item)).toList();
    }

    // Calculate real dynamic net balance from local entries minus local expenses
    final entreeDs = EntreeLocalDataSourceImpl(sharedPreferences: sharedPreferences);
    final sortieDs = SortieLocalDataSourceImpl(sharedPreferences: sharedPreferences);

    final entrees = await entreeDs.getCachedEntrees();
    final sorties = await sortieDs.getCachedSorties();

    final totalRevenus = entrees.fold<int>(0, (sum, item) => sum + item.montant);
    final totalDepenses = sorties.fold<int>(0, (sum, item) => sum + item.montant);

    return [SoldeModel(montant: totalRevenus - totalDepenses)];
  }

  @override
  Future<void> cacheSolde(List<SoldeModel> list) async {
    final jsonString = jsonEncode(list.map((e) => e.toJson()).toList());
    await sharedPreferences.setString(CACHED_SOLDE_KEY, jsonString);
  }
}
