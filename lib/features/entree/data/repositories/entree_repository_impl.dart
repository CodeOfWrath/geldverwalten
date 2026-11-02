import '../../domain/entities/entree_entity.dart';
import '../../domain/repositories/entree_repository.dart';
import '../datasources/entree_local_datasource.dart';
import '../datasources/entree_remote_datasource.dart';
import '../models/entree_model.dart';

class EntreeRepositoryImpl implements EntreeRepository {
  final EntreeRemoteDataSource remoteDataSource;
  final EntreeLocalDataSource localDataSource;

  EntreeRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<List<EntreeEntity>> getEntrees() async {
    try {
      final remoteList = await remoteDataSource.getEntrees();
      await localDataSource.cacheEntrees(remoteList);
      return remoteList;
    } catch (_) {
      return await localDataSource.getCachedEntrees();
    }
  }

  @override
  Future<dynamic> addEntree(String origine, int montant) async {
    final newModel = EntreeModel(
      montant: montant,
      origine: origine,
      date: "${DateTime.now().day.toString().padLeft(2, '0')}/${DateTime.now().month.toString().padLeft(2, '0')}/${DateTime.now().year}",
    );
    await localDataSource.addLocalEntree(newModel);
    try {
      return await remoteDataSource.addEntree(origine, montant);
    } catch (_) {
      return newModel.toJson();
    }
  }
}
