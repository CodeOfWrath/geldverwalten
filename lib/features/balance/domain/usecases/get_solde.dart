import '../entities/solde_entity.dart';
import '../repositories/solde_repository.dart';

class GetSolde {
  final SoldeRepository repository;

  GetSolde(this.repository);

  Future<List<SoldeEntity>> call() async {
    return await repository.getSolde();
  }
}
