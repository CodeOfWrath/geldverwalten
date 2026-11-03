import '../../../../core/util/data_change_notifier.dart';
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

    // 1. Local-First Instant Write
    await localDataSource.addLocalEntree(newModel);

    // 2. Notify entire app to refresh data in real time
    dataChangeNotifier.notifyDataChanged();

    // 3. Background async remote sync (non-blocking)
    remoteDataSource.addEntree(origine, montant).then((_) {}).catchError((_) {});

    return newModel.toJson();
  }
}
