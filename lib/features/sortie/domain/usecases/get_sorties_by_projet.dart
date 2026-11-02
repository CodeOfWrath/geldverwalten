import '../entities/sortie_entity.dart';
import '../repositories/sortie_repository.dart';

class GetSortiesByProjet {
  final SortieRepository repository;

  GetSortiesByProjet(this.repository);

  Future<List<SortieEntity>> call(int idProjet) async {
    return await repository.getSortiesByProjet(idProjet);
  }
}
