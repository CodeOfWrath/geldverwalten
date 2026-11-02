import '../entities/entree_entity.dart';
import '../repositories/entree_repository.dart';

class GetEntrees {
  final EntreeRepository repository;

  GetEntrees(this.repository);

  Future<List<EntreeEntity>> call() async {
    return await repository.getEntrees();
  }
}
