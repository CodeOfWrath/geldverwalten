import '../../../../core/util/data_change_notifier.dart';
import '../../domain/entities/projet_entity.dart';
import '../../domain/repositories/projet_repository.dart';
import '../datasources/projet_local_datasource.dart';
import '../datasources/projet_remote_datasource.dart';
import '../models/projet_model.dart';

class ProjetRepositoryImpl implements ProjetRepository {
  final ProjetRemoteDataSource remoteDataSource;
  final ProjetLocalDataSource localDataSource;

  ProjetRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<List<ProjetEntity>> getProjets() async {
    try {
      final remoteList = await remoteDataSource.getProjets();
      await localDataSource.cacheProjets(remoteList);
      return remoteList;
    } catch (_) {
      return await localDataSource.getCachedProjets();
    }
  }

  @override
  Future<dynamic> createProjet(String nomProjet, {int montantCible = 100000}) async {
    final newModel = ProjetModel(
      id: DateTime.now().millisecondsSinceEpoch,
      idUser: 1,
      statut: 1,
      nomProjet: nomProjet,
      montantCible: montantCible > 0 ? montantCible : 100000,
      montantActuel: 0,
    );

    // 1. Local-First Instant Write
    await localDataSource.addLocalProjet(newModel);

    // 2. Notify entire app to refresh data in real time
    dataChangeNotifier.notifyDataChanged();

    // 3. Background async remote sync (non-blocking)
    remoteDataSource.createProjet(nomProjet).then((_) {}).catchError((_) {});

    return newModel.toJson();
  }
}
