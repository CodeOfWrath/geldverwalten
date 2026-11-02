import '../repositories/entree_repository.dart';

class AddEntreeUseCase {
  final EntreeRepository repository;

  AddEntreeUseCase(this.repository);

  Future<dynamic> call(String origine, int montant) async {
    return await repository.addEntree(origine, montant);
  }
}
