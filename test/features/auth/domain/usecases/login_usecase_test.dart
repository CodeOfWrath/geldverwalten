import 'package:flutter_test/flutter_test.dart';
import 'package:geldverwalten/features/auth/domain/entities/user_entity.dart';
import 'package:geldverwalten/features/auth/domain/repositories/auth_repository.dart';
import 'package:geldverwalten/features/auth/domain/usecases/login_usecase.dart';

class MockAuthRepository implements AuthRepository {
  @override
  Future<UserEntity> login(String emailOrPseudo, String password) async {
    return const UserEntity(
      id: 1,
      nom: "Test",
      prenom: "User",
      pseudo: "Micaelle",
      email: "test@depensia.cm",
      token: "mock_jwt_token",
      isGuest: false,
    );
  }

  @override
  Future<UserEntity> register({
    required String nom,
    required String prenom,
    required String pseudo,
    required String email,
    required String password,
  }) async {
    throw UnimplementedError();
  }

  @override
  Future<UserEntity> getCurrentUser() async {
    return UserEntity.guest;
  }

  @override
  Future<void> logout() async {}

  @override
  Future<void> setGuestMode(bool isGuest, {String? pseudo}) async {}

  @override
  Future<bool> isGuest() async => false;

  @override
  Future<void> setHasSeenOnboarding(bool value) async {}

  @override
  Future<bool> hasSeenOnboarding() async => true;
}

void main() {
  late LoginUseCase usecase;
  late MockAuthRepository mockRepository;

  setUp(() {
    mockRepository = MockAuthRepository();
    usecase = LoginUseCase(mockRepository);
  });

  test('should return UserEntity when login is successful', () async {
    final result = await usecase("Micaelle", "password123");

    expect(result.pseudo, "Micaelle");
    expect(result.isGuest, false);
    expect(result.token, "mock_jwt_token");
  });
}
