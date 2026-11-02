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
  Future<dynamic> createProjet(String nomProjet) async {
    final newModel = ProjetModel(
      id: DateTime.now().millisecondsSinceEpoch,
      idUser: 1,
      statut: 1,
      nomProjet: nomProjet,
      montantCible: 100000,
      montantActuel: 0,
    );
    await localDataSource.addLocalProjet(newModel);
    try {
      return await remoteDataSource.createProjet(nomProjet);
    } catch (_) {
      return newModel.toJson();
    }
  }
}
