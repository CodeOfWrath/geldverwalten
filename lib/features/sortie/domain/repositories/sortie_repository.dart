import '../entities/sortie_entity.dart';

abstract class SortieRepository {
  Future<List<SortieEntity>> getSorties();
  Future<List<SortieEntity>> getSortiesByProjet(int idProjet);
  Future<dynamic> addSortie(String raison, String montant, int idProjet);
}
