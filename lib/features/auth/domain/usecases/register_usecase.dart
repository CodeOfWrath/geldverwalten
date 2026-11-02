import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

class RegisterUseCase {
  final AuthRepository repository;

  RegisterUseCase(this.repository);

  Future<UserEntity> call({
    required String nom,
    required String prenom,
    required String pseudo,
    required String email,
    required String password,
  }) async {
    return await repository.register(
      nom: nom,
      prenom: prenom,
      pseudo: pseudo,
      email: email,
      password: password,
    );
  }
}
