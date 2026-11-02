import '../../domain/entities/solde_entity.dart';
import '../../domain/repositories/solde_repository.dart';
import '../datasources/solde_local_datasource.dart';
import '../datasources/solde_remote_datasource.dart';

class SoldeRepositoryImpl implements SoldeRepository {
  final SoldeRemoteDataSource remoteDataSource;
  final SoldeLocalDataSource localDataSource;

  SoldeRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<List<SoldeEntity>> getSolde() async {
    try {
      final remoteSolde = await remoteDataSource.getSolde();
      await localDataSource.cacheSolde(remoteSolde);
      return remoteSolde;
    } catch (_) {
      // Offline-First Fallback
      return await localDataSource.getCachedSolde();
    }
  }
}
