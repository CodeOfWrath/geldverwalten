import '../entities/entree_entity.dart';

abstract class EntreeRepository {
  Future<List<EntreeEntity>> getEntrees();
  Future<dynamic> addEntree(String origine, int montant);
}
