import '../entities/solde_entity.dart';

abstract class SoldeRepository {
  Future<List<SoldeEntity>> getSolde();
}
