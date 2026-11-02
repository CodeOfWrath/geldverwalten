import '../repositories/projet_repository.dart';

class CreateProjetUseCase {
  final ProjetRepository repository;

  CreateProjetUseCase(this.repository);

  Future<dynamic> call(String nomProjet) async {
    return await repository.createProjet(nomProjet);
  }
}
