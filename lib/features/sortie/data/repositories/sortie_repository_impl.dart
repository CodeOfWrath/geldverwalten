import '../../domain/entities/sortie_entity.dart';
import '../../domain/repositories/sortie_repository.dart';
import '../datasources/sortie_local_datasource.dart';
import '../datasources/sortie_remote_datasource.dart';
import '../models/sortie_model.dart';

class SortieRepositoryImpl implements SortieRepository {
  final SortieRemoteDataSource remoteDataSource;
  final SortieLocalDataSource localDataSource;

  SortieRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<List<SortieEntity>> getSorties() async {
    try {
      final remoteList = await remoteDataSource.getSorties();
      await localDataSource.cacheSorties(remoteList);
      return remoteList;
    } catch (_) {
      return await localDataSource.getCachedSorties();
    }
  }

  @override
  Future<List<SortieEntity>> getSortiesByProjet(int idProjet) async {
    try {
      final remoteList = await remoteDataSource.getSortiesByProjet(idProjet);
      return remoteList;
    } catch (_) {
      final allLocal = await localDataSource.getCachedSorties();
      return allLocal;
    }
  }

  @override
  Future<dynamic> addSortie(String raison, String montant, int idProjet) async {
    final int montantInt = int.tryParse(montant.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
    final newModel = SortieModel(
      nomProjet: "Projet $idProjet",
      montant: montantInt,
      message: raison,
      date: "${DateTime.now().day.toString().padLeft(2, '0')}/${DateTime.now().month.toString().padLeft(2, '0')}/${DateTime.now().year}",
    );
    await localDataSource.addLocalSortie(newModel);
    try {
      return await remoteDataSource.addSortie(raison, montant, idProjet);
    } catch (_) {
      return newModel.toJson();
    }
  }
}
