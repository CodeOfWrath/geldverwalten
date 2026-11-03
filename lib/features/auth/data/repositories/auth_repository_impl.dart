import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_datasource.dart';
import '../datasources/auth_remote_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<UserEntity> login(String emailOrPseudo, String password) async {
    final userModel = await remoteDataSource.login(emailOrPseudo, password);
    await localDataSource.cacheUser(userModel);
    await localDataSource.setGuestMode(false);
    await localDataSource.setHasSeenOnboarding(true);
    return userModel;
  }

  @override
  Future<UserEntity> register({
    required String nom,
    required String prenom,
    required String pseudo,
    required String email,
    required String password,
  }) async {
    final userModel = await remoteDataSource.register(
      nom: nom,
      prenom: prenom,
      pseudo: pseudo,
      email: email,
      password: password,
    );
    await localDataSource.cacheUser(userModel);
    await localDataSource.setGuestMode(false);
    await localDataSource.setHasSeenOnboarding(true);
    return userModel;
  }

  @override
  Future<UserEntity> getCurrentUser() async {
    final cached = await localDataSource.getCachedUser();
    if (cached != null) {
      return cached;
    }
    return UserEntity.guest;
  }

  @override
  Future<void> logout() async {
    await localDataSource.clearUser();
    await localDataSource.setGuestMode(true);
  }

  @override
  Future<void> setGuestMode(bool isGuest, {String? pseudo}) async {
    await localDataSource.setGuestMode(isGuest, pseudo: pseudo);
  }

  @override
  Future<bool> isGuest() async {
    return await localDataSource.isGuest();
  }

  @override
  Future<void> setHasSeenOnboarding(bool value) async {
    await localDataSource.setHasSeenOnboarding(value);
  }

  @override
  Future<bool> hasSeenOnboarding() async {
    return await localDataSource.hasSeenOnboarding();
  }
}
