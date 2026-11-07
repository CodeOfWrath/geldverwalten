import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';

abstract class AuthLocalDataSource {
  Future<void> cacheUser(UserModel user);
  Future<UserModel?> getCachedUser();
  Future<void> clearUser();
  Future<void> setGuestMode(bool isGuest, {String? pseudo});
  Future<bool> isGuest();
  Future<void> setHasSeenOnboarding(bool value);
  Future<bool> hasSeenOnboarding();
  Future<void> saveRegisteredUser({
    required String email,
    required String pseudo,
    required String password,
    required UserModel user,
  });
  Future<UserModel?> validateLocalLogin(String emailOrPseudo, String password);
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final SharedPreferences sharedPreferences;

  static const String cachedUserKey = 'CACHED_USER_KEY';
  static const String guestModeKey = 'GUEST_MODE_KEY';
  static const String hasSeenOnboardingKey = 'HAS_SEEN_ONBOARDING_KEY';
  static const String registeredAccountsKey = 'REGISTERED_ACCOUNTS_KEY';

  AuthLocalDataSourceImpl({required this.sharedPreferences});

  @override
  Future<void> cacheUser(UserModel user) async {
    await sharedPreferences.setString(cachedUserKey, jsonEncode(user.toJson()));
    await sharedPreferences.setBool(guestModeKey, user.isGuest);
  }

  @override
  Future<UserModel?> getCachedUser() async {
    final jsonString = sharedPreferences.getString(cachedUserKey);
    if (jsonString != null) {
      return UserModel.fromJson(jsonDecode(jsonString));
    }
    return null;
  }

  @override
  Future<void> clearUser() async {
    await sharedPreferences.remove(cachedUserKey);
    await sharedPreferences.remove(guestModeKey);
  }

  @override
  Future<void> setGuestMode(bool isGuest, {String? pseudo}) async {
    await sharedPreferences.setBool(guestModeKey, isGuest);
    final String chosenPseudo = (pseudo != null && pseudo.trim().isNotEmpty)
        ? pseudo.trim()
        : 'Visiteur';

    final guestUser = UserModel.fromJson({
      'id': 0,
      'nom': 'Invité',
      'prenom': 'Utilisateur',
      'pseudo': chosenPseudo,
      'email': 'mode.visiteur@depensia.cm',
      'token': '',
      'isGuest': isGuest,
    });
    await cacheUser(guestUser);
  }

  @override
  Future<bool> isGuest() async {
    return sharedPreferences.getBool(guestModeKey) ?? true;
  }

  @override
  Future<void> setHasSeenOnboarding(bool value) async {
    await sharedPreferences.setBool(hasSeenOnboardingKey, value);
  }

  @override
  Future<bool> hasSeenOnboarding() async {
    return sharedPreferences.getBool(hasSeenOnboardingKey) ?? false;
  }

  @override
  Future<void> saveRegisteredUser({
    required String email,
    required String pseudo,
    required String password,
    required UserModel user,
  }) async {
    final list = await _getRegisteredAccounts();
    list.add({
      'email': email.toLowerCase().trim(),
      'pseudo': pseudo.toLowerCase().trim(),
      'password': password.trim(),
      'user': user.toJson(),
    });
    await sharedPreferences.setString(registeredAccountsKey, jsonEncode(list));
  }

  @override
  Future<UserModel?> validateLocalLogin(String emailOrPseudo, String password) async {
    final list = await _getRegisteredAccounts();
    final query = emailOrPseudo.toLowerCase().trim();
    final inputPass = password.trim();

    for (var acc in list) {
      final accEmail = (acc['email'] ?? '').toString().toLowerCase();
      final accPseudo = (acc['pseudo'] ?? '').toString().toLowerCase();
      final accPass = (acc['password'] ?? '').toString();

      if ((accEmail == query || accPseudo == query) && accPass == inputPass) {
        return UserModel.fromJson(acc['user']);
      }
    }
    return null;
  }

  Future<List<Map<String, dynamic>>> _getRegisteredAccounts() async {
    final raw = sharedPreferences.getString(registeredAccountsKey);
    if (raw != null) {
      final List<dynamic> decoded = jsonDecode(raw);
      return decoded.map((e) => Map<String, dynamic>.from(e as Map)).toList();
    }
    return [];
  }
}
