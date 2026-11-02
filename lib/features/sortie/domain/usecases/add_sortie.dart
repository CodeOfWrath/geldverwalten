import '../repositories/sortie_repository.dart';

class AddSortieUseCase {
  final SortieRepository repository;

  AddSortieUseCase(this.repository);

  Future<dynamic> call(String raison, String montant, int idProjet) async {
    return await repository.addSortie(raison, montant, idProjet);
  }
}
