import '../entities/projet_entity.dart';
import '../repositories/projet_repository.dart';

class GetProjets {
  final ProjetRepository repository;

  GetProjets(this.repository);

  Future<List<ProjetEntity>> call() async {
    return await repository.getProjets();
  }
}
