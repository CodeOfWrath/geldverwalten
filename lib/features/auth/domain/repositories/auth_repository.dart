import '../entities/user_entity.dart';

abstract class AuthRepository {
  Future<UserEntity> login(String emailOrPseudo, String password);
  Future<UserEntity> register({
    required String nom,
    required String prenom,
    required String pseudo,
    required String email,
    required String password,
  });
  Future<UserEntity> getCurrentUser();
  Future<void> logout();
  Future<void> setGuestMode(bool isGuest, {String? pseudo});
  Future<bool> isGuest();
  Future<void> setHasSeenOnboarding(bool value);
  Future<bool> hasSeenOnboarding();
}
