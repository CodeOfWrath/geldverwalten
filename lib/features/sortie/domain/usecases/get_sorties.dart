import '../entities/sortie_entity.dart';
import '../repositories/sortie_repository.dart';

class GetSorties {
  final SortieRepository repository;

  GetSorties(this.repository);

  Future<List<SortieEntity>> call() async {
    return await repository.getSorties();
  }
}
